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
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CollectionDetailViewModel

    private let ticketWidth: CGFloat = 210

    init(id: UUID) {
        _viewModel = State(
            initialValue: CollectionDetailViewModel(ticketID: id)
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Group {
            if let page = viewModel.selectedPage {
                ticketContent(page)
            } else if viewModel.isLoading {
                ProgressView()
                    .tint(StillColors.Content.secondary)
            } else {
                ContentUnavailableView(
                    "티켓을 찾을 수 없어요",
                    systemImage: "ticket",
                    description: Text(viewModel.unavailableDescription)
                )
            }
        }
        .task {
            await viewModel.load(modelContext: modelContext)
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(
                        "티켓 삭제",
                        systemImage: "trash",
                        role: .destructive
                    ) {
                        viewModel.requestSelectedTicketDeletion()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color(uiColor: .label))
                }
                .disabled(viewModel.selectedPage == nil)
                .accessibilityLabel("티켓 메뉴")
            }
        }
        .overlay {
            if viewModel.isShowingDeleteConfirmation {
                TicketDeleteAlert(
                    onCancel: viewModel.dismissDeleteConfirmation,
                    onDelete: deleteSelectedTicket
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(
            .easeInOut(duration: 0.18),
            value: viewModel.isShowingDeleteConfirmation
        )
        .alert(
            "티켓을 삭제하지 못했어요",
            isPresented: $viewModel.isShowingDeleteError
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.deleteErrorMessage)
        }
    }

    private func deleteSelectedTicket() {
        viewModel.dismissDeleteConfirmation()
        let didDeleteLastTicket = viewModel.deleteSelectedTicket(
            modelContext: modelContext
        )

        if didDeleteLastTicket {
            dismiss()
        }
    }

    private func ticketContent(
        _ page: CollectionDetailViewModel.TicketPage
    ) -> some View {
        let ticket = page.ticket

        return ZStack {
            Color.clear
                .background {
                    if let backdrop = page.backdrop {
                        Image(uiImage: backdrop)
                            .resizable()
                            .scaledToFill()
                            .id(page.id)
                            .transition(.opacity)
                    }
                }
                .clipped()
                .blur(radius: 5, opaque: true)
                .overlay {StillColors.Surface.scrim}
                .ignoresSafeArea()
                .animation(
                    .easeInOut(duration: 0.24),
                    value: viewModel.selectedTicketID
                )

            VStack {
                VStack(spacing: 10) {
                    TabView(selection: ticketSelection) {
                        ForEach(viewModel.pages) { page in
                            ticketArtwork(page)
                                .frame(width: ticketWidth)
                                .tag(page.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: ticketHeight)

                    if viewModel.pages.count > 1 {
                        pageIndicator
                    }
                }

                Spacer()

                ticketDetails(ticket)
                    .id(ticket.id)
                    .transition(.opacity)
                    .animation(
                        .easeInOut(duration: 0.2),
                        value: viewModel.selectedTicketID
                    )
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func ticketDetails(_ ticket: MovieTicket) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(ticket.movieTitle)
                    .font(.still(.sectionTitle))
                    .foregroundColor(StillColors.Content.primary)

                Text(viewModel.summaryText(for: ticket))
                    .font(.still(.label))
                    .foregroundColor(StillColors.Content.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("그날의 한마디")
                    .font(.still(.labelEmphasized))
                    .foregroundColor(StillColors.Accent.primary)

                ScrollView {
                    Text(ticket.note)
                        .font(.still(.body))
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
            ForEach(viewModel.pages) { page in
                Circle()
                    .fill(
                        page.id == viewModel.selectedTicketID
                            ? StillColors.Content.primary
                            : StillColors.Content.teriary
                    )
                    .frame(width: 6, height: 6)
                    .scaleEffect(
                        page.id == viewModel.selectedTicketID ? 1 : 0.72
                    )
                    .opacity(
                        page.id == viewModel.selectedTicketID ? 1 : 0.65
                    )
            }
        }
        .animation(
            .interactiveSpring(
                response: 0.32,
                dampingFraction: 0.84,
                blendDuration: 0.12
            ),
            value: viewModel.selectedTicketID
        )
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func ticketArtwork(
        _ page: CollectionDetailViewModel.TicketPage
    ) -> some View {
        if let backdrop = page.backdrop {
            MomentTicket(
                poster: backdrop,
                logo: page.logo,
                logoPosition: page.logoPosition
            )
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
