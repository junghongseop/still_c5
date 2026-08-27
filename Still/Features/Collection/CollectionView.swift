//
//  CollectionView.swift
//  Still
//
//  Created by 정홍섭 on 8/19/26.
//

import SwiftUI

struct CollectionView: View {
    @State private var selectedYear: Int?
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("기록")
                .foregroundStyle(StillColors.Content.primary)
                .bold()
                .font(.system(size: 44))
            
            HStack(spacing: 8) {
                FilterChip(title: "전체", isSelected: selectedYear == nil) {
                    selectedYear = nil
                }
                
                FilterChip(title: "2026", isSelected: selectedYear == 2026) {
                    selectedYear = 2026
                }
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<10, id: \.self) { index in
                        MomentTicket(poster: "spiderman", logo: "logo")
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .screenLayoutStyle()
    }
}

#Preview {
    CollectionView()
}
