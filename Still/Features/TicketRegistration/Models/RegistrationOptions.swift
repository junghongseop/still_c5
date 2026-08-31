//
//  RegistrationOptions.swift
//  Still
//

import Foundation

nonisolated protocol RegistrationOption:
    RawRepresentable,
    CaseIterable,
    Hashable,
    Sendable where RawValue == String {
    static var defaultOption: Self { get }
    static var customOption: Self { get }
}

extension RegistrationOption {
    static var options: [Self] {
        Array(allCases)
    }

    static func selection(
        from storedValue: String
    ) -> (option: Self?, customText: String) {
        guard !storedValue.isEmpty else { return (nil, "") }

        if let option = options.first(
            where: { $0 != customOption && $0.rawValue == storedValue }
        ) {
            return (option, "")
        }

        return (customOption, storedValue)
    }

    func resolvedValue(customText: String) -> String {
        self == Self.customOption
            ? customText.trimmingCharacters(in: .whitespacesAndNewlines)
            : rawValue
    }
}

nonisolated enum TheaterOption: String, RegistrationOption {
    case cgv = "CGV"
    case megabox = "MEGABOX"
    case lotteCinema = "롯데시네마"
    case other = "기타"

    static let defaultOption = TheaterOption.cgv
    static let customOption = TheaterOption.other
}

nonisolated enum PlatformOption: String, RegistrationOption {
    case tving = "TVING"
    case netflix = "Netflix"
    case disneyPlus = "Disney+"
    case wavve = "Wavve"
    case watcha = "왓챠"
    case other = "기타"

    static let defaultOption = PlatformOption.tving
    static let customOption = PlatformOption.other
}
