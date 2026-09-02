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

    private enum TicketLoadError: LocalizedError {
        case missingBackdrop
        case missingUnusedBackdrop
        case missingLogo

        var errorDescription: String? {
            switch self {
            case .missingBackdrop:
                "사용할 수 있는 배경 이미지가 없어요."

            case .missingUnusedBackdrop:
                "이 영화에서 아직 사용하지 않은 배경 이미지가 없어요."

            case .missingLogo:
                "사용할 수 있는 영화 로고나 제작사 로고가 없어요."
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
    ) -> Bool {
        guard
            !isSaving,
            case let .loaded(generatedTicket) = state
        else {
            return false
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
            )
        )

        modelContext.insert(ticket)

        do {
            try modelContext.save()
            return true
        } catch {
            modelContext.delete(ticket)
            isSaving = false
            saveErrorMessage = error.localizedDescription
            isShowingSaveError = true
            Log.debug("Ticket save failed:", error.localizedDescription)
            return false
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
            let logoData = try await logoData(
                images: imageResponse,
                detail: detailResponse
            )
            let selectedBackdrop = try await selectedBackdropTask
            let logo: UIImage?
            if let logoData {
                guard let decodedLogo = UIImage(data: logoData) else {
                    throw URLError(.cannotDecodeContentData)
                }
                logo = decodedLogo
            } else {
                logo = nil
            }
            let analysis = await imageAnalyzer.analyzeBackdrop(
                imageData: selectedBackdrop.data,
                targetAspectRatio: MomentTicketLayout.aspectRatio,
                logoAspectRatio: logo.map {
                    $0.size.width / $0.size.height
                } ?? 2,
                logoImageData: logoData
            )

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

        let candidates = backdrops.enumerated().filter {
            !excludingPaths.contains($0.element.filePath)
        }

        guard !candidates.isEmpty else {
            throw TicketLoadError.missingUnusedBackdrop
        }

        for (index, backdrop) in candidates.shuffled() {
            try Task.checkCancellation()

            guard let url = originalImageURL(path: backdrop.filePath) else {
                continue
            }

            do {
                let data = try await imageData(from: url)
                let containsText = await imageAnalyzer
                    .containsDistractingText(imageData: data)

                guard !containsText else {
                    Log.debug(
                        "Rejected backdrop containing text:",
                        backdrop.filePath
                    )
                    continue
                }

                Log.debug("Selected random backdrop:", backdrop.filePath)
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

    private func logoData(
        images: TMDBMovieImageResponse,
        detail: TMDBMovieDetailResponse
    ) async throws -> Data? {
        guard !images.logos.isEmpty else {
            Log.debug("Ticket logo: hidden because logos are empty")
            return nil
        }

        let preferredLanguage = preferredLogoLanguage(
            for: detail.originalLanguage
        )
        let logoCandidates = images.logos.filter {
            $0.iso6391 == preferredLanguage
        } + images.logos.filter {
            $0.iso6391 != preferredLanguage
        }

        for candidate in logoCandidates {
            guard let url = originalImageURL(path: candidate.filePath) else {
                continue
            }

            do {
                let data = try await imageData(from: url)
                Log.debug(
                    "Ticket logo: TMDB movie logo",
                    candidate.iso6391 ?? "language-neutral"
                )
                return data
            } catch {
                Log.debug("Failed movie logo:", error.localizedDescription)
            }
        }

        guard
            let productionCompany = detail.productionCompanies.first(
                where: { $0.logoPath != nil }
            ),
            let logoPath = productionCompany.logoPath,
            let logoURL = originalImageURL(path: logoPath)
        else {
            throw TicketLoadError.missingLogo
        }

        Log.debug("Ticket logo: production company", productionCompany.name)
        return try await imageData(from: logoURL)
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
