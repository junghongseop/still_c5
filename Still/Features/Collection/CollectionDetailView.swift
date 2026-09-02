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
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CollectionDetailViewModel

    private let ticketWidth: CGFloat = 210

    init(id: UUID) {
        _viewModel = State(
            initialValue: CollectionDetailViewModel(ticketID: id)
        )
    }

    var body: some View {
        Group {
            if let ticket = viewModel.ticket {
                ticketContent(ticket)
            } else {
                ContentUnavailableView(
                    "티켓을 찾을 수 없어요",
                    systemImage: "ticket",
                    description: Text(viewModel.unavailableDescription)
                )
            }
        }
        .onAppear {
            viewModel.load(modelContext: modelContext)
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
                .blur(radius: 5, opaque: true)
                .overlay {StillColors.Surface.scrim}
                .ignoresSafeArea()

            VStack {
                VStack(spacing: 10) {
                    TabView(selection: ticketSelection) {
                        ForEach(viewModel.tickets, id: \.id) { ticket in
                            ticketArtwork(ticket)
                                .frame(width: ticketWidth)
                                .tag(ticket.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: ticketHeight)

                    if viewModel.tickets.count > 1 {
                        pageIndicator
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ticket.movieTitle)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(StillColors.Content.primary)

                        Text(viewModel.summaryText(for: ticket))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(StillColors.Content.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("그날의 한마디")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(StillColors.Accent.primary)

                        ScrollView {
                            Text(ticket.note)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(StillColors.Content.primary)
                        }
                        .scrollIndicators(.hidden)
                        .scrollBounceBehavior(.basedOnSize)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, maxHeight: 122, alignment: .topLeading)
                    .background(StillColors.Surface.raised)
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .inset(by: 0.5)
                            .stroke(StillColors.Border.subtle, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private var ticketHeight: CGFloat {
        ticketWidth / MomentTicketLayout.aspectRatio
    }

    private var ticketSelection: Binding<UUID> {
        Binding(
            get: { viewModel.selectedTicketID },
            set: { viewModel.selectedTicketID = $0 }
        )
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.tickets, id: \.id) { ticket in
                Circle()
                    .fill(
                        ticket.id == viewModel.selectedTicketID
                            ? StillColors.Content.primary
                            : StillColors.Content.teriary
                    )
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityHidden(true)
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
}

#Preview {
    CollectionDetailView(id: UUID())
        .modelContainer(for: MovieTicket.self, inMemory: true)
}
