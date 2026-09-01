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
    @State private var isSaving = false
    @State private var saveErrorMessage = ""
    @State private var isShowingSaveError = false

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
        .alert(
            "티켓을 저장하지 못했어요",
            isPresented: $isShowingSaveError
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
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
                            .font(
                                .system(
                                    size: 28,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(
                                StillColors.Content.primary
                            )

                        Text("확인하면 컬렉션에 저장돼요")
                            .font(
                                .system(
                                    size: 15,
                                    weight: .regular
                                )
                            )
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
                saveTicket(ticket)
            } label: {
                Group {
                    if isSaving {
                        ProgressView()
                            .tint(StillColors.Content.onAccent)
                    } else {
                        Text("확인")
                            .font(
                                .system(
                                    size: 17,
                                    weight: .medium
                                )
                            )
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
            .disabled(isSaving)
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
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(StillColors.Content.primary)

            Text(message)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await loadTicket()
                }
            } label: {
                Text("다시 시도")
                    .font(.system(size: 15, weight: .medium))
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

        do {
            let movieID = review.registration.draft.movieID
            let descriptor = FetchDescriptor<MovieTicket>(
                predicate: #Predicate { ticket in
                    ticket.movieID == movieID
                }
            )
            let savedTickets = try modelContext.fetch(descriptor)
            let usedBackdropPaths = Set(
                savedTickets.map(\.backdropPath)
            )

            await viewModel.loadTicket(
                id: movieID,
                excludingBackdropPaths: usedBackdropPaths
            )
        } catch {
            Log.debug(
                "Failed to load saved backdrop history:",
                error.localizedDescription
            )
            viewModel.showFailure(
                message: "이전에 사용한 티켓 이미지를 확인하지 못했어요."
            )
        }
    }

    private func saveTicket(
        _ generatedTicket: TicketCompleteViewModel.GeneratedTicket
    ) {
        guard !isSaving else { return }
        isSaving = true

        let registration = review.registration
        let draft = registration.draft
        let ticket = MovieTicket(
            movieID: draft.movieID,
            movieTitle: draft.movieTitle,
            posterPath: draft.posterPath,
            watchedDate: draft.watchedDate,
            place: registration.place,
            theater: draft.theater,
            seat: draft.seat,
            platform: draft.platform,
            rating: review.rating,
            tasteFit: review.tasteFit,
            note: review.note,
            storyAnswer: review.answer(for: .story),
            actingAnswer: review.answer(for: .acting),
            directingAnswer: review.answer(for: .directing),
            visualsAnswer: review.answer(for: .visuals),
            musicAnswer: review.answer(for: .music),
            moodAnswer: review.answer(for: .mood),
            backdropIndex: generatedTicket.backdropIndex,
            backdropPath: generatedTicket.backdropPath,
            backdropImageData: generatedTicket.backdropData,
            logoImageData: generatedTicket.logoData,
            logoVerticalCenterRatio: Double(
                generatedTicket.logoPosition.verticalCenterRatio
            )
        )

        modelContext.insert(ticket)

        do {
            try modelContext.save()
            router.returnHomeAfterTicketSave()
        } catch {
            modelContext.delete(ticket)
            isSaving = false
            saveErrorMessage = error.localizedDescription
            isShowingSaveError = true
            Log.debug(
                "Ticket save failed:",
                error.localizedDescription
            )
        }
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
