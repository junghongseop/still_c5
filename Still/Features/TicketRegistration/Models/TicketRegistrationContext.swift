//
//  TicketRegistrationContext.swift
//  Still
//

import Foundation

nonisolated enum WatchingPlace: Hashable, Sendable {
    case theater
    case home
}

nonisolated enum TheaterOption: String, CaseIterable, Hashable, Sendable {
    case cgv = "CGV"
    case megabox = "MEGABOX"
    case lotteCinema = "롯데시네마"
    case other = "기타"
}

nonisolated enum PlatformOption: String, CaseIterable, Hashable, Sendable {
    case tving = "TVING"
    case netflix = "Netflix"
    case disneyPlus = "Disney+"
    case wavve = "Wavve"
    case watcha = "왓챠"
    case other = "기타"
}

nonisolated struct TicketRegistrationDraft: Hashable, Sendable {
    var movieTitle = ""
    var watchedDate = Date()
    var theater = ""
    var seat = ""
    var platform = ""
}

nonisolated struct TicketRegistrationContext: Hashable, Sendable {
    let place: WatchingPlace
    let draft: TicketRegistrationDraft

    var headerTitle: String {
        "선택한 영화를 확인해 주세요"
    }

    var headerDescription: String {
        switch place {
        case .home:
            "시청 정보를 입력해 주세요"

        case .theater:
            "관람 정보를 입력해 주세요"
        }
    }
}
