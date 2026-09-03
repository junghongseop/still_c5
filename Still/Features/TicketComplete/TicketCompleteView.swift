//
//  TicketCompleteView.swift
//  Still
//
//  Created by 정홍섭 on 9/1/26.
//

import SwiftUI
import SwiftData
import UIKit

struct TicketCompleteView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    let review: MovieReviewDraft

    @State private var viewModel = TicketCompleteViewModel()
    @State private var ticketPrintProgress: CGFloat = 0

    private func printTicket() async {
        guard ticketPrintProgress == 0 else { return }

        let clock = ContinuousClock()

        do {
            try await clock.sleep(for: .milliseconds(250))

            let steps = 28
            for step in 1...steps {
                ticketPrintProgress = CGFloat(step) / CGFloat(steps)
                try await clock.sleep(for: .milliseconds(100))
            }
        } catch {
            return
        }
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            switch viewModel.state {
            case .loading:
                TicketLoadingView()

            case let .loaded(ticket):
                completedView(ticket: ticket)

            case let .failed(message):
                loadFailureView(message: message)
            }
        }
        .task(id: review) {
            await loadTicket()
        }
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled()
        .alert(
            "티켓을 저장하지 못했어요",
            isPresented: $viewModel.isShowingSaveError
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.saveErrorMessage)
        }
    }

    private func completedView(
        ticket: TicketCompleteViewModel.GeneratedTicket
    ) -> some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let ticketOffsetMultiplier = ticketPrintProgress - 1

                let defaultTicketWidth: CGFloat = 193
                let defaultTicketHeight: CGFloat = 396

                let topPadding: CGFloat = {
                    switch geometry.size.height {
                    case ..<700:
                        return 24
                    case ..<800:
                        return 48
                    default:
                        return 77
                    }
                }()

                let headerHeight: CGFloat = 150

                let availableTicketHeight = max(
                    0,
                    geometry.size.height - topPadding - headerHeight
                )

                let heightScale = availableTicketHeight / defaultTicketHeight

                let widthScale = (
                    geometry.size.width - 48
                ) / defaultTicketWidth

                let ticketScale = min(
                    1,
                    min(heightScale, widthScale)
                )

                let ticketWidth = defaultTicketWidth * ticketScale
                let ticketHeight = defaultTicketHeight * ticketScale

                VStack(spacing: 15) {
                    Image(systemName: "checkmark")
                        .padding(14)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(
                            StillColors.Content.onAccent
                        )
                        .background(
                            StillColors.Accent.primary
                        )
                        .clipShape(Circle())

                    VStack(spacing: 4) {
                        Text("티켓이 완성됐어요")
                            .font(.still(.heroTitle))
                            .foregroundStyle(
                                StillColors.Content.primary
                            )

                        Text("확인하면 컬렉션에 저장돼요")
                            .font(.still(.label))
                            .foregroundStyle(
                                StillColors.Content.secondary
                            )
                    }

                    ZStack {
                        MomentTicket(
                            poster: ticket.backdrop,
                            logo: ticket.logo,
                            logoPosition: ticket.logoPosition
                        )
                        .frame(
                            width: ticketWidth,
                            height: ticketHeight
                        )
                        .visualEffect { content, geometry in
                            content.offset(
                                y: geometry.size.height
                                    * ticketOffsetMultiplier
                            )
                        }
                    }
                    .frame(
                        width: ticketWidth,
                        height: ticketHeight
                    )
                    .clipped()
                    .task {
                        await printTicket()
                    }
                }
                .padding(.top, topPadding)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
            }

            Button {
                if let ticketID = viewModel.saveTicket(
                    review: review,
                    modelContext: modelContext
                ) {
                    router.showCollectionDetailAfterTicketSave(
                        ticketID: ticketID
                    )
                }
            } label: {
                Group {
                    if viewModel.isSaving {
                        ProgressView()
                            .tint(StillColors.Content.onAccent)
                    } else {
                        Text("확인")
                            .font(.still(.headline))
                    }
                }
                .frame(height: 22)
                .padding(.vertical, 16)
                .foregroundStyle(
                    StillColors.Content.onAccent
                )
                .frame(maxWidth: .infinity)
                .background(
                    StillColors.Accent.strong
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    private func loadFailureView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(StillColors.Accent.primary)

            Text("티켓을 만들지 못했어요")
                .font(.still(.title))
                .foregroundStyle(StillColors.Content.primary)

            Text(message)
                .font(.still(.label))
                .foregroundStyle(StillColors.Content.secondary)
                .multilineTextAlignment(.center)

            Button {
                router.showHomeAfterTicketFailure()
            } label: {
                Text("나가기")
                    .font(.still(.labelEmphasized))
                    .foregroundStyle(StillColors.Content.onAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(StillColors.Accent.strong)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.vertical, 4)
        }
    }

    private func loadTicket() async {
        ticketPrintProgress = 0
        await viewModel.loadTicket(
            review: review,
            modelContext: modelContext
        )
    }
}

#Preview {
    TicketCompleteView(
        review: MovieReviewDraft(
            registration: TicketRegistrationContext(
                place: .theater,
                draft: TicketRegistrationDraft(
                    movieID: 969681,
                    movieTitle: "스파이더맨: 브랜드 뉴 데이",
                    theater: "CGV",
                    seat: "H열 9번"
                )
            ),
            rating: 4.5,
            tasteFit: .perfect,
            answers: [],
            note: "엔딩 크레딧까지 여운이 오래 남았다."
        )
    )
    .environment(AppRouter())
    .modelContainer(for: MovieTicket.self, inMemory: true)
}
