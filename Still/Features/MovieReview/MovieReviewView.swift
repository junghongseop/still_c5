//
//  MovieReviewView.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieReviewView: View {
    @Environment(AppRouter.self) private var router

    let id: Int
    let title: String
    let poster: String?

    @State private var selectedRating = 0.5
    @State private var selectedTasteFit: TasteFitOption = .average
    @State private var detailedAnswers: [
        MovieReviewDetailedQuestion: MovieReviewQuestionAnswer
    ] = [:]
    @State private var note = ""
    @State private var isShowingRequiredNoteAlert = false

    private func starSymbol(for star: Int) -> String {
        if selectedRating >= Double(star) {
            "star.fill"
        } else if selectedRating >= Double(star) - 0.5 {
            "star.leadinghalf.filled"
        } else {
            "star"
        }
    }

    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("감상 평가")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(StillColors.Content.primary)

                    Text("\(title)를 보고 느낀 점을 알려주세요")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(StillColors.Content.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView {
                    VStack(spacing: 12) {
                        if let poster {
                            AsyncImage(
                                url: URL(string: "https://image.tmdb.org/t/p/original\(poster)")
                            ) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                                    .tint(StillColors.Accent.primary)
                            }
                            .frame(width: 134, height: 202)
                        }

                        HStack(spacing: 8) {
                            Text("별점")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(StillColors.Content.secondary)

                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: starSymbol(for: star))
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        selectedRating >= Double(star) - 0.5
                                        ? StillColors.Accent.primary
                                        : StillColors.Content.teriary
                                    )
                                    .frame(width: 28, height: 28)
                                    .contentShape(Rectangle())
                                    .gesture(
                                        SpatialTapGesture()
                                            .onEnded { value in
                                                let score = value.location.x < 14
                                                ? 0.5
                                                : 1.0
                                                selectedRating = Double(star - 1) + score
                                            }
                                )
                            }
                        }
                        
                        MovieReviewOptionalNoteView(note: $note)

                        MovieReviewTasteFitView(selection: $selectedTasteFit)

                        MovieReviewDetailedQuestionsView(answers: $detailedAnswers)
                            .padding(.bottom, 30)

                        Button(action: saveReview) {
                            Text("평가 저장")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(StillColors.Content.onAccent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(StillColors.Accent.strong)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.vertical, 4)
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
            }
            .padding(.top, 12)
            .padding(.horizontal, 24)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
        .alert(
            "한줄 감상을 입력해 주세요",
            isPresented: $isShowingRequiredNoteAlert
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("평가를 저장하려면 한줄 감상을 남겨야 해요.")
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func saveReview() {
        guard !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isShowingRequiredNoteAlert = true
            return
        }

        Log.debug(
            "Movie review:",
            id,
            selectedRating,
            selectedTasteFit.rawValue,
            detailedAnswers,
            note
        )

        router.push(.ticketComplete(id: id))
    }
}

#Preview {
    MovieReviewView(
        id: 12345,
        title: "파묘",
        poster: "/1E5baAaEse26fej7uHcjOgEE2t2.jpg"
    )
    .environment(AppRouter())
}
