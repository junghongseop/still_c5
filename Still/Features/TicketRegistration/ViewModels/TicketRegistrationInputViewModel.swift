//
//  TicketRegistrationInputViewModel.swift
//  Still
//

import Foundation
import Observation

@MainActor
@Observable
final class TicketRegistrationInputViewModel {
    let place: WatchingPlace
    let headerTitle: String
    let headerDescription: String

    let movieTitle: String
    var watchedDate: Date
    var selectedTheater: TheaterOption?
    var customTheater: String
    var selectedSeatRow: String?
    var selectedSeatNumber: Int?
    var selectedPlatform: PlatformOption?
    var customPlatform: String

    init(context: TicketRegistrationContext) {
        place = context.place
        headerTitle = context.headerTitle
        headerDescription = context.headerDescription

        movieTitle = context.draft.movieTitle
        watchedDate = context.draft.watchedDate
        let theaterSelection = Self.theaterSelection(
            from: context.draft.theater
        )
        selectedTheater = theaterSelection.0
            ?? (context.place == .theater ? .cgv : nil)
        customTheater = theaterSelection.1

        let seatSelection = Self.seatSelection(
            from: context.draft.seat
        )
        selectedSeatRow = seatSelection.0
            ?? (context.place == .theater ? "A" : nil)
        selectedSeatNumber = seatSelection.1
            ?? (context.place == .theater ? 1 : nil)

        let platformSelection = Self.platformSelection(
            from: context.draft.platform
        )
        selectedPlatform = platformSelection.0
            ?? (context.place == .home ? .tving : nil)
        customPlatform = platformSelection.1
    }

    var draft: TicketRegistrationDraft {
        TicketRegistrationDraft(
            movieTitle: movieTitle,
            watchedDate: watchedDate,
            theater: place == .theater ? resolvedTheater : "",
            seat: place == .theater ? resolvedSeat : "",
            platform: place == .home ? resolvedPlatform : ""
        )
    }

    private var resolvedTheater: String {
        guard let selectedTheater else { return "" }

        return selectedTheater == .other
            ? customTheater.trimmingCharacters(in: .whitespacesAndNewlines)
            : selectedTheater.rawValue
    }

    private var resolvedSeat: String {
        guard let selectedSeatRow, let selectedSeatNumber else { return "" }
        return "\(selectedSeatRow)열 \(selectedSeatNumber)번"
    }

    private var resolvedPlatform: String {
        guard let selectedPlatform else { return "" }

        return selectedPlatform == .other
            ? customPlatform.trimmingCharacters(in: .whitespacesAndNewlines)
            : selectedPlatform.rawValue
    }

    private static func theaterSelection(
        from theater: String
    ) -> (TheaterOption?, String) {
        guard !theater.isEmpty else { return (nil, "") }

        if let option = TheaterOption.allCases.first(
            where: { $0 != .other && $0.rawValue == theater }
        ) {
            return (option, "")
        }

        return (.other, theater)
    }

    private static func platformSelection(
        from platform: String
    ) -> (PlatformOption?, String) {
        guard !platform.isEmpty else { return (nil, "") }

        if let option = PlatformOption.allCases.first(
            where: { $0 != .other && $0.rawValue == platform }
        ) {
            return (option, "")
        }

        return (.other, platform)
    }

    private static func seatSelection(
        from seat: String
    ) -> (String?, Int?) {
        let normalizedSeat = seat.uppercased()
        let row = normalizedSeat.first.map(String.init).flatMap {
            ("A"..."Z").contains($0) ? $0 : nil
        }
        let number = normalizedSeat
            .split(whereSeparator: { !$0.isNumber })
            .compactMap { Int($0) }
            .first

        return (row, number)
    }
}
