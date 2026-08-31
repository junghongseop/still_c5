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
        let theaterSelection = TheaterOption.selection(
            from: context.draft.theater
        )
        selectedTheater = theaterSelection.option
            ?? (context.place == .theater ? .defaultOption : nil)
        customTheater = theaterSelection.customText

        let seatSelection = Self.seatSelection(
            from: context.draft.seat
        )
        selectedSeatRow = seatSelection.0
            ?? (context.place == .theater ? "A" : nil)
        selectedSeatNumber = seatSelection.1
            ?? (context.place == .theater ? 1 : nil)

        let platformSelection = PlatformOption.selection(
            from: context.draft.platform
        )
        selectedPlatform = platformSelection.option
            ?? (context.place == .home ? .defaultOption : nil)
        customPlatform = platformSelection.customText
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

        return selectedTheater.resolvedValue(customText: customTheater)
    }

    private var resolvedSeat: String {
        guard let selectedSeatRow, let selectedSeatNumber else { return "" }
        return "\(selectedSeatRow)열 \(selectedSeatNumber)번"
    }

    private var resolvedPlatform: String {
        guard let selectedPlatform else { return "" }

        return selectedPlatform.resolvedValue(customText: customPlatform)
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
