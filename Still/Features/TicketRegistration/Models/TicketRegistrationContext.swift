//
//  TicketRegistrationContext.swift
//  Still
//

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
