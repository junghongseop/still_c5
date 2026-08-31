//
//  MovieReviewView.swift
//  Still
//
//  Created by 정홍섭 on 8/31/26.
//

import SwiftUI

struct MovieReviewView: View {
    let id: Int
    let title: String
    let poster: String?

    @State private var selectedRating = 0.5
    @State private var selectedTasteFit: TasteFitOption = .average

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

                        MovieReviewTasteFitView(
                            selection: $selectedTasteFit
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
            .padding(.top, 12)
            .padding(.horizontal, 24)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
    }
}

#Preview {
    MovieReviewView(
        id: 12345,
        title: "파묘",
        poster: "/1E5baAaEse26fej7uHcjOgEE2t2.jpg"
    )
}
