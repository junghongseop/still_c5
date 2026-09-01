//
//  MovieReviewDetailedQuestionsView.swift
//  Still
//

import SwiftUI

struct MovieReviewDetailedQuestionsView: View {
    @Binding var answers: [
        MovieReviewDetailedQuestion: MovieReviewQuestionAnswer
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("어떤 점이 좋거나 아쉬웠나요?")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(StillColors.Content.primary)

                Text("답할수록 다음 추천이 더 정확해져요 · 선택")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StillColors.Content.secondary)
            }

            VStack(spacing: 12) {
                ForEach(MovieReviewDetailedQuestion.allCases) { question in
                    questionCard(for: question)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func questionCard(
        for question: MovieReviewDetailedQuestion
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.rawValue)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(StillColors.Content.primary)

            HStack(spacing: 12) {
                ForEach(MovieReviewQuestionAnswer.allCases) { answer in
                    answerButton(answer, for: question)
                }
            }
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func answerButton(
        _ answer: MovieReviewQuestionAnswer,
        for question: MovieReviewDetailedQuestion
    ) -> some View {
        let isSelected = answers[question] == answer

        return Button {
            answers[question] = isSelected ? nil : answer
        } label: {
            Text(answer.rawValue)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(
                    isSelected
                        ? StillColors.Content.primary
                        : StillColors.Content.secondary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background {
                    Capsule()
                        .fill(
                            isSelected
                                ? StillColors.Accent.strong
                                : StillColors.Surface.elevated
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected
                                ? StillColors.Accent.strong
                                : StillColors.Border.subtle,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
