//
//  MovieReviewDetailedQuestionsView.swift
//  Still
//

import SwiftUI

enum MovieReviewDetailedQuestion: String, CaseIterable, Identifiable {
    case story = "이야기와 주제가 마음에 들었나요?"
    case acting = "캐릭터와 배우의 연기가 좋았나요?"
    case directing = "연출이 인상적이었나요?"
    case visuals = "영상미가 좋았나요?"
    case music = "음악이 영화와 잘 어울렸나요?"
    case mood = "분위기와 여운이 남았나요?"

    var id: Self { self }
}

enum MovieReviewQuestionAnswer: String, CaseIterable, Identifiable {
    case negative = "아쉬웠어요"
    case positive = "좋았어요"

    var id: Self { self }
}

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

