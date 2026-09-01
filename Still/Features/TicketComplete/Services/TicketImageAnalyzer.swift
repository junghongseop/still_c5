//
//  TicketImageAnalyzer.swift
//  Still
//
//  Created by 정홍섭 on 9/1/26.
//

import CoreML
import ImageIO
import UIKit
import Vision

struct TicketBackdropAnalysis: Sendable {
    let imageData: Data
    let logoPosition: MomentTicketLogoPosition
}

actor TicketImageAnalyzer {
    private enum DetectionOrientation: CaseIterable {
        case up
        case left
        case right

        var imageOrientation: CGImagePropertyOrientation {
            switch self {
            case .up:
                .up

            case .left:
                .left

            case .right:
                .right
            }
        }
    }

    private struct DetectedRegion {
        let boundingBox: CGRect
        let confidence: CGFloat
    }

    private struct CropResult {
        let image: CGImage
        let normalizedRect: CGRect
    }

    private struct SaliencyResult {
        let regions: [DetectedRegion]
        let attentionPoint: CGPoint?
        let heatRegions: [DetectedRegion]
    }

    private struct AttentionAnalysis {
        let point: CGPoint?
        let heatRegions: [DetectedRegion]
    }

    private struct SubjectFocus {
        let region: DetectedRegion
        let combinesTwoSubjects: Bool
    }

    private struct LuminanceMap {
        let width: Int
        let height: Int
        let pixels: [UInt8]
    }

    private struct LogoAppearance {
        let averageLuminance: CGFloat
        let averageSaturation: CGFloat
    }

    func analyzeBackdrop(
        imageData: Data,
        targetAspectRatio: CGFloat,
        logoAspectRatio: CGFloat = 2,
        logoImageData: Data? = nil
    ) -> TicketBackdropAnalysis {
        guard
            let image = UIImage(data: imageData),
            let cgImage = image.cgImage
        else {
            return TicketBackdropAnalysis(
                imageData: imageData,
                logoPosition: .bottom
            )
        }

        let textRegions = textRegions(in: cgImage)
        let faceRegions = faceRegions(in: cgImage)
        let humanRegions = humanRegions(in: cgImage)
        let saliencyResult = saliencyResult(
            in: cgImage,
            excluding: textRegions
        )
        let contentRegions = saliencyResult.regions.filter {
            !isTextDominated($0, textRegions: textRegions)
        }
        let focusRegion = primaryFocusRegion(
            faces: faceRegions,
            humans: humanRegions,
            content: contentRegions,
            attentionPoint: saliencyResult.attentionPoint
        )

        guard let cropResult = crop(
            cgImage,
            containing: focusRegion.boundingBox,
            targetAspectRatio: targetAspectRatio
        ) else {
            return TicketBackdropAnalysis(
                imageData: imageData,
                logoPosition: .bottom
            )
        }

        let croppedData = UIImage(cgImage: cropResult.image)
            .jpegData(compressionQuality: 1)
            ?? imageData
        let protectedFaces = faceRegions
            + humanRegions.map(inferredHeadRegion)
        let visibleFaces = protectedFaces
            .compactMap {
                region($0, inside: cropResult.normalizedRect)
            }
        let logoAvoidanceRegions = humanRegions

        let visibleRegions = logoAvoidanceRegions
            .compactMap {
                region($0, inside: cropResult.normalizedRect)
            }
        let visibleImportantRegions = (
            contentRegions
                + [focusRegion]
                + saliencyResult.heatRegions
        )
            .compactMap {
                region($0, inside: cropResult.normalizedRect)
            }
        let logoPosition = logoPosition(
            avoiding: visibleRegions,
            protecting: visibleFaces.map(protectedFaceRegion),
            protectingImportantContent: visibleImportantRegions,
            logoHeight: min(
                MomentTicketLayout.logoWidthRatio
                    * targetAspectRatio
                    / max(logoAspectRatio, 0.01),
                MomentTicketLayout.maximumLogoHeightRatio
            ),
            logoAppearance: logoImageData.flatMap(logoAppearance),
            in: cropResult.image
        )

        return TicketBackdropAnalysis(
            imageData: croppedData,
            logoPosition: logoPosition
        )
    }

    private func faceRegions(in image: CGImage) -> [DetectedRegion] {
        for orientation in DetectionOrientation.allCases {
            let request = VNDetectFaceRectanglesRequest()
            configureCPU(for: request)

            do {
                try VNImageRequestHandler(
                    cgImage: image,
                    orientation: orientation.imageOrientation
                )
                    .perform([request])
                let regions = request.results?.map {
                    DetectedRegion(
                        boundingBox: originalBoundingBox(
                            $0.boundingBox,
                            detectedIn: orientation
                        ),
                        confidence: CGFloat($0.confidence)
                    )
                } ?? []

                if !regions.isEmpty {
                    return regions
                }
            } catch {
                continue
            }
        }

        return []
    }

    private func humanRegions(in image: CGImage) -> [DetectedRegion] {
        for orientation in DetectionOrientation.allCases {
            let request = VNDetectHumanRectanglesRequest()
            request.upperBodyOnly = false
            configureCPU(for: request)

            do {
                try VNImageRequestHandler(
                    cgImage: image,
                    orientation: orientation.imageOrientation
                )
                    .perform([request])
                let regions = request.results?.map {
                    DetectedRegion(
                        boundingBox: originalBoundingBox(
                            $0.boundingBox,
                            detectedIn: orientation
                        ),
                        confidence: CGFloat($0.confidence)
                    )
                } ?? []

                if !regions.isEmpty {
                    return regions
                }
            } catch {
                continue
            }
        }

        return []
    }

    private func originalBoundingBox(
        _ boundingBox: CGRect,
        detectedIn orientation: DetectionOrientation
    ) -> CGRect {
        switch orientation {
        case .up:
            boundingBox

        case .left:
            CGRect(
                x: boundingBox.minY,
                y: 1 - boundingBox.maxX,
                width: boundingBox.height,
                height: boundingBox.width
            )

        case .right:
            CGRect(
                x: 1 - boundingBox.maxY,
                y: boundingBox.minX,
                width: boundingBox.height,
                height: boundingBox.width
            )
        }
    }

    private func saliencyResult(
        in image: CGImage,
        excluding textRegions: [CGRect]
    ) -> SaliencyResult {
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        configureCPU(for: request)

        do {
            try VNImageRequestHandler(cgImage: image).perform([request])
            guard let observation = request.results?.first else {
                return SaliencyResult(
                    regions: [],
                    attentionPoint: nil,
                    heatRegions: []
                )
            }

            let regions = observation.salientObjects?.map {
                DetectedRegion(
                    boundingBox: $0.boundingBox,
                    confidence: CGFloat($0.confidence)
                )
            } ?? []

            let attention = attentionAnalysis(
                in: observation.pixelBuffer,
                excluding: textRegions
            )

            return SaliencyResult(
                regions: regions,
                attentionPoint: attention.point,
                heatRegions: attention.heatRegions
            )
        } catch {
            return SaliencyResult(
                regions: [],
                attentionPoint: nil,
                heatRegions: []
            )
        }
    }

    private func configureCPU(for request: VNRequest) {
        guard
            let cpu = MLComputeDevice.allComputeDevices.first(where: {
                if case .cpu = $0 { return true }
                return false
            }),
            let supportedDevices = try? request.supportedComputeStageDevices
        else {
            return
        }

        for (stage, devices) in supportedDevices where devices.contains(cpu) {
            request.setComputeDevice(cpu, for: stage)
        }
    }

    private func attentionAnalysis(
        in pixelBuffer: CVPixelBuffer,
        excluding textRegions: [CGRect]
    ) -> AttentionAnalysis {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return AttentionAnalysis(point: nil, heatRegions: [])
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)

        func value(x: Int, y: Int) -> CGFloat? {
            let rowAddress = baseAddress.advanced(by: y * bytesPerRow)

            switch pixelFormat {
            case kCVPixelFormatType_OneComponent32Float:
                return CGFloat(
                    rowAddress.assumingMemoryBound(to: Float.self)[x]
                )

            case kCVPixelFormatType_OneComponent8:
                return CGFloat(
                    rowAddress.assumingMemoryBound(to: UInt8.self)[x]
                ) / 255

            default:
                return nil
            }
        }

        func normalizedPoint(x: Int, y: Int) -> CGPoint {
            CGPoint(
                x: (CGFloat(x) + 0.5) / CGFloat(width),
                y: 1 - (CGFloat(y) + 0.5) / CGFloat(height)
            )
        }

        func isInsideText(_ point: CGPoint) -> Bool {
            textRegions.contains {
                $0.insetBy(dx: -0.02, dy: -0.02).contains(point)
            }
        }

        var maximumValue = CGFloat.zero

        for y in 0..<height {
            for x in 0..<width {
                let point = normalizedPoint(x: x, y: y)
                guard
                    !isInsideText(point),
                    let value = value(x: x, y: y)
                else {
                    continue
                }

                maximumValue = max(maximumValue, value)
            }
        }

        guard maximumValue > 0 else {
            return AttentionAnalysis(point: nil, heatRegions: [])
        }

        let threshold = maximumValue * 0.72
        var totalWeight = CGFloat.zero
        var weightedX = CGFloat.zero
        var weightedY = CGFloat.zero
        var heatRegions: [DetectedRegion] = []

        for y in 0..<height {
            for x in 0..<width {
                let point = normalizedPoint(x: x, y: y)
                guard
                    !isInsideText(point),
                    let value = value(x: x, y: y),
                    value >= threshold
                else {
                    continue
                }

                totalWeight += value
                weightedX += point.x * value
                weightedY += point.y * value
                heatRegions.append(
                    DetectedRegion(
                        boundingBox: CGRect(
                            x: CGFloat(x) / CGFloat(width),
                            y: 1 - CGFloat(y + 1) / CGFloat(height),
                            width: 1 / CGFloat(width),
                            height: 1 / CGFloat(height)
                        ),
                        confidence: value / maximumValue
                    )
                )
            }
        }

        guard totalWeight > 0 else {
            return AttentionAnalysis(point: nil, heatRegions: [])
        }

        return AttentionAnalysis(
            point: CGPoint(
                x: weightedX / totalWeight,
                y: weightedY / totalWeight
            ),
            heatRegions: heatRegions
        )
    }

    private func textRegions(in image: CGImage) -> [CGRect] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.automaticallyDetectsLanguage = true
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.03

        do {
            try VNImageRequestHandler(cgImage: image).perform([request])
            return request.results?.map(\.boundingBox) ?? []
        } catch {
            return []
        }
    }

    private func isTextDominated(
        _ region: DetectedRegion,
        textRegions: [CGRect]
    ) -> Bool {
        let objectArea = region.boundingBox.width * region.boundingBox.height
        guard objectArea > 0 else { return false }

        let textOverlap = textRegions.reduce(CGFloat.zero) { overlap, textRegion in
            let intersection = region.boundingBox.intersection(textRegion)
            guard !intersection.isNull else { return overlap }

            return overlap + intersection.width * intersection.height
        }

        return textOverlap / objectArea >= 0.6
    }

    private func primaryFocusRegion(
        faces: [DetectedRegion],
        humans: [DetectedRegion],
        content: [DetectedRegion],
        attentionPoint: CGPoint?
    ) -> DetectedRegion {
        let faceFocus = subjectFocus(
            in: faces,
            attentionPoint: attentionPoint
        )
        let humanFocus = subjectFocus(
            in: humans,
            attentionPoint: attentionPoint
        )

        if let faceFocus, faceFocus.combinesTwoSubjects {
            return expandedFaceFocus(faceFocus)
        }

        if let humanFocus, humanFocus.combinesTwoSubjects {
            return humanFocus.region
        }

        if let faceFocus {
            if
                faces.count == 1,
                let attentionPoint,
                !faceFocus.region.boundingBox
                    .insetBy(dx: -0.02, dy: -0.02)
                    .contains(attentionPoint),
                distanceFromRegionCenter(
                    faceFocus.region,
                    to: attentionPoint
                ) <= 0.22
            {
                return attentionRegion(at: attentionPoint)
            }

            return expandedFaceFocus(faceFocus)
        }

        if let humanFocus {
            if
                humans.count > 1
                || attentionPoint.map({
                    subjectMatchesAttention(
                        humanFocus.region,
                        attentionPoint: $0,
                        maximumDistance: 0.18
                    )
                }) ?? true
            {
                return humanFocus.region
            }
        }

        if let attentionPoint {
            return attentionRegion(at: attentionPoint)
        }

        if let salient = content.first {
            return salient
        }

        return DetectedRegion(
            boundingBox: CGRect(x: 0.45, y: 0.45, width: 0.1, height: 0.1),
            confidence: 1
        )
    }

    private func expandedFaceFocus(
        _ focus: SubjectFocus
    ) -> DetectedRegion {
        let face = focus.region
        let horizontalExpansion = focus.combinesTwoSubjects
            ? face.boundingBox.width * 0.15
            : face.boundingBox.width * 0.75
        let verticalExpansion = focus.combinesTwoSubjects
            ? face.boundingBox.height * 0.5
            : face.boundingBox.height
        let expandedBox = face.boundingBox
            .insetBy(
                dx: -horizontalExpansion,
                dy: -verticalExpansion
            )
            .intersection(CGRect(x: 0, y: 0, width: 1, height: 1))

        return DetectedRegion(
            boundingBox: expandedBox,
            confidence: face.confidence
        )
    }

    private func attentionRegion(at point: CGPoint) -> DetectedRegion {
        let focusBox = CGRect(
            x: point.x - 0.05,
            y: point.y - 0.05,
            width: 0.1,
            height: 0.1
        )
            .intersection(CGRect(x: 0, y: 0, width: 1, height: 1))

        return DetectedRegion(
            boundingBox: focusBox,
            confidence: 1
        )
    }

    private func subjectMatchesAttention(
        _ subject: DetectedRegion,
        attentionPoint: CGPoint,
        maximumDistance: CGFloat
    ) -> Bool {
        hypot(
            subject.boundingBox.midX - attentionPoint.x,
            subject.boundingBox.midY - attentionPoint.y
        ) <= maximumDistance
    }

    private func focusContainsAttention(
        _ focus: DetectedRegion,
        attentionPoint: CGPoint
    ) -> Bool {
        focus.boundingBox
            .insetBy(dx: -0.06, dy: -0.06)
            .contains(attentionPoint)
    }

    private func largestRegion(in regions: [DetectedRegion]) -> DetectedRegion? {
        regions.max {
            regionScore($0) < regionScore($1)
        }
    }

    private func subjectFocus(
        in regions: [DetectedRegion],
        attentionPoint: CGPoint?
    ) -> SubjectFocus? {
        guard let dominantSubject = largestRegion(in: regions) else {
            return nil
        }

        let dominantScore = regionScore(dominantSubject)
        let prominentSubjects = regions.filter {
            regionScore($0) >= dominantScore * 0.35
        }
        var bestPair: (first: DetectedRegion, second: DetectedRegion)?
        var bestPairScore = CGFloat.zero

        for firstIndex in prominentSubjects.indices {
            for secondIndex in prominentSubjects.indices
                where secondIndex > firstIndex
            {
                let first = prominentSubjects[firstIndex]
                let second = prominentSubjects[secondIndex]
                guard subjectsAreClose(first, second) else { continue }
                let combinedRegion = DetectedRegion(
                    boundingBox: first.boundingBox.union(second.boundingBox),
                    confidence: min(first.confidence, second.confidence)
                )
                if
                    let attentionPoint,
                    !focusContainsAttention(
                        combinedRegion,
                        attentionPoint: attentionPoint
                    )
                {
                    continue
                }

                let centerDistance = hypot(
                    first.boundingBox.midX - second.boundingBox.midX,
                    first.boundingBox.midY - second.boundingBox.midY
                )
                let pairScore = (regionScore(first) + regionScore(second))
                    / max(centerDistance, 0.05)

                if pairScore > bestPairScore {
                    bestPair = (first, second)
                    bestPairScore = pairScore
                }
            }
        }

        guard let bestPair else {
            let individualSubject: DetectedRegion
            if let attentionPoint {
                individualSubject = prominentSubjects.min {
                    distanceFromRegionCenter($0, to: attentionPoint)
                        < distanceFromRegionCenter($1, to: attentionPoint)
                } ?? dominantSubject
            } else {
                individualSubject = dominantSubject
            }

            return SubjectFocus(
                region: individualSubject,
                combinesTwoSubjects: false
            )
        }

        return SubjectFocus(
            region: DetectedRegion(
                boundingBox: bestPair.first.boundingBox.union(
                    bestPair.second.boundingBox
                ),
                confidence: min(
                    bestPair.first.confidence,
                    bestPair.second.confidence
                )
            ),
            combinesTwoSubjects: true
        )
    }

    private func distanceFromRegionCenter(
        _ region: DetectedRegion,
        to point: CGPoint
    ) -> CGFloat {
        hypot(
            region.boundingBox.midX - point.x,
            region.boundingBox.midY - point.y
        )
    }

    private func subjectsAreClose(
        _ first: DetectedRegion,
        _ second: DetectedRegion
    ) -> Bool {
        let left = first.boundingBox.midX < second.boundingBox.midX
            ? first.boundingBox
            : second.boundingBox
        let right = first.boundingBox.midX < second.boundingBox.midX
            ? second.boundingBox
            : first.boundingBox
        let horizontalGap = max(right.minX - left.maxX, 0)
        let subjectWidth = max(left.width, right.width)
        let verticalDifference = abs(left.midY - right.midY)
        let subjectHeight = max(left.height, right.height)
        let centerDistance = hypot(
            left.midX - right.midX,
            left.midY - right.midY
        )

        return centerDistance <= 0.3
            && horizontalGap <= max(0.08, subjectWidth * 1.5)
            && verticalDifference <= max(0.12, subjectHeight)
    }

    private func regionScore(_ region: DetectedRegion) -> CGFloat {
        region.boundingBox.width
            * region.boundingBox.height
            * region.confidence
    }

    private func crop(
        _ image: CGImage,
        containing focusRegion: CGRect,
        targetAspectRatio: CGFloat
    ) -> CropResult? {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let sourceAspectRatio = width / height
        let pixelRect: CGRect
        let normalizedRect: CGRect

        if sourceAspectRatio > targetAspectRatio {
            let normalizedWidth = targetAspectRatio / sourceAspectRatio
            let originX = cropOrigin(
                containing: focusRegion.minX...focusRegion.maxX,
                cropLength: normalizedWidth
            )

            normalizedRect = CGRect(
                x: originX,
                y: 0,
                width: normalizedWidth,
                height: 1
            )
            pixelRect = CGRect(
                x: originX * width,
                y: 0,
                width: normalizedWidth * width,
                height: height
            )
        } else {
            let normalizedHeight = sourceAspectRatio / targetAspectRatio
            let originY = cropOrigin(
                containing: focusRegion.minY...focusRegion.maxY,
                cropLength: normalizedHeight
            )

            normalizedRect = CGRect(
                x: 0,
                y: originY,
                width: 1,
                height: normalizedHeight
            )
            pixelRect = CGRect(
                x: 0,
                y: (1 - originY - normalizedHeight) * height,
                width: width,
                height: normalizedHeight * height
            )
        }

        guard let croppedImage = image.cropping(to: pixelRect.integral) else {
            return nil
        }

        return CropResult(
            image: croppedImage,
            normalizedRect: normalizedRect
        )
    }

    private func cropOrigin(
        containing range: ClosedRange<CGFloat>,
        cropLength: CGFloat
    ) -> CGFloat {
        let maximumOrigin = 1 - cropLength
        let centeredOrigin = (range.lowerBound + range.upperBound - cropLength) / 2

        guard range.upperBound - range.lowerBound <= cropLength else {
            return min(max(centeredOrigin, 0), maximumOrigin)
        }

        let minimumContainingOrigin = max(range.upperBound - cropLength, 0)
        let maximumContainingOrigin = min(range.lowerBound, maximumOrigin)

        return min(
            max(centeredOrigin, minimumContainingOrigin),
            maximumContainingOrigin
        )
    }

    private func region(
        _ region: DetectedRegion,
        inside cropRect: CGRect
    ) -> DetectedRegion? {
        let intersection = region.boundingBox.intersection(cropRect)
        guard !intersection.isNull else { return nil }

        return DetectedRegion(
            boundingBox: CGRect(
                x: (intersection.minX - cropRect.minX) / cropRect.width,
                y: (intersection.minY - cropRect.minY) / cropRect.height,
                width: intersection.width / cropRect.width,
                height: intersection.height / cropRect.height
            ),
            confidence: region.confidence
        )
    }

    private func protectedFaceRegion(
        _ face: DetectedRegion
    ) -> DetectedRegion {
        let horizontalPadding = max(face.boundingBox.width * 0.45, 0.025)
        let verticalPadding = max(face.boundingBox.height * 0.55, 0.025)
        let protectedBox = face.boundingBox
            .insetBy(dx: -horizontalPadding, dy: -verticalPadding)
            .intersection(CGRect(x: 0, y: 0, width: 1, height: 1))

        return DetectedRegion(
            boundingBox: protectedBox,
            confidence: max(face.confidence, 1)
        )
    }

    private func inferredHeadRegion(
        _ person: DetectedRegion
    ) -> DetectedRegion {
        let personBox = person.boundingBox
        let headHeight = min(
            personBox.height * 0.24,
            max(personBox.width * 0.9, 0.08)
        )
        let headWidth = min(
            personBox.width * 0.72,
            headHeight * 1.15
        )
        let headBox = CGRect(
            x: personBox.midX - headWidth / 2,
            y: personBox.maxY - headHeight,
            width: headWidth,
            height: headHeight
        )
            .intersection(CGRect(x: 0, y: 0, width: 1, height: 1))

        return DetectedRegion(
            boundingBox: headBox,
            confidence: person.confidence
        )
    }

    private func logoPosition(
        avoiding regions: [DetectedRegion],
        protecting faces: [DetectedRegion],
        protectingImportantContent importantRegions: [DetectedRegion],
        logoHeight: CGFloat,
        logoAppearance: LogoAppearance?,
        in image: CGImage
    ) -> MomentTicketLogoPosition {
        guard
            !regions.isEmpty || !faces.isEmpty || !importantRegions.isEmpty
        else {
            return .bottom
        }

        let halfLogoHeight = logoHeight / 2
        let edgeInset: CGFloat = 0.05
        let luminanceMap = luminanceMap(for: image)
        let visionCenterCandidates = stride(
            from: halfLogoHeight + edgeInset,
            through: 1 - halfLogoHeight - edgeInset,
            by: 0.01
        )

        guard let bestVisionCenter = visionCenterCandidates.min(by: {
            logoPlacementScore(
                visionCenterY: $0,
                logoHeight: logoHeight,
                regions: regions,
                protectedFaces: faces,
                importantRegions: importantRegions,
                logoAppearance: logoAppearance,
                luminanceMap: luminanceMap
            ) < logoPlacementScore(
                visionCenterY: $1,
                logoHeight: logoHeight,
                regions: regions,
                protectedFaces: faces,
                importantRegions: importantRegions,
                logoAppearance: logoAppearance,
                luminanceMap: luminanceMap
            )
        }) else {
            return .bottom
        }

        return MomentTicketLogoPosition(
            verticalCenterRatio: 1 - bestVisionCenter
        )
    }

    private func logoPlacementScore(
        visionCenterY: CGFloat,
        logoHeight: CGFloat,
        regions: [DetectedRegion],
        protectedFaces: [DetectedRegion],
        importantRegions: [DetectedRegion],
        logoAppearance: LogoAppearance?,
        luminanceMap: LuminanceMap?
    ) -> CGFloat {
        let logoArea = CGRect(
            x: (1 - MomentTicketLayout.logoWidthRatio) / 2,
            y: visionCenterY - logoHeight / 2,
            width: MomentTicketLayout.logoWidthRatio,
            height: logoHeight
        )
        let protectedFaceOverlap = protectedFaces.reduce(CGFloat.zero) {
            score,
            face in
            let intersection = face.boundingBox.intersection(logoArea)
            guard !intersection.isNull else { return score }

            let faceArea = face.boundingBox.width * face.boundingBox.height
            guard faceArea > 0 else { return score }

            return score
                + intersection.width * intersection.height / faceArea
        }
        let overlap = overlapScore(of: regions, with: logoArea)
        let importantContentOverlap = overlapScore(
            of: importantRegions,
            with: logoArea
        )
        let proximity = regions.reduce(CGFloat.zero) { score, region in
            let regionCenterY = region.boundingBox.midY
            let distance = abs(regionCenterY - visionCenterY)
            let horizontalCoverage = region.boundingBox
                .intersection(
                    CGRect(
                        x: (1 - MomentTicketLayout.logoWidthRatio) / 2,
                        y: 0,
                        width: MomentTicketLayout.logoWidthRatio,
                        height: 1
                    )
                )
                .width

            return score
                + horizontalCoverage
                * region.boundingBox.height
                * region.confidence
                / max(distance, 0.02)
        }
        let complexity = luminanceMap.map {
            visualComplexity(
                visionCenterY: visionCenterY,
                logoHeight: logoHeight,
                in: $0
            )
        } ?? 0
        let contrastPenalty = logoContrastPenalty(
            rasterLogoArea: CGRect(
                x: logoArea.minX,
                y: 1 - logoArea.maxY,
                width: logoArea.width,
                height: logoArea.height
            ),
            logoAppearance: logoAppearance,
            luminanceMap: luminanceMap
        )
        let bottomPreference = visionCenterY * 0.001

        let contrastPriority = logoAppearance.map {
            max(0.15, 1 - $0.averageSaturation * 2)
        } ?? 0

        return protectedFaceOverlap * 1_000_000
            + importantContentOverlap * 20_000
            + overlap * 100
            + proximity
            + contrastPenalty * 30_000 * contrastPriority
            + complexity * 8
            + bottomPreference
    }

    private func logoAppearance(from data: Data) -> LogoAppearance? {
        guard
            let image = UIImage(data: data)?.cgImage,
            image.width > 0,
            image.height > 0
        else {
            return nil
        }

        let width = 128
        let height = max(
            Int(CGFloat(width) * CGFloat(image.height) / CGFloat(image.width)),
            1
        )
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let didDraw = pixels.withUnsafeMutableBytes { bytes in
            guard let context = CGContext(
                data: bytes.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                    | CGBitmapInfo.byteOrder32Big.rawValue
            ) else {
                return false
            }

            context.draw(
                image,
                in: CGRect(x: 0, y: 0, width: width, height: height)
            )
            return true
        }

        guard didDraw else { return nil }

        var weightedLuminance = CGFloat.zero
        var weightedSaturation = CGFloat.zero
        var totalAlpha = CGFloat.zero

        for index in stride(from: 0, to: pixels.count, by: 4) {
            let alpha = CGFloat(pixels[index + 3]) / 255
            guard alpha > 0.05 else { continue }

            let red = CGFloat(pixels[index]) / 255 / alpha
            let green = CGFloat(pixels[index + 1]) / 255 / alpha
            let blue = CGFloat(pixels[index + 2]) / 255 / alpha
            let luminance = red * 0.2126
                + green * 0.7152
                + blue * 0.0722
            let saturation = max(red, green, blue) - min(red, green, blue)

            weightedLuminance += min(luminance, 1) * alpha
            weightedSaturation += min(saturation, 1) * alpha
            totalAlpha += alpha
        }

        guard totalAlpha > 0 else { return nil }
        return LogoAppearance(
            averageLuminance: weightedLuminance / totalAlpha,
            averageSaturation: weightedSaturation / totalAlpha
        )
    }

    private func logoContrastPenalty(
        rasterLogoArea: CGRect,
        logoAppearance: LogoAppearance?,
        luminanceMap: LuminanceMap?
    ) -> CGFloat {
        guard
            let logoAppearance,
            let luminanceMap,
            let backgroundLuminance = averageLuminance(
                in: rasterLogoArea,
                map: luminanceMap
            )
        else {
            return 0
        }

        let lighter = max(
            logoAppearance.averageLuminance,
            backgroundLuminance
        )
        let darker = min(
            logoAppearance.averageLuminance,
            backgroundLuminance
        )
        let contrastRatio = (lighter + 0.05) / (darker + 0.05)

        return 1 / max(contrastRatio, 1)
    }

    private func averageLuminance(
        in area: CGRect,
        map: LuminanceMap
    ) -> CGFloat? {
        let minimumX = max(Int(area.minX * CGFloat(map.width)), 0)
        let maximumX = min(Int(ceil(area.maxX * CGFloat(map.width))), map.width)
        let minimumY = max(Int(area.minY * CGFloat(map.height)), 0)
        let maximumY = min(
            Int(ceil(area.maxY * CGFloat(map.height))),
            map.height
        )
        guard minimumX < maximumX, minimumY < maximumY else { return nil }

        var total = CGFloat.zero
        var count = 0

        for y in minimumY..<maximumY {
            for x in minimumX..<maximumX {
                total += CGFloat(map.pixels[y * map.width + x]) / 255
                count += 1
            }
        }

        guard count > 0 else { return nil }
        return total / CGFloat(count)
    }

    private func luminanceMap(for image: CGImage) -> LuminanceMap? {
        let width = 64
        let height = 128
        var pixels = [UInt8](repeating: 0, count: width * height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let didDraw = pixels.withUnsafeMutableBytes { bytes in
            guard let context = CGContext(
                data: bytes.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.none.rawValue
            ) else {
                return false
            }

            context.interpolationQuality = .low
            context.draw(
                image,
                in: CGRect(x: 0, y: 0, width: width, height: height)
            )
            return true
        }

        guard didDraw else { return nil }
        return LuminanceMap(width: width, height: height, pixels: pixels)
    }

    private func visualComplexity(
        visionCenterY: CGFloat,
        logoHeight: CGFloat,
        in map: LuminanceMap
    ) -> CGFloat {
        let rasterCenterY = 1 - visionCenterY
        let minimumX = Int(CGFloat(map.width) * 0.06)
        let maximumX = Int(CGFloat(map.width) * 0.94)
        let minimumY = max(
            Int((rasterCenterY - logoHeight / 2) * CGFloat(map.height)),
            1
        )
        let maximumY = min(
            Int((rasterCenterY + logoHeight / 2) * CGFloat(map.height)),
            map.height - 1
        )
        var differenceTotal = CGFloat.zero
        var sampleCount = 0

        for y in minimumY..<maximumY {
            for x in max(minimumX, 1)..<maximumX {
                let index = y * map.width + x
                let horizontalDifference = abs(
                    Int(map.pixels[index]) - Int(map.pixels[index - 1])
                )
                let verticalDifference = abs(
                    Int(map.pixels[index])
                        - Int(map.pixels[index - map.width])
                )

                differenceTotal += CGFloat(
                    horizontalDifference + verticalDifference
                ) / 510
                sampleCount += 1
            }
        }

        guard sampleCount > 0 else { return 0 }
        return differenceTotal / CGFloat(sampleCount)
    }

    private func overlapScore(
        of regions: [DetectedRegion],
        with area: CGRect
    ) -> CGFloat {
        regions.reduce(0) { score, region in
            let intersection = region.boundingBox.intersection(area)
            guard !intersection.isNull else { return score }

            return score
                + intersection.width
                * intersection.height
                * region.confidence
        }
    }
}
