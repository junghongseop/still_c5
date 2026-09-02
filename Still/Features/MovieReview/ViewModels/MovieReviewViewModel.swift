//
//  MovieReviewViewModel.swift
//  Still
//

import Foundation
import Observation

@MainActor
@Observable
final class MovieReviewViewModel {
    var selectedRating = 0.5
    var selectedTasteFit: TasteFitOption = .average
    var detailedAnswers: [
        MovieReviewDetailedQuestion: MovieReviewQuestionAnswer
    ] = [:]
    var note = ""
    var isShowingRequiredNoteAlert = false

    func starSymbol(for star: Int) -> String {
        if selectedRating >= Double(star) {
            return "star.fill"
        }

        if selectedRating >= Double(star) - 0.5 {
            return "star.leadinghalf.filled"
        }

        return "star"
    }

    func makeReview(
        registration: TicketRegistrationContext
    ) -> MovieReviewDraft? {
        let trimmedNote = note.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedNote.isEmpty else {
            isShowingRequiredNoteAlert = true
            return nil
        }

        let answers = MovieReviewDetailedQuestion.allCases.compactMap {
            question -> MovieReviewAnswerDraft? in
            guard let answer = detailedAnswers[question] else { return nil }
            return MovieReviewAnswerDraft(
                question: question,
                answer: answer
            )
        }

        return MovieReviewDraft(
            registration: registration,
            rating: selectedRating,
            tasteFit: selectedTasteFit,
            answers: answers,
            note: trimmedNote
        )
    }
}
