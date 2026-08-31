//
//  MethodSelectionView.swift
//  Still
//
//  Created by 정홍섭 on 8/30/26.
//

import SwiftUI

struct MethodSelectionView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("영화관에서 본 영화를 찾아요")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(StillColors.Content.primary)

                    Text("영화 제목을 검색해 관람 기록으로 등록해요")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StillColors.Content.secondary)
                }

                MethodSelectionButton(
                    title: "영화 검색으로 등록",
                    systemImage: "magnifyingglass"
                ) {
                    router.push(.theaterMovieSearch)
                }

                Text("영화를 선택한 뒤 관람 정보를 입력할 수 있어요")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(StillColors.Content.teriary)
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
        .toolbarVisibility(.visible, for: .navigationBar)
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

#Preview {
    MethodSelectionView()
        .environment(AppRouter())
}
