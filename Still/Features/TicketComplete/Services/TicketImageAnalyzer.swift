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

struct TicketLogoCandidate: Sendable {
    let data: Data
    let preferencePriority: Int
}

struct TicketBackdropAnalysis: Sendable {
    let imageData: Data
    let logoData: Data?
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
        let averageSaturation: CGFloat
        let samples: [LogoSample]
    }

    private struct LogoSample {
        let normalizedX: CGFloat
        let normalizedY: CGFloat
        let luminance: CGFloat
        let alpha: CGFloat
    }

    private struct LogoSelection {
        let data: Data
        let position: MomentTicketLogoPosition
        let score: CGFloat
    }

    private struct LogoPlacement {
        let position: MomentTicketLogoPosition
        let score: CGFloat
    }

    func analyzeBackdrop(
        imageData: Data,
        targetAspectRatio: CGFloat,
        logoCandidates: [TicketLogoCandidate] = []
    ) -> TicketBackdropAnalysis {
        guard
            let image = UIImage(data: imageData),
            let cgImage = image.cgImage
        else {
            return TicketBackdropAnalysis(
                imageData: imageData,
                logoData: logoCandidates.first?.data,
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
        let textFreeHorizontalRange = recoverableHorizontalRange(
            excluding: textRegions,
            sourceAspectRatio: CGFloat(cgImage.width) / CGFloat(cgImage.height),
            targetAspectRatio: targetAspectRatio
        )

        guard let cropResult = crop(
            cgImage,
            containing: focusRegion.boundingBox,
            targetAspectRatio: targetAspectRatio,
            allowedHorizontalRange: textFreeHorizontalRange
        ) else {
            return TicketBackdropAnalysis(
                imageData: imageData,
                logoData: logoCandidates.first?.data,
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
        let logoSelection = bestLogoSelection(
            from: logoCandidates,
            avoiding: visibleRegions,
            protecting: visibleFaces.map(protectedFaceRegion),
            protectingImportantContent: visibleImportantRegions,
            in: cropResult.image
        )

        return TicketBackdropAnalysis(
            imageData: croppedData,
            logoData: logoSelection?.data,
            logoPosition: logoSelection?.position ?? .bottom
        )
    }

    func containsDistractingText(
        imageData: Data,
        targetAspectRatio: CGFloat
    ) -> Bool {
        guard
            let image = UIImage(data: imageData),
            let cgImage = image.cgImage
        else {
            return true
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.automaticallyDetectsLanguage = true
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.015
        configureCPU(for: request)

        do {
            try VNImageRequestHandler(cgImage: cgImage).perform([request])
        } catch {
            return true
        }

        let distractingTextRegions: [CGRect] = request.results?.compactMap {
            observation -> CGRect? in
            guard
                let candidate = observation.topCandidates(1).first,
                candidate.confidence >= 0.4
            else {
                return nil
            }

            let containsLetterOrNumber = candidate.string.unicodeScalars
                .contains {
                    CharacterSet.alphanumerics.contains($0)
                }
            guard containsLetterOrNumber else { return nil }

            let box = observation.boundingBox
            guard
                box.height >= 0.018,
                box.width >= 0.06 || box.height >= 0.04
            else {
                return nil
            }

            return box
        } ?? []

        guard !distractingTextRegions.isEmpty else { return false }

        let sourceAspectRatio = CGFloat(cgImage.width) / CGFloat(cgImage.height)
        let recoverableRange = recoverableHorizontalRange(
            excluding: distractingTextRegions,
            sourceAspectRatio: sourceAspectRatio,
            targetAspectRatio: targetAspectRatio
        )

        return recoverableRange == nil
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
        var maximumPoint: CGPoint?

        for y in 0..<height {
            for x in 0..<width {
                let point = normalizedPoint(x: x, y: y)
                guard
                    !isInsideText(point),
                    let value = value(x: x, y: y)
                else {
                    continue
                }

                if value > maximumValue {
                    maximumValue = value
                    maximumPoint = point
                }
            }
        }

        guard maximumValue > 0, let maximumPoint else {
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
                    value >= threshold,
                    hypot(
                        point.x - maximumPoint.x,
                        point.y - maximumPoint.y
                    ) <= 0.2
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
        configureCPU(for: request)

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
        if let crowdedFaceGroup = crowdedGroupFocus(in: faces) {
            return crowdedFaceGroup
        }

        if let crowdedHumanGroup = crowdedGroupFocus(in: humans) {
            return crowdedHumanGroup
        }

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

    private func crowdedGroupFocus(
        in regions: [DetectedRegion]
    ) -> DetectedRegion? {
        guard let dominantSubject = largestRegion(in: regions) else {
            return nil
        }

        let dominantScore = regionScore(dominantSubject)
        let group = regions.filter {
            regionScore($0) >= dominantScore * 0.2
        }
        guard group.count >= 3 else { return nil }

        let groupBox = group.dropFirst().reduce(
            group[0].boundingBox
        ) { combinedBox, subject in
            combinedBox.union(subject.boundingBox)
        }

        return DetectedRegion(
            boundingBox: groupBox,
            confidence: group.map(\.confidence).reduce(0, +)
                / CGFloat(group.count)
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
        targetAspectRatio: CGFloat,
        allowedHorizontalRange: ClosedRange<CGFloat>?
    ) -> CropResult? {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let sourceAspectRatio = width / height
        let pixelRect: CGRect
        let normalizedRect: CGRect

        if sourceAspectRatio > targetAspectRatio {
            let normalizedWidth = targetAspectRatio / sourceAspectRatio
            let focusedOriginX = cropOrigin(
                containing: focusRegion.minX...focusRegion.maxX,
                cropLength: normalizedWidth
            )
            let originX: CGFloat
            if
                let allowedHorizontalRange,
                allowedHorizontalRange.upperBound
                    - allowedHorizontalRange.lowerBound >= normalizedWidth
            {
                originX = min(
                    max(focusedOriginX, allowedHorizontalRange.lowerBound),
                    allowedHorizontalRange.upperBound - normalizedWidth
                )
            } else {
                originX = focusedOriginX
            }

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

    private func recoverableHorizontalRange(
        excluding textRegions: [CGRect],
        sourceAspectRatio: CGFloat,
        targetAspectRatio: CGFloat
    ) -> ClosedRange<CGFloat>? {
        guard sourceAspectRatio > targetAspectRatio else { return nil }

        let prominentTextRegions = textRegions.filter {
            $0.width >= 0.12 && $0.height >= 0.05
        }
        guard let firstRegion = prominentTextRegions.first else { return nil }

        let textBounds = prominentTextRegions.dropFirst().reduce(firstRegion) {
            $0.union($1)
        }
        let requiredWidth = targetAspectRatio / sourceAspectRatio
        let margin: CGFloat = 0.03

        if textBounds.maxX <= 0.58 {
            let lowerBound = min(textBounds.maxX + margin, 1)
            guard 1 - lowerBound >= requiredWidth else { return nil }
            return lowerBound...1
        }

        if textBounds.minX >= 0.42 {
            let upperBound = max(textBounds.minX - margin, 0)
            guard upperBound >= requiredWidth else { return nil }
            return 0...upperBound
        }

        return nil
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

    private func bestLogoSelection(
        from candidates: [TicketLogoCandidate],
        avoiding regions: [DetectedRegion],
        protecting faces: [DetectedRegion],
        protectingImportantContent importantRegions: [DetectedRegion],
        in image: CGImage
    ) -> LogoSelection? {
        let luminanceMap = luminanceMap(for: image)
        var selections: [LogoSelection] = []

        for candidate in candidates {
            guard
                let logo = UIImage(data: candidate.data),
                logo.size.height > 0,
                let appearance = logoAppearance(from: candidate.data)
            else {
                continue
            }

            let aspectRatio = logo.size.width / logo.size.height
            let scales: [CGFloat] = aspectRatio < 0.9
                ? [1, 0.9, 0.8, 0.7, 0.6]
                : [1]

            for scale in scales {
                let logoSize = MomentTicketLayout.logoSizeRatios(
                    for: aspectRatio,
                    scale: scale
                )
                let placement = logoPlacement(
                    avoiding: regions,
                    protecting: faces,
                    protectingImportantContent: importantRegions,
                    logoSize: logoSize,
                    logoAppearance: appearance,
                    luminanceMap: luminanceMap,
                    scale: scale
                )
                let sizePenalty = (1 - scale) * (1 - scale) * 1_200
                let preferencePenalty = CGFloat(
                    candidate.preferencePriority
                ) * 600

                selections.append(
                    LogoSelection(
                        data: candidate.data,
                        position: placement.position,
                        score: placement.score
                            + sizePenalty
                            + preferencePenalty
                    )
                )
            }
        }

        return selections.min { $0.score < $1.score }
    }

    private func logoPlacement(
        avoiding regions: [DetectedRegion],
        protecting faces: [DetectedRegion],
        protectingImportantContent importantRegions: [DetectedRegion],
        logoSize: CGSize,
        logoAppearance: LogoAppearance?,
        luminanceMap: LuminanceMap?,
        scale: CGFloat
    ) -> LogoPlacement {
        let logoHeight = logoSize.height

        let halfLogoHeight = logoHeight / 2
        let edgeInset: CGFloat = 0.05
        let visionCenterCandidates = stride(
            from: halfLogoHeight + edgeInset,
            through: 1 - halfLogoHeight - edgeInset,
            by: 0.01
        )
        let scoredCandidates = visionCenterCandidates.map { centerY in
            (
                centerY,
                logoPlacementScore(
                    visionCenterY: centerY,
                    logoSize: logoSize,
                    regions: regions,
                    protectedFaces: faces,
                    importantRegions: importantRegions,
                    logoAppearance: logoAppearance,
                    luminanceMap: luminanceMap
                )
            )
        }

        guard let bestCandidate = scoredCandidates.min(by: {
            $0.1 < $1.1
        }) else {
            return LogoPlacement(
                position: MomentTicketLogoPosition(
                    verticalCenterRatio: 0.84,
                    scale: scale
                ),
                score: .greatestFiniteMagnitude
            )
        }

        return LogoPlacement(
            position: MomentTicketLogoPosition(
                verticalCenterRatio: 1 - bestCandidate.0,
                scale: scale
            ),
            score: bestCandidate.1
        )
    }

    private func logoPlacementScore(
        visionCenterY: CGFloat,
        logoSize: CGSize,
        regions: [DetectedRegion],
        protectedFaces: [DetectedRegion],
        importantRegions: [DetectedRegion],
        logoAppearance: LogoAppearance?,
        luminanceMap: LuminanceMap?
    ) -> CGFloat {
        let logoWidth = logoSize.width
        let logoHeight = logoSize.height
        let logoArea = CGRect(
            x: (1 - logoWidth) / 2,
            y: visionCenterY - logoHeight / 2,
            width: logoWidth,
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
                        x: (1 - logoWidth) / 2,
                        y: 0,
                        width: logoWidth,
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
                logoWidth: logoWidth,
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

        var weightedSaturation = CGFloat.zero
        var totalAlpha = CGFloat.zero
        var samples: [LogoSample] = []

        for pixelIndex in 0..<(width * height) {
            let index = pixelIndex * 4
            let alpha = CGFloat(pixels[index + 3]) / 255
            guard alpha > 0.05 else { continue }

            let red = CGFloat(pixels[index]) / 255 / alpha
            let green = CGFloat(pixels[index + 1]) / 255 / alpha
            let blue = CGFloat(pixels[index + 2]) / 255 / alpha
            let luminance = red * 0.2126
                + green * 0.7152
                + blue * 0.0722
            let saturation = max(red, green, blue) - min(red, green, blue)

            weightedSaturation += min(saturation, 1) * alpha
            totalAlpha += alpha
            samples.append(
                LogoSample(
                    normalizedX: (
                        CGFloat(pixelIndex % width) + 0.5
                    ) / CGFloat(width),
                    normalizedY: (
                        CGFloat(pixelIndex / width) + 0.5
                    ) / CGFloat(height),
                    luminance: min(luminance, 1),
                    alpha: alpha
                )
            )
        }

        guard totalAlpha > 0, !samples.isEmpty else { return nil }
        return LogoAppearance(
            averageSaturation: weightedSaturation / totalAlpha,
            samples: samples
        )
    }

    private func logoContrastPenalty(
        rasterLogoArea: CGRect,
        logoAppearance: LogoAppearance?,
        luminanceMap: LuminanceMap?
    ) -> CGFloat {
        guard
            let logoAppearance,
            let luminanceMap
        else {
            return 0
        }

        let minimumReadableContrast: CGFloat = 1.45
        var unreadableWeight = CGFloat.zero
        var totalWeight = CGFloat.zero

        for sample in logoAppearance.samples {
            let mapX = min(
                max(
                    Int(
                        (rasterLogoArea.minX
                            + sample.normalizedX * rasterLogoArea.width)
                            * CGFloat(luminanceMap.width)
                    ),
                    0
                ),
                luminanceMap.width - 1
            )
            let mapY = min(
                max(
                    Int(
                        (rasterLogoArea.minY
                            + sample.normalizedY * rasterLogoArea.height)
                            * CGFloat(luminanceMap.height)
                    ),
                    0
                ),
                luminanceMap.height - 1
            )
            let backgroundLuminance = CGFloat(
                luminanceMap.pixels[mapY * luminanceMap.width + mapX]
            ) / 255
            let lighter = max(sample.luminance, backgroundLuminance)
            let darker = min(sample.luminance, backgroundLuminance)
            let contrastRatio = (lighter + 0.05) / (darker + 0.05)

            if contrastRatio < minimumReadableContrast {
                unreadableWeight += (
                    minimumReadableContrast - contrastRatio
                ) / (minimumReadableContrast - 1) * sample.alpha
            }
            totalWeight += sample.alpha
        }

        guard totalWeight > 0 else { return 0 }
        return unreadableWeight / totalWeight
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
        logoWidth: CGFloat,
        logoHeight: CGFloat,
        in map: LuminanceMap
    ) -> CGFloat {
        let rasterCenterY = 1 - visionCenterY
        let minimumX = max(
            Int((0.5 - logoWidth / 2) * CGFloat(map.width)),
            1
        )
        let maximumX = min(
            Int((0.5 + logoWidth / 2) * CGFloat(map.width)),
            map.width - 1
        )
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
            for x in minimumX..<maximumX {
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
