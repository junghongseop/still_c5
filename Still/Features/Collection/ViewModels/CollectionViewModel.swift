//
//  CollectionViewModel.swift
//  Still
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CollectionViewModel {
    private(set) var tickets: [MovieTicket] = []
    private(set) var loadErrorMessage: String?
    var selectedYear: Int?

    var availableYears: [Int] {
        Set(tickets.map(year(for:)))
            .sorted(by: >)
    }

    var filteredTickets: [MovieTicket] {
        guard let selectedYear else {
            return groupedTickets
        }

        return tickets
            .filter { year(for: $0) == selectedYear }
            .sorted(by: isWatchedLater)
    }

    var emptyMessage: String {
        if let loadErrorMessage {
            return loadErrorMessage
        }

        return selectedYear == nil
            ? "아직 저장한 티켓이 없어요"
            : "이 해에 저장한 티켓이 없어요"
    }

    func load(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<MovieTicket>(
            sortBy: [SortDescriptor(\MovieTicket.createdAt, order: .reverse)]
        )

        do {
            tickets = try modelContext.fetch(descriptor)
            loadErrorMessage = nil
        } catch {
            tickets = []
            loadErrorMessage = "티켓을 불러오지 못했어요"
            Log.debug("Collection load failed:", error.localizedDescription)
        }
    }

    private func year(for ticket: MovieTicket) -> Int {
        Calendar.current.component(.year, from: ticket.watchedDate)
    }

    private var groupedTickets: [MovieTicket] {
        Dictionary(grouping: tickets, by: \MovieTicket.movieID)
            .compactMap { movieID, tickets -> TicketGroup? in
                guard
                    let firstTicket = tickets.min(by: isWatchedEarlier),
                    let latestTicket = tickets.max(by: isCreatedEarlier)
                else {
                    return nil
                }

                return TicketGroup(
                    movieID: movieID,
                    representative: firstTicket,
                    latestCreatedAt: latestTicket.createdAt,
                    latestWatchedDate: tickets.map(\.watchedDate).max()
                        ?? latestTicket.watchedDate
                )
            }
            .sorted {
                if $0.latestCreatedAt == $1.latestCreatedAt {
                    if $0.latestWatchedDate != $1.latestWatchedDate {
                        return $0.latestWatchedDate > $1.latestWatchedDate
                    }

                    return $0.movieID > $1.movieID
                }

                return $0.latestCreatedAt > $1.latestCreatedAt
            }
            .map(\.representative)
    }

    private func isCreatedEarlier(
        _ lhs: MovieTicket,
        _ rhs: MovieTicket
    ) -> Bool {
        if lhs.createdAt == rhs.createdAt {
            return lhs.persistentModelID < rhs.persistentModelID
        }

        return lhs.createdAt < rhs.createdAt
    }

    private func isWatchedEarlier(
        _ lhs: MovieTicket,
        _ rhs: MovieTicket
    ) -> Bool {
        if lhs.watchedDate == rhs.watchedDate {
            return isCreatedEarlier(lhs, rhs)
        }

        return lhs.watchedDate < rhs.watchedDate
    }

    private func isWatchedLater(
        _ lhs: MovieTicket,
        _ rhs: MovieTicket
    ) -> Bool {
        isWatchedEarlier(rhs, lhs)
    }
}

private struct TicketGroup {
    let movieID: Int
    let representative: MovieTicket
    let latestCreatedAt: Date
    let latestWatchedDate: Date
}
