//
//  TicketCompleteViewModel.swift
//  Still
//
//  Created by 정홍섭 on 9/1/26.
//

import Foundation
import Observation
import SwiftData
import UIKit

@MainActor
@Observable
final class TicketCompleteViewModel {
    struct GeneratedTicket {
        let backdrop: UIImage
        let backdropData: Data
        let backdropIndex: Int
        let backdropPath: String
        let logo: UIImage?
        let logoData: Data?
        let logoPosition: MomentTicketLogoPosition
    }

    enum State {
        case loading
        case loaded(GeneratedTicket)
        case failed(message: String)
    }

    private struct SelectedBackdrop {
        let index: Int
        let path: String
        let data: Data
    }

    private struct LogoSource {
        let path: String
        let preferencePriority: Int
    }

    private enum TicketLoadError: LocalizedError {
        case missingBackdrop

        var errorDescription: String? {
            switch self {
            case .missingBackdrop:
                "사용할 수 있는 배경 이미지가 없어요."
            }
        }
    }

    private(set) var state: State = .loading
    private(set) var isSaving = false
    private(set) var saveErrorMessage = ""
    var isShowingSaveError = false

    @ObservationIgnored private let imageService: TMDBImageService
    @ObservationIgnored private let detailService: TMDBDetailService
    @ObservationIgnored private let imageAnalyzer: TicketImageAnalyzer
    @ObservationIgnored private let session: URLSession

    init() {
        imageService = TMDBImageService()
        detailService = TMDBDetailService()
        imageAnalyzer = TicketImageAnalyzer()
        session = .shared
    }

    init(
        imageService: TMDBImageService,
        detailService: TMDBDetailService,
        imageAnalyzer: TicketImageAnalyzer,
        session: URLSession = .shared
    ) {
        self.imageService = imageService
        self.detailService = detailService
        self.imageAnalyzer = imageAnalyzer
        self.session = session
    }

    func loadTicket(
        review: MovieReviewDraft,
        modelContext: ModelContext
    ) async {
        let movieID = review.registration.draft.movieID

        do {
            let descriptor = FetchDescriptor<MovieTicket>(
                predicate: #Predicate { ticket in
                    ticket.movieID == movieID
                }
            )
            let savedTickets = try modelContext.fetch(descriptor)

            await loadTicket(
                id: movieID,
                excludingBackdropPaths: Set(
                    savedTickets.map(\.backdropPath)
                )
            )
        } catch {
            Log.debug(
                "Failed to load saved backdrop history:",
                error.localizedDescription
            )
            state = .failed(
                message: "이전에 사용한 티켓 이미지를 확인하지 못했어요."
            )
        }
    }

    func saveTicket(
        review: MovieReviewDraft,
        modelContext: ModelContext
    ) -> UUID? {
        guard
            !isSaving,
            case let .loaded(generatedTicket) = state
        else {
            return nil
        }

        isSaving = true
        let registration = review.registration
        let draft = registration.draft
        let ticket = MovieTicket(
            movieID: draft.movieID,
            movieTitle: draft.movieTitle,
            posterPath: draft.posterPath,
            watchedDate: draft.watchedDate,
            place: registration.place,
            theater: draft.theater,
            seat: draft.seat,
            platform: draft.platform,
            rating: review.rating,
            tasteFit: review.tasteFit,
            note: review.note,
            storyAnswer: review.answer(for: .story),
            actingAnswer: review.answer(for: .acting),
            directingAnswer: review.answer(for: .directing),
            visualsAnswer: review.answer(for: .visuals),
            musicAnswer: review.answer(for: .music),
            moodAnswer: review.answer(for: .mood),
            backdropIndex: generatedTicket.backdropIndex,
            backdropPath: generatedTicket.backdropPath,
            backdropImageData: generatedTicket.backdropData,
            logoImageData: generatedTicket.logoData,
            logoVerticalCenterRatio: Double(
                generatedTicket.logoPosition.verticalCenterRatio
            ),
            logoScale: Double(generatedTicket.logoPosition.scale)
        )

        modelContext.insert(ticket)

        do {
            try modelContext.save()
            return ticket.id
        } catch {
            modelContext.delete(ticket)
            isSaving = false
            saveErrorMessage = error.localizedDescription
            isShowingSaveError = true
            Log.debug("Ticket save failed:", error.localizedDescription)
            return nil
        }
    }

    private func loadTicket(
        id: Int,
        excludingBackdropPaths: Set<String>
    ) async {
        state = .loading

        do {
            let imageResponse = try await imageService.movieImage(id: id)
            let detailResponse = try await detailService.detailMovie(id: id)

            Log.debug(
                "TMDB movie images:",
                "id=\(id)",
                "backdrops=\(imageResponse.backdrops.count)",
                "koBackdrops=\(imageResponse.backdrops.filter { $0.iso6391 == "ko" }.count)",
                "koLogos=\(imageResponse.logos.filter { $0.iso6391 == "ko" }.count)",
                "productionCompanies=\(detailResponse.productionCompanies.count)"
            )

            async let selectedBackdropTask = randomBackdrop(
                from: imageResponse.backdrops,
                excludingPaths: excludingBackdropPaths
            )
            async let logoCandidatesTask = logoCandidates(
                images: imageResponse,
                detail: detailResponse
            )
            let (selectedBackdrop, logoCandidates) = try await (
                selectedBackdropTask,
                logoCandidatesTask
            )
            let analysis = await imageAnalyzer.analyzeBackdrop(
                imageData: selectedBackdrop.data,
                targetAspectRatio: MomentTicketLayout.aspectRatio,
                logoCandidates: logoCandidates
            )
            let logoData = analysis.logoData
            let logo: UIImage?
            if let logoData {
                guard let decodedLogo = UIImage(data: logoData) else {
                    throw URLError(.cannotDecodeContentData)
                }
                logo = decodedLogo
            } else {
                logo = nil
            }

            guard
                let backdrop = UIImage(data: analysis.imageData)
            else {
                throw URLError(.cannotDecodeContentData)
            }

            state = .loaded(
                GeneratedTicket(
                    backdrop: backdrop,
                    backdropData: analysis.imageData,
                    backdropIndex: selectedBackdrop.index,
                    backdropPath: selectedBackdrop.path,
                    logo: logo,
                    logoData: logoData,
                    logoPosition: analysis.logoPosition
                )
            )
        } catch is CancellationError {
            return
        } catch {
            Log.debug("Ticket creation failed:", error.localizedDescription)
            state = .failed(message: error.localizedDescription)
        }
    }

    private func originalImageURL(path: String) -> URL? {
        URL(string: "https://image.tmdb.org/t/p/original\(path)")
    }

    private func randomBackdrop(
        from backdrops: [TMDBImage],
        excludingPaths: Set<String>
    ) async throws -> SelectedBackdrop {
        guard !backdrops.isEmpty else {
            throw TicketLoadError.missingBackdrop
        }

        let indexedBackdrops = Array(backdrops.enumerated())
        let unusedCandidates = indexedBackdrops.filter {
            !excludingPaths.contains($0.element.filePath)
        }
        let reusedCandidates = indexedBackdrops.filter {
            excludingPaths.contains($0.element.filePath)
        }
        let candidates = unusedCandidates.shuffled()
            + reusedCandidates.shuffled()

        for (index, backdrop) in candidates {
            try Task.checkCancellation()

            guard let url = originalImageURL(path: backdrop.filePath) else {
                continue
            }

            do {
                let data = try await imageData(from: url)
                let containsText = await imageAnalyzer
                    .containsDistractingText(
                        imageData: data,
                        targetAspectRatio: MomentTicketLayout.aspectRatio
                    )

                guard !containsText else {
                    Log.debug(
                        "Rejected backdrop containing text:",
                        backdrop.filePath
                    )
                    continue
                }

                if excludingPaths.contains(backdrop.filePath) {
                    Log.debug(
                        "Reused backdrop after unused candidates:",
                        backdrop.filePath
                    )
                } else {
                    Log.debug(
                        "Selected random backdrop:",
                        backdrop.filePath
                    )
                }
                return SelectedBackdrop(
                    index: index,
                    path: backdrop.filePath,
                    data: data
                )
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                if Task.isCancelled {
                    throw CancellationError()
                }

                Log.debug(
                    "Failed backdrop candidate:",
                    backdrop.filePath,
                    error.localizedDescription
                )
            }
        }

        throw TicketLoadError.missingBackdrop
    }

    private func logoCandidates(
        images: TMDBMovieImageResponse,
        detail: TMDBMovieDetailResponse
    ) async -> [TicketLogoCandidate] {
        let preferredLanguage = preferredLogoLanguage(
            for: detail.originalLanguage
        )
        let preferredLogos = sortedByQuality(
            images.logos.filter {
                $0.iso6391 == preferredLanguage
            }
        )
        let neutralLogos = sortedByQuality(
            images.logos.filter { $0.iso6391 == nil }
        )
        let fallbackLogos = sortedByQuality(images.logos.filter {
            $0.iso6391 != preferredLanguage && $0.iso6391 != nil
        })
        var sources: [LogoSource] = []
        var usedPaths = Set<String>()

        appendLogoSources(
            preferredLogos,
            priority: 0,
            limit: 4,
            to: &sources,
            usedPaths: &usedPaths
        )
        appendLogoSources(
            neutralLogos,
            priority: preferredLogos.isEmpty ? 0 : 1,
            limit: 3,
            to: &sources,
            usedPaths: &usedPaths
        )
        appendLogoSources(
            fallbackLogos,
            priority: preferredLogos.isEmpty && neutralLogos.isEmpty ? 0 : 2,
            limit: max(8 - sources.count, 0),
            to: &sources,
            usedPaths: &usedPaths
        )

        let movieLogos = await downloadLogoCandidates(from: sources)
        if !movieLogos.isEmpty {
            Log.debug(
                "Ticket logo candidates: movie logos",
                movieLogos.count
            )
            return movieLogos
        }

        let companySources = detail.productionCompanies
            .compactMap(\.logoPath)
            .prefix(3)
            .map {
                LogoSource(path: $0, preferencePriority: 0)
            }
        let companyLogos = await downloadLogoCandidates(
            from: Array(companySources)
        )

        if companyLogos.isEmpty {
            Log.debug("Ticket logo: hidden because no logo could be loaded")
        } else {
            Log.debug(
                "Ticket logo candidates: production companies",
                companyLogos.count
            )
        }

        return companyLogos
    }

    private func sortedByQuality(
        _ images: [TMDBImage]
    ) -> [TMDBImage] {
        images.sorted {
            if $0.voteCount != $1.voteCount {
                return $0.voteCount > $1.voteCount
            }

            if $0.voteAverage != $1.voteAverage {
                return $0.voteAverage > $1.voteAverage
            }

            return $0.width * $0.height > $1.width * $1.height
        }
    }

    private func appendLogoSources(
        _ images: [TMDBImage],
        priority: Int,
        limit: Int,
        to sources: inout [LogoSource],
        usedPaths: inout Set<String>
    ) {
        guard limit > 0 else { return }
        var appendedCount = 0

        for image in images where sources.count < 8 {
            guard
                usedPaths.insert(image.filePath).inserted
            else {
                continue
            }

            sources.append(
                LogoSource(
                    path: image.filePath,
                    preferencePriority: priority
                )
            )
            appendedCount += 1

            if appendedCount >= limit {
                return
            }
        }
    }

    private func downloadLogoCandidates(
        from sources: [LogoSource]
    ) async -> [TicketLogoCandidate] {
        let session = session

        return await withTaskGroup(
            of: (Int, TicketLogoCandidate)?.self
        ) { group in
            for (index, source) in sources.enumerated() {
                guard let url = logoImageURL(path: source.path) else {
                    continue
                }
                let preferencePriority = source.preferencePriority

                group.addTask(priority: .userInitiated) {
                    do {
                        let data = try await Self.imageData(
                            from: url,
                            session: session
                        )
                        return (
                            index,
                            TicketLogoCandidate(
                                data: data,
                                preferencePriority: preferencePriority
                            )
                        )
                    } catch {
                        return nil
                    }
                }
            }

            var downloaded: [(Int, TicketLogoCandidate)] = []
            for await result in group {
                if let result {
                    downloaded.append(result)
                }
            }

            return downloaded
                .sorted { $0.0 < $1.0 }
                .map(\.1)
        }
    }

    private func logoImageURL(path: String) -> URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    private func preferredLogoLanguage(for originalLanguage: String) -> String {
        switch originalLanguage {
        case "ja", "ko":
            originalLanguage

        case "zh", "cn", "yue":
            "zh"

        default:
            "en"
        }
    }

    private func imageData(from url: URL) async throws -> Data {
        try await Self.imageData(from: url, session: session)
    }

    nonisolated private static func imageData(
        from url: URL,
        session: URLSession
    ) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard
            let response = response as? HTTPURLResponse,
            200..<300 ~= response.statusCode,
            UIImage(data: data) != nil
        else {
            throw URLError(.cannotDecodeContentData)
        }

        return data
    }
}
