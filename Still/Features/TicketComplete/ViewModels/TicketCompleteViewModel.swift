//
//  TicketCompleteViewModel.swift
//  Still
//
//  Created by 정홍섭 on 9/1/26.
//

import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class TicketCompleteViewModel {
    enum State {
        case loading
        case loaded(
            backdrop: UIImage,
            logo: UIImage?,
            logoPosition: MomentTicketLogoPosition
        )
        case failed(message: String)
    }

    private enum TicketLoadError: LocalizedError {
        case missingBackdrop
        case missingLogo
        case invalidImageURL

        var errorDescription: String? {
            switch self {
            case .missingBackdrop:
                "사용할 수 있는 배경 이미지가 없어요."

            case .missingLogo:
                "사용할 수 있는 영화 로고나 제작사 로고가 없어요."

            case .invalidImageURL:
                "영화 이미지 주소가 올바르지 않아요."
            }
        }
    }

    private(set) var state: State = .loading

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

    func loadTicket(id: Int) async {
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

            guard let backdropPath = imageResponse.backdrops.first?.filePath else {
                throw TicketLoadError.missingBackdrop
            }

            guard let backdropURL = originalImageURL(path: backdropPath) else {
                throw TicketLoadError.invalidImageURL
            }

            async let backdropDataTask = imageData(from: backdropURL)
            let logoData = try await logoData(
                images: imageResponse,
                detail: detailResponse
            )
            let backdropData = try await backdropDataTask
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
                imageData: backdropData,
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
                backdrop: backdrop,
                logo: logo,
                logoPosition: analysis.logoPosition
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
