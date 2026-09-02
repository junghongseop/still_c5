//
//  CollectionDetailViewModel.swift
//  Still
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CollectionDetailViewModel {
    private let initialTicketID: UUID

    private(set) var tickets: [MovieTicket] = []
    var selectedTicketID: UUID
    private(set) var unavailableDescription = "저장되지 않은 티켓이에요."

    var ticket: MovieTicket? {
        tickets.first { $0.id == selectedTicketID }
    }

    init(ticketID: UUID) {
        initialTicketID = ticketID
        selectedTicketID = ticketID
    }

    func load(modelContext: ModelContext) {
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
                tickets = []
                unavailableDescription = "삭제되었거나 저장되지 않은 티켓이에요."
                return
            }

            let movieID = initialTicket.movieID
            let movieTicketsDescriptor = FetchDescriptor<MovieTicket>(
                predicate: #Predicate { ticket in
                    ticket.movieID == movieID
                }
            )

            tickets = try modelContext.fetch(movieTicketsDescriptor)
                .sorted(by: isWatchedEarlier)
            if tickets.contains(where: { $0.id == initialTicketID }) {
                selectedTicketID = initialTicketID
            } else if let firstTicket = tickets.first {
                selectedTicketID = firstTicket.id
            }
        } catch {
            tickets = []
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
}
