//
//  MovieSummaryCard.swift
//  Still
//
//  Created by 정홍섭 on 8/26/26.
//

import SwiftUI

struct MovieSummaryCard: View {
    let filter: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(filter)
                .font(.still(.captionEmphasized))
                .foregroundStyle(StillColors.Accent.primary)
                .frame(height: 17)
            
            Text(content)
                .font(.still(.headline))
                .foregroundStyle(StillColors.Content.primary)
                .frame(height: 24)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StillColors.Surface.raised)
        .cornerRadius(24)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(StillColors.Border.subtle, lineWidth: 1)
        }
    }
}

#Preview {
    MovieSummaryCard(
        filter: "전체 기록",
        content: "집과 영화관에서 4편씩 봤어요"
    )
}
