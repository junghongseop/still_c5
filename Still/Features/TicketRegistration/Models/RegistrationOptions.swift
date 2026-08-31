//
//  RegistrationOptions.swift
//  Still
//

nonisolated protocol RegistrationOption:
    RawRepresentable,
    CaseIterable,
    Hashable,
    Sendable where RawValue == String {
    static var defaultOption: Self { get }
}

extension RegistrationOption {
    static var options: [Self] {
        Array(allCases)
    }

    static func option(from storedValue: String) -> Self? {
        options.first { $0.rawValue == storedValue }
    }
}

nonisolated enum TheaterOption: String, RegistrationOption {
    case cgv = "CGV"
    case megabox = "MEGABOX"
    case lotteCinema = "롯데시네마"

    static let defaultOption = TheaterOption.cgv
}

nonisolated enum PlatformOption: String, RegistrationOption {
    case tving = "TVING"
    case netflix = "Netflix"
    case disneyPlus = "Disney+"
    case wavve = "Wavve"
    case watcha = "왓챠"

    static let defaultOption = PlatformOption.tving
}
