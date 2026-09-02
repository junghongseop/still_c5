//
//  FilterChip.swift
//  Still
//
//  Created by 정홍섭 on 8/26/26.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.still(.labelEmphasized))
                .foregroundStyle(
                    isSelected ? StillColors.Accent.primary : StillColors.Content.secondary
                )
                .padding(.horizontal, 15)
                .padding(.vertical, 6)
                .background {
                    Capsule()
                        .fill(isSelected ? StillColors.Surface.raised : StillColors.Surface.elevated)
                }
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected ? StillColors.Accent.primary : StillColors.Border.subtle,
                            lineWidth: 1
                        )
                }
        }
    }
}

#Preview("True") {
    FilterChip(title: "전체", isSelected: true, action: {})
}

#Preview("False") {
    FilterChip(title: "전체", isSelected: false, action: {})
}
