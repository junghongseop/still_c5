//
//  RegistrationOptions.swift
//  Still
//

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
