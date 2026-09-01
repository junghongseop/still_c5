//
//  TicketLoadingView.swift
//  Still
//
//  Created by 정홍섭 on 9/1/26.
//

import SwiftUI

struct TicketLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(StillColors.Accent.primary)

            VStack(spacing: 4) {
                Text("티켓을 만드는 중")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(StillColors.Content.primary)

                Text("영화 이미지와 로고를 불러오고 있어요")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(StillColors.Content.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TicketLoadingView()
        .background(StillColors.Surface.base)
}
