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
        let visibleTickets = filteredTickets

        guard !visibleTickets.isEmpty else {
            return "아직 관람한 영화가 없어요"
        }

        let homeCount = visibleTickets.filter { $0.place == .home }.count
        let theaterCount = visibleTickets.filter {
            $0.place == .theater
        }.count

        guard homeCount + theaterCount == visibleTickets.count else {
            return "관람한 영화가 \(visibleTickets.count)편 있어요"
        }

        guard homeCount > 0 else {
            return "영화관에서만 \(theaterCount)편 봤어요"
        }

        guard theaterCount > 0 else {
            return "집에서만 \(homeCount)편 봤어요"
        }

        guard homeCount != theaterCount else {
            return "집과 영화관에서 \(homeCount)편씩 봤어요"
        }

        return homeCount > theaterCount
            ? "집에서 더 많이 봤어요"
            : "영화관에서 더 많이 봤어요"
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
