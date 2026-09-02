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
        guard let selectedYear else { return tickets }
        return tickets.filter { year(for: $0) == selectedYear }
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
            sortBy: [SortDescriptor(\MovieTicket.watchedDate, order: .reverse)]
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
}
