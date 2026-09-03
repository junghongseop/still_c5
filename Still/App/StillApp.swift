//
//  StillApp.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI
import SwiftData

@main
struct StillApp: App {
    @State private var router = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .font(.still(.body))
                .environment(router)
        }
        .modelContainer(for: MovieTicket.self)
    }
}

private struct AppRootView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            StillTabView()
                .allowsHitTesting(!isShowingSplash)
                .accessibilityHidden(isShowingSplash)

            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            let displayDuration: Duration = reduceMotion
                ? .milliseconds(650)
                : .milliseconds(1_650)

            try? await Task.sleep(for: displayDuration)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: reduceMotion ? 0.18 : 0.28)) {
                isShowingSplash = false
            }
        }
    }
}
