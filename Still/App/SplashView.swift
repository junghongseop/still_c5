//
//  SplashView.swift
//  Still
//

import SwiftUI

/// 시스템 Launch Screen 직후 잠깐 표시되는 인앱 스플래시 화면입니다.
struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var ticketRevealProgress: CGFloat = 0
    @State private var isSymbolSettled = false
    @State private var isNameVisible = false

    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            VStack(spacing: 8) {
                ticketSymbol

                Text("STILL")
                    .font(.still(.display))
                    .tracking(5)
                    .foregroundStyle(StillColors.Content.primary)
                    .padding(.leading, 5)
                    .opacity(isNameVisible ? 1 : 0)
                    .offset(y: reduceMotion ? 0 : (isNameVisible ? 0 : 6))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("스틸")
        .onAppear(perform: startAnimation)
    }

    private var ticketSymbol: some View {
        ZStack {
            Image("ticketMask")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(StillColors.Accent.primary)

            RoundedRectangle(cornerRadius: 4)
                .stroke(StillColors.Surface.base, lineWidth: 2)
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
        }
        .frame(width: 52, height: 103)
        .mask {
            Rectangle()
                .scaleEffect(y: ticketRevealProgress, anchor: .top)
        }
        .scaleEffect(reduceMotion ? 1 : (isSymbolSettled ? 1 : 0.94))
        .rotationEffect(.degrees(-90))
        .frame(width: 103, height: 52)
    }

    private func startAnimation() {
        guard !reduceMotion else {
            ticketRevealProgress = 1
            isSymbolSettled = true
            isNameVisible = true
            return
        }

        withAnimation(.easeOut(duration: 0.58)) {
            ticketRevealProgress = 1
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.12)) {
            isSymbolSettled = true
        }

        withAnimation(.easeOut(duration: 0.35).delay(0.34)) {
            isNameVisible = true
        }
    }
}

#Preview {
    SplashView()
}
