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

    let movieID: Int
    let movieTitle: String
    var watchedDate: Date
    var selectedTheater: TheaterOption?
    var selectedSeatRow: String?
    var selectedSeatNumber: Int?
    var selectedPlatform: PlatformOption?

    init(context: TicketRegistrationContext) {
        place = context.place
        headerTitle = context.headerTitle
        headerDescription = context.headerDescription

        movieID = context.draft.movieID
        movieTitle = context.draft.movieTitle
        watchedDate = context.draft.watchedDate
        selectedTheater = TheaterOption.option(
            from: context.draft.theater
        )
            ?? (context.place == .theater ? .defaultOption : nil)

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

        selectedPlatform = PlatformOption.option(
            from: context.draft.platform
        )
            ?? (context.place == .home ? .defaultOption : nil)
    }

    var draft: TicketRegistrationDraft {
        TicketRegistrationDraft(
            movieID: movieID,
            movieTitle: movieTitle,
            watchedDate: watchedDate,
            theater: place == .theater ? resolvedTheater : "",
            seat: place == .theater ? resolvedSeat : "",
            platform: place == .home ? resolvedPlatform : ""
        )
    }

    private var resolvedTheater: String {
        selectedTheater?.rawValue ?? ""
    }

    private var resolvedSeat: String {
        SeatSelection(
            selectedRow: selectedSeatRow,
            selectedNumber: selectedSeatNumber
        )?.storedValue ?? ""
    }

    private var resolvedPlatform: String {
        selectedPlatform?.rawValue ?? ""
    }

}
