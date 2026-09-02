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
    private let ticketID: UUID

    private(set) var ticket: MovieTicket?
    private(set) var unavailableDescription = "저장되지 않은 티켓이에요."

    init(ticketID: UUID) {
        self.ticketID = ticketID
    }

    func load(modelContext: ModelContext) {
        let ticketID = ticketID
        let descriptor = FetchDescriptor<MovieTicket>(
            predicate: #Predicate { ticket in
                ticket.id == ticketID
            }
        )

        do {
            ticket = try modelContext.fetch(descriptor).first
            if ticket == nil {
                unavailableDescription = "삭제되었거나 저장되지 않은 티켓이에요."
            }
        } catch {
            ticket = nil
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
}
