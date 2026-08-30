//
//  RecommendationDetailView.swift
//  Still
//
//  Created by 정홍섭 on 8/29/26.
//

import SwiftUI

struct RecommendationDetailView: View {
    @State private var scrollOffset: CGFloat = 0
    
    private func scrollBackgroundOpacity(fadeEnd: CGFloat) -> Double {
        let progress = min(max(scrollOffset / fadeEnd, 0), 1)

        let easedProgress = progress * progress * (3 - 2 * progress)

        return Double(easedProgress)
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            let contentTopSpacing = screenHeight * 0.72
            
            let fadeEnd = screenHeight * 0.6

            ZStack {
                StillColors.Surface.base
                    .ignoresSafeArea()

                RecommendationPosterBackground(
                    imageName: "poster",
                    width: screenWidth,
                    height: screenHeight
                )

                StillColors.Surface.base
                    .opacity(
                        scrollBackgroundOpacity(fadeEnd: fadeEnd)
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                ScrollView {
                    VStack(spacing: 0) {

                        Color.clear
                            .frame(height: contentTopSpacing)

                        RecommendationContent()
                    }
                }
                .toolbarVisibility(.hidden, for: .tabBar)
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { _, newValue in
                    scrollOffset = newValue
                }
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

#Preview {
    RecommendationDetailView()
}
