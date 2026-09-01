//
//  TicketCompleteView.swift
//  Still
//
//  Created by 정홍섭 on 9/1/26.
//

import SwiftUI

struct TicketCompleteView: View {
    let poster: String
    let logo: String
    
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
        let ticketOffsetMultiplier = ticketPrintProgress - 1

        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            VStack(spacing: 15) {
                Image(systemName: "checkmark")
                    .padding(14)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(StillColors.Content.onAccent)
                    .background(StillColors.Accent.primary)
                    .cornerRadius(99)

                VStack(spacing: 4) {
                    Text("티켓이 완성됐어요")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(StillColors.Content.primary)

                    Text("첫 번째 감상 티켓을 컬렉션에 담았어요")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(StillColors.Content.secondary)
                }

                ZStack {
                    MomentTicket(poster: poster, logo: logo)
                        .visualEffect { content, geometry in
                            content.offset(
                                y: geometry.size.height * ticketOffsetMultiplier
                            )
                        }
                }
                    .frame(maxWidth: 193)
                    .clipped()
                    .task {
                        await printTicket()
                    }
            }
        }
        .overlay(alignment: .bottom) {
            Button {

            } label: {
                Text("확인")
                    .padding(.vertical, 16)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(StillColors.Content.onAccent)
                    .frame(maxWidth: .infinity)
                    .background(StillColors.Accent.strong)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    TicketCompleteView(poster: "spiderman", logo: "logo")
}
