//
//  WatchingPlace.swift
//  Still
//

nonisolated enum WatchingPlace: String, Hashable, Sendable {
    case theater
    case home

    var displayName: String {
        switch self {
        case .theater:
            "극장"

        case .home:
            "집"
        }
    }
}
