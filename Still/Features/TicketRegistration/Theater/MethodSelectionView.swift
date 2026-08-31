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
                Text("티켓을 불러올 방법을 선택해 주세요")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(StillColors.Content.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("지류 티켓이나 모바일 예매 화면을 인식해요")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StillColors.Content.secondary)
                    
                    HStack(spacing: 12) {
                        MethodSelectionButton(
                            title: "카메라",
                            systemImage: "camera"
                        ) {}
                        
                        MethodSelectionButton(
                            title: "사진 보관함",
                            systemImage: "photo.on.rectangle.angled"
                        ) {}
                    }
                }
                
                HStack(spacing: 12) {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundStyle(StillColors.Border.subtle)
                    
                    Text("또는")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(StillColors.Content.teriary)
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundStyle(StillColors.Border.subtle)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("티켓이 없다면")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(StillColors.Content.primary)
                    
                    MethodSelectionButton(
                        title: "영화 검색으로 등록",
                        systemImage: "magnifyingglass"
                    ) {
                        router.push(.theaterMovieSearch)
                    }
                }
                
                Text("티켓 이미지는 인식 후 저장되지 않아요")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(StillColors.Content.teriary)
            }
            .padding(.top, 16)
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    MethodSelectionView()
        .environment(AppRouter())
}
