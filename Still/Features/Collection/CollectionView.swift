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
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CollectionViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("기록")
                .foregroundStyle(StillColors.Content.primary)
                .font(.still(.display))

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    FilterChip(
                        title: "전체",
                        isSelected: viewModel.selectedYear == nil
                    ) {
                        viewModel.selectedYear = nil
                    }

                    ForEach(viewModel.availableYears, id: \.self) { year in
                        FilterChip(
                            title: String(year),
                            isSelected: viewModel.selectedYear == year
                        ) {
                            viewModel.selectedYear = year
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)

            if viewModel.filteredTickets.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(
                            viewModel.filteredTickets,
                            id: \.id
                        ) { ticket in
                            ticketButton(ticket)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .screenLayoutStyle()
        .onAppear {
            viewModel.load(modelContext: modelContext)
        }
    }

    private var emptyState: some View {
        Text(viewModel.emptyMessage)
            .font(.still(.label))
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
                logoVerticalCenterRatio: ticket.logoVerticalCenterRatio,
                logoScale: ticket.logoScale
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
