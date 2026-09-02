//
//  CollectionDetailViewModel.swift
//  Still
//

import Foundation
import Observation
import SwiftData
import UIKit

@MainActor
@Observable
final class CollectionDetailViewModel {
    struct TicketPage: Identifiable {
        let ticket: MovieTicket
        var backdrop: UIImage?
        var logo: UIImage?
        let logoPosition: MomentTicketLogoPosition
        var isImagePrepared: Bool

        var id: UUID {
            ticket.id
        }

        init(
            ticket: MovieTicket,
            backdrop: UIImage? = nil,
            logo: UIImage? = nil,
            isImagePrepared: Bool = false
        ) {
            self.ticket = ticket
            self.backdrop = backdrop
            self.logo = logo
            self.isImagePrepared = isImagePrepared
            logoPosition = MomentTicketLogoPosition(
                verticalCenterRatio: CGFloat(
                    ticket.logoVerticalCenterRatio
                ),
                scale: CGFloat(ticket.logoScale)
            )
        }
    }

    private struct ImagePayload: Sendable {
        let id: UUID
        let backdropData: Data
        let logoData: Data?
    }

    private struct PreparedPageImages: @unchecked Sendable {
        let id: UUID
        let backdrop: UIImage?
        let logo: UIImage?
    }

    private let initialTicketID: UUID

    private(set) var pages: [TicketPage] = []
    var selectedTicketID: UUID
    private(set) var isLoading = true
    private(set) var unavailableDescription = "저장되지 않은 티켓이에요."
    private(set) var deleteErrorMessage = ""
    var isShowingDeleteConfirmation = false
    var isShowingDeleteError = false

    var selectedPage: TicketPage? {
        pages.first { $0.id == selectedTicketID }
    }

    init(ticketID: UUID) {
        initialTicketID = ticketID
        selectedTicketID = ticketID
    }

    func load(modelContext: ModelContext) async {
        guard pages.isEmpty else {
            await preloadPageImages()
            return
        }

        isLoading = true
        let initialTicketID = initialTicketID
        let initialTicketDescriptor = FetchDescriptor<MovieTicket>(
            predicate: #Predicate { ticket in
                ticket.id == initialTicketID
            }
        )

        do {
            guard
                let initialTicket = try modelContext.fetch(
                    initialTicketDescriptor
                ).first
            else {
                pages = []
                isLoading = false
                unavailableDescription = "삭제되었거나 저장되지 않은 티켓이에요."
                return
            }

            let movieID = initialTicket.movieID
            let movieTicketsDescriptor = FetchDescriptor<MovieTicket>(
                predicate: #Predicate { ticket in
                    ticket.movieID == movieID
                }
            )

            let tickets = try modelContext.fetch(movieTicketsDescriptor)
                .sorted(by: isWatchedEarlier)

            if tickets.contains(where: { $0.id == initialTicketID }) {
                selectedTicketID = initialTicketID
            } else if let firstTicket = tickets.first {
                selectedTicketID = firstTicket.id
            }

            pages = makeInitialPages(from: tickets)
            isLoading = false

            await Task.yield()
            await preloadPageImages()
        } catch {
            pages = []
            isLoading = false
            unavailableDescription = "티켓을 불러오지 못했어요."
            Log.debug(
                "Collection detail load failed:",
                error.localizedDescription
            )
        }
    }

    func summaryText(for ticket: MovieTicket) -> String {
        let date = ticket.watchedDate.formatted(
            .dateTime
                .year()
                .month(.twoDigits)
                .day(.twoDigits)
                .locale(Locale(identifier: "ko_KR"))
        )
        let place = ticket.place?.displayName ?? "관람"
        let rating = ticket.rating.formatted(
            .number.precision(.fractionLength(1))
        )

        return "\(date) · \(place) · ★ \(rating)"
    }

    func requestSelectedTicketDeletion() {
        guard selectedPage != nil else { return }
        isShowingDeleteConfirmation = true
    }

    func deleteSelectedTicket(modelContext: ModelContext) -> Bool {
        guard
            let selectedIndex = pages.firstIndex(
                where: { $0.id == selectedTicketID }
            )
        else {
            return false
        }

        let ticket = pages[selectedIndex].ticket
        modelContext.delete(ticket)

        do {
            try modelContext.save()
            pages.remove(at: selectedIndex)

            guard !pages.isEmpty else { return true }

            let nextIndex = min(selectedIndex, pages.count - 1)
            selectedTicketID = pages[nextIndex].id
            return false
        } catch {
            modelContext.rollback()
            deleteErrorMessage = error.localizedDescription
            isShowingDeleteError = true
            Log.debug(
                "Collection ticket delete failed:",
                error.localizedDescription
            )
            return false
        }
    }

    private func isWatchedEarlier(
        _ lhs: MovieTicket,
        _ rhs: MovieTicket
    ) -> Bool {
        if lhs.watchedDate != rhs.watchedDate {
            return lhs.watchedDate < rhs.watchedDate
        }

        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt < rhs.createdAt
        }

        return lhs.persistentModelID < rhs.persistentModelID
    }

    private func makeInitialPages(
        from tickets: [MovieTicket]
    ) -> [TicketPage] {
        tickets.map { ticket in
            guard ticket.id == selectedTicketID else {
                return TicketPage(ticket: ticket)
            }

            return TicketPage(
                ticket: ticket,
                backdrop: UIImage(data: ticket.backdropImageData),
                logo: ticket.logoImageData.flatMap(UIImage.init(data:)),
                isImagePrepared: true
            )
        }
    }

    private func preloadPageImages() async {
        let payloads = pages
            .filter { !$0.isImagePrepared }
            .map { page in
                ImagePayload(
                    id: page.id,
                    backdropData: page.ticket.backdropImageData,
                    logoData: page.ticket.logoImageData
                )
            }

        await withTaskGroup(of: PreparedPageImages?.self) { group in
            for payload in payloads {
                group.addTask(priority: .userInitiated) {
                    guard !Task.isCancelled else { return nil }
                    return await Self.prepareImages(from: payload)
                }
            }

            for await preparedImages in group {
                guard !Task.isCancelled else {
                    group.cancelAll()
                    return
                }

                guard
                    let preparedImages,
                    let index = pages.firstIndex(
                        where: { $0.id == preparedImages.id }
                    )
                else {
                    continue
                }

                pages[index].backdrop = preparedImages.backdrop
                pages[index].logo = preparedImages.logo
                pages[index].isImagePrepared = true
            }
        }
    }

    nonisolated private static func prepareImages(
        from payload: ImagePayload
    ) async -> PreparedPageImages {
        let backdrop = await preparedImage(from: payload.backdropData)
        let logo = await preparedImage(from: payload.logoData)

        return PreparedPageImages(
            id: payload.id,
            backdrop: backdrop,
            logo: logo
        )
    }

    nonisolated private static func preparedImage(
        from data: Data?
    ) async -> UIImage? {
        guard let data, let image = UIImage(data: data) else {
            return nil
        }

        return await image.byPreparingForDisplay() ?? image
    }
}
