//
//  CollectionDetailView.swift
//  Still
//
//  Created by 정홍섭 on 8/28/26.
//

import SwiftData
import SwiftUI
import UIKit

struct CollectionDetailView: View {
    @Query private var tickets: [MovieTicket]

    init(id: UUID) {
        let ticketID = id
        _tickets = Query(
            filter: #Predicate<MovieTicket> { ticket in
                ticket.id == ticketID
            }
        )
    }

    private var ticket: MovieTicket? {
        tickets.first
    }

    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            if let ticket {
                ticketContent(ticket)
            } else {
                ContentUnavailableView(
                    "티켓을 찾을 수 없어요",
                    systemImage: "ticket",
                    description: Text("삭제되었거나 저장되지 않은 티켓이에요.")
                )
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
        }
    }

    private func ticketContent(_ ticket: MovieTicket) -> some View {
        ZStack {
            Color.clear
                .background {
                    if let backdrop = UIImage(
                        data: ticket.backdropImageData
                    ) {
                        Image(uiImage: backdrop)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .clipped()
                .blur(radius: 10, opaque: true)
                .overlay {
                    StillColors.Surface.scrim
                }
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 56) {
                    ticketArtwork(ticket)
                        .frame(maxWidth: 194)

                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(ticket.movieTitle)
                                .font(.system(size: 22, weight: .regular))
                                .foregroundStyle(
                                    StillColors.Content.primary
                                )

                            Text(summaryText(for: ticket))
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(
                                    StillColors.Content.secondary
                                )
                        }

                        detailCard(title: "그날의 한마디") {
                            Text(ticket.note)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(
                                    StillColors.Content.primary
                                )
                        }

                        if hasDetailedAnswers(ticket) {
                            detailCard(title: "상세 평가") {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(
                                        MovieReviewDetailedQuestion.allCases
                                    ) { question in
                                        if let answer = ticket.answer(
                                            for: question
                                        ) {
                                            VStack(
                                                alignment: .leading,
                                                spacing: 3
                                            ) {
                                                Text(question.rawValue)
                                                    .font(
                                                        .system(
                                                            size: 13,
                                                            weight: .regular
                                                        )
                                                    )
                                                    .foregroundStyle(
                                                        StillColors.Content
                                                            .secondary
                                                    )

                                                Text(answer.rawValue)
                                                    .font(
                                                        .system(
                                                            size: 15,
                                                            weight: .medium
                                                        )
                                                    )
                                                    .foregroundStyle(
                                                        StillColors.Content
                                                            .primary
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    @ViewBuilder
    private func ticketArtwork(_ ticket: MovieTicket) -> some View {
        if let artwork = MomentTicket(
            posterData: ticket.backdropImageData,
            logoData: ticket.logoImageData,
            logoVerticalCenterRatio: ticket.logoVerticalCenterRatio
        ) {
            artwork
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(StillColors.Surface.raised)
                .aspectRatio(
                    MomentTicketLayout.aspectRatio,
                    contentMode: .fit
                )
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(StillColors.Content.teriary)
                }
        }
    }

    private func detailCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(StillColors.Accent.primary)

            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StillColors.Surface.raised)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .inset(by: 0.5)
                .stroke(StillColors.Border.subtle, lineWidth: 1)
        }
    }

    private func summaryText(for ticket: MovieTicket) -> String {
        let date = ticket.watchedDate.formatted(
            .dateTime
                .year()
                .month(.twoDigits)
                .day(.twoDigits)
                .locale(Locale(identifier: "ko_KR"))
        )
        let place = ticket.place?.displayName ?? "관람"
        let rating = ticket.rating.formatted(
            .number.precision(.fractionLength(1))
        )

        return "\(date) · \(place) · ★ \(rating)"
    }

    private func hasDetailedAnswers(_ ticket: MovieTicket) -> Bool {
        MovieReviewDetailedQuestion.allCases.contains {
            ticket.answer(for: $0) != nil
        }
    }
}

#Preview {
    CollectionDetailView(id: UUID())
        .modelContainer(for: MovieTicket.self, inMemory: true)
}
