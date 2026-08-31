//
//  TicketRegistrationDraft.swift
//  Still
//

import Foundation

nonisolated struct TicketRegistrationDraft: Hashable, Sendable {
    var movieTitle = ""
    var watchedDate = Date()
    var theater = ""
    var seat = ""
    var platform = ""
}
