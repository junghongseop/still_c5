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

        let seatSelection = SeatSelection(
            storedValue: context.draft.seat
        )
        selectedSeatRow = seatSelection?.row
            ?? (context.place == .theater
                ? SeatSelection.defaultSelection.row
                : nil)
        selectedSeatNumber = seatSelection?.number
            ?? (context.place == .theater
                ? SeatSelection.defaultSelection.number
                : nil)

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
        SeatSelection(
            selectedRow: selectedSeatRow,
            selectedNumber: selectedSeatNumber
        )?.storedValue ?? ""
    }

    private var resolvedPlatform: String {
        guard let selectedPlatform else { return "" }

        return selectedPlatform.resolvedValue(customText: customPlatform)
    }

}
