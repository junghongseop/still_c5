//
//  RecommendationSection.swift
//  Still
//
//  Created by 정홍섭 on 8/27/26.
//

import SwiftUI

struct RecommendationSection: View {
    @Environment(AppRouter.self) private var router
    
    let title: String
    let movieID: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundStyle(StillColors.Content.primary)
                .bold()
                .font(.system(size: 24))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<10, id: \.self) { index in
                        Button {
                            router.push(.movieDetail(id: movieID))
                        } label: {
                            Image("poster")
                                .resizable()
                                .frame(width: 110, height: 166)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    RecommendationSection(title: "곧 만나볼 추천 영화")
        .background(.black)
        .environment(AppRouter())
}
