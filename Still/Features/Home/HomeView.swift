//
//  HomeView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedYear: Int?
    
    private let currentYear = DateUtility.currentYear
    
    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("홈")
                    .foregroundStyle(StillColors.Content.primary)
                    .bold()
                    .font(.system(size: 44))
                
                HStack(spacing: 8) {
                    FilterChip(title: "전체", isSelected: selectedYear == nil) {
                        selectedYear = nil
                    }
                    
                    FilterChip(title: String(currentYear), isSelected: selectedYear == currentYear) {
                        selectedYear = currentYear
                    }
                }
                
                MovieSummaryCard(
                    filter: selectedYear == currentYear ? String(currentYear) :"전체",
                    content: selectedYear == currentYear
                        ? "올해는 집에서 더 많이 봤어요"
                        : "지금까지 극장에서 더 많이 봤어요"
                )
                
                Text("캐릭터")
                    .frame(maxWidth: .infinity)
                    .frame(height: 406)
                    .background()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    HomeView()
}
