//
//  HomeView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    
    @State private var selectedYear: Int?
    
    private let currentYear = DateUtility.currentYear
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("홈")
                    .foregroundStyle(StillColors.Content.primary)
                    .bold()
                    .font(.system(size: 44))
                
                Spacer()
                
                Button {
                    router.push(.setting)
                } label: {
                    Image(systemName: "person")
                        .font(.system(size: 22))
                        .foregroundStyle(StillColors.Content.primary)
                }
            }
            
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
                .frame(maxHeight: 406)
                .background()
        }
        .screenLayoutStyle()
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
}
