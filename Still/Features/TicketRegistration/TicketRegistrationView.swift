//
//  TicketRegistrationView.swift
//  Still
//
//  Created by 정홍섭 on 8/19/26.
//

import SwiftUI

struct TicketRegistrationView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 36) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("어디에서 본 영화인가요?")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(StillColors.Content.primary)

                        Text("관람 환경에 맞는 방법으로 빠르게 기록해요")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(StillColors.Content.secondary)
                    }

                    TicketRegistrationOptionButton(
                        title: "영화관에서 봤어요",
                        description: "영화를 검색해 관람 기록으로 등록"
                    ) {
                        router.push(.theaterMovieSearch)
                    }

                    TicketRegistrationOptionButton(
                        title: "집에서 봤어요",
                        description: "영화를 검색해 시청 기록으로 등록"
                    ) {
                        router.push(.homeMovieSearch)
                    }
                }

                Text("관람 장소를 선택하면 다음 등록 방식으로 이동해요")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(StillColors.Content.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

#Preview {
    TicketRegistrationView()
        .environment(AppRouter())
}
