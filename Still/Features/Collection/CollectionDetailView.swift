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
        GeometryReader { geometry in
            let layout = CollectionDetailLayout(size: geometry.size)

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
                    .overlay {
                        StillColors.Surface.scrim
                    }
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: layout.ticketContentSpacing) {
                        ticketArtwork(ticket)
                            .frame(width: layout.ticketWidth)

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

                                Text(ticket.note)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(StillColors.Content.primary)
                            }
                            .padding(18)
                            .frame(maxWidth: .infinity, minHeight: 122, alignment: .topLeading)
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
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
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
}

#Preview {
    CollectionDetailView(id: UUID())
        .modelContainer(for: MovieTicket.self, inMemory: true)
}
