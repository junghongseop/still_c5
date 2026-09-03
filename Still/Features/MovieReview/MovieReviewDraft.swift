//
//  MovieReviewDraft.swift
//  Still
//

import Foundation

nonisolated enum TasteFitOption: String, CaseIterable, Identifiable, Sendable {
    case different = "별로예요"
    case average = "보통이에요"
    case perfect = "완전 좋아요"

    var id: Self { self }
}

nonisolated enum MovieReviewDetailedQuestion: String, CaseIterable, Identifiable, Sendable {
    case story = "이야기와 주제가 마음에 들었나요?"
    case acting = "캐릭터와 배우의 연기가 좋았나요?"
    case directing = "연출이 인상적이었나요?"
    case visuals = "영상미가 좋았나요?"
    case music = "음악이 영화와 잘 어울렸나요?"
    case mood = "분위기와 여운이 남았나요?"

    var id: Self { self }
}

nonisolated enum MovieReviewQuestionAnswer: String, CaseIterable, Identifiable, Sendable {
    case negative = "아쉬웠어요"
    case positive = "좋았어요"

    var id: Self { self }
}

nonisolated struct MovieReviewAnswerDraft: Hashable, Sendable {
    let question: MovieReviewDetailedQuestion
    let answer: MovieReviewQuestionAnswer
}

nonisolated struct MovieReviewDraft: Hashable, Sendable {
    let registration: TicketRegistrationContext
    let rating: Double
    let tasteFit: TasteFitOption
    let answers: [MovieReviewAnswerDraft]
    let note: String

    func answer(
        for question: MovieReviewDetailedQuestion
    ) -> MovieReviewQuestionAnswer? {
        answers.first { $0.question == question }?.answer
    }
}
