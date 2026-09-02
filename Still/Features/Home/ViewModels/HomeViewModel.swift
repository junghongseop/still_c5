//
//  HomeViewModel.swift
//  Still
//

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    private(set) var tickets: [MovieTicket] = []
    var selectedYear: Int?

    let currentYear = DateUtility.currentYear

    var summaryFilter: String {
        selectedYear == currentYear ? String(currentYear) : "전체"
    }

    var summaryContent: String {
        let homeCount = filteredTickets.filter { $0.place == .home }.count
        let theaterCount = filteredTickets.filter {
            $0.place == .theater
        }.count

        guard homeCount + theaterCount > 0 else {
            return "아직 기록된 영화가 없어요"
        }

        guard homeCount != theaterCount else {
            return "집과 극장에서 같은 수만큼 봤어요"
        }

        return homeCount > theaterCount
            ? "집에서 더 많이 봤어요"
            : "극장에서 더 많이 봤어요"
    }

    func load(modelContext: ModelContext) {
        do {
            tickets = try modelContext.fetch(FetchDescriptor<MovieTicket>())
        } catch {
            tickets = []
            Log.debug("Home tickets load failed:", error.localizedDescription)
        }
    }

    private var filteredTickets: [MovieTicket] {
        guard let selectedYear else { return tickets }

        return tickets.filter {
            Calendar.current.component(.year, from: $0.watchedDate)
                == selectedYear
        }
    }
}
