//
//  TicketRegistrationDraft.swift
//  Still
//

import Foundation

nonisolated struct TicketRegistrationDraft: Hashable, Sendable {
    var movieID: Int
    var movieTitle = ""
    var posterPath: String? = nil
    var watchedDate = Date()
    var theater = ""
    var seat = ""
    var platform = ""
}
