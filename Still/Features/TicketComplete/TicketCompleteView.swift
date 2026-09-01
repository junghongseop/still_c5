//
//  TicketCompleteView.swift
//  Still
//
//  Created by 정홍섭 on 9/1/26.
//

import SwiftUI
import UIKit

struct TicketCompleteView: View {
    let id: Int

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
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            switch viewModel.state {
            case .loading:
                TicketLoadingView()

            case let .loaded(backdrop, logo, logoPosition):
                completedView(
                    backdrop: backdrop,
                    logo: logo,
                    logoPosition: logoPosition
                )

            case let .failed(message):
                loadFailureView(message: message)
            }
        }
        .task(id: id) {
            await loadTicket()
        }
    }

    private func completedView(
        backdrop: UIImage,
        logo: UIImage?,
        logoPosition: MomentTicketLogoPosition
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

                        Text("첫 번째 감상 티켓을 컬렉션에 담았어요")
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
                            poster: backdrop,
                            logo: logo,
                            logoPosition: logoPosition
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
            } label: {
                Text("확인")
                    .padding(.vertical, 16)
                    .font(
                        .system(
                            size: 17,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        StillColors.Content.onAccent
                    )
                    .frame(maxWidth: .infinity)
                    .background(
                        StillColors.Accent.strong
                    )
                    .cornerRadius(12)
            }
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
        await viewModel.loadTicket(id: id)
    }
}

#Preview {
    TicketCompleteView(id: 969681)
}
