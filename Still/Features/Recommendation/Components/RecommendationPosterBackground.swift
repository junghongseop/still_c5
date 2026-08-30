//
//  RecommendationPosterBackground.swift
//  Still
//
//  Created by 정홍섭 on 8/30/26.
//

import SwiftUI

struct RecommendationPosterBackground: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: width,
                    height: height
                )
                .ignoresSafeArea()

            LinearGradient(
                stops: [
                    .init(
                        color: .clear,
                        location: 0
                    ),
                    .init(
                        color: .clear,
                        location: 0.28
                    ),
                    .init(
                        color: StillColors.Surface.base,
                        location: 0.8
                    ),
                    .init(
                        color: StillColors.Surface.base,
                        location: 1
                    )
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(
                width: width,
                height: height
            )
        }
        .frame(
            width: width,
            height: height
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GeometryReader { geometry in
        RecommendationPosterBackground(
            imageName: "poster",
            width: geometry.size.width,
            height: geometry.size.height
        )
    }
}
