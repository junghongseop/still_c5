//
//  RecommendationView.swift
//  Still
//
//  Created by 정홍섭 on 8/19/26.
//

import SwiftUI

struct RecommendationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("추천")
                .foregroundStyle(StillColors.Content.primary)
                .bold()
                .font(.system(size: 44))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    RecommendationSection(title: "곧 만나볼 추천 영화")
                    RecommendationSection(title: "테오님이 좋아할 만한 영화")
                    RecommendationSection(title: "요즘 취향에 어울리는 영화")
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .screenLayoutStyle()
    }
}

#Preview {
    RecommendationView()
        .environment(AppRouter())
}
