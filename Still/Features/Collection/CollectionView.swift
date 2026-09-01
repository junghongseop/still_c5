//
//  CollectionView.swift
//  Still
//
//  Created by 정홍섭 on 8/19/26.
//

import SwiftData
import SwiftUI

struct CollectionView: View {
    @Environment(AppRouter.self) private var router
    @Query(
        sort: \MovieTicket.watchedDate,
        order: .reverse
    ) private var tickets: [MovieTicket]

    @State private var selectedYear: Int?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible())
    ]

    private var availableYears: [Int] {
        Set(
            tickets.map {
                Calendar.current.component(.year, from: $0.watchedDate)
            }
        )
        .sorted(by: >)
    }

    private var filteredTickets: [MovieTicket] {
        guard let selectedYear else { return tickets }

        return tickets.filter {
            Calendar.current.component(.year, from: $0.watchedDate)
                == selectedYear
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("기록")
                .foregroundStyle(StillColors.Content.primary)
                .bold()
                .font(.system(size: 44))

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "전체",
                        isSelected: selectedYear == nil
                    ) {
                        selectedYear = nil
                    }

                    ForEach(availableYears, id: \.self) { year in
                        FilterChip(
                            title: String(year),
                            isSelected: selectedYear == year
                        ) {
                            selectedYear = year
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            if filteredTickets.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredTickets, id: \.id) { ticket in
                            ticketButton(ticket)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .screenLayoutStyle()
    }

    private var emptyState: some View {
        Text(selectedYear == nil
             ? "아직 저장한 티켓이 없어요"
             : "이 해에 저장한 티켓이 없어요")
        .font(.system(size: 15, weight: .regular))
        .foregroundStyle(StillColors.Content.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func ticketButton(_ ticket: MovieTicket) -> some View {
        Button {
            router.push(.ticketDetail(id: ticket.id))
        } label: {
            if let artwork = MomentTicket(
                posterData: ticket.backdropImageData,
                logoData: ticket.logoImageData,
                logoVerticalCenterRatio: ticket.logoVerticalCenterRatio
            ) {
                artwork
            } else {
                RoundedRectangle(cornerRadius: 8)
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
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(ticket.movieTitle), \(ticket.place?.displayName ?? "관람") 티켓"
        )
    }
}

#Preview {
    CollectionView()
        .environment(AppRouter())
        .modelContainer(for: MovieTicket.self, inMemory: true)
}
