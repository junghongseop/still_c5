//
//  TheaterMovieSearchView.swift
//  Still
//
//  Created by 정홍섭 on 8/30/26.
//

import SwiftUI

struct TheaterMovieSearchView: View {
    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()
            
            MovieSearchContent(
                title: "영화관에서 본 영화를 찾아요",
                subTitle: "티켓이 없는 예전 관람도 영화 제목으로 찾아요"
            )
            .padding(.top, 16)
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

#Preview {
    TheaterMovieSearchView()
}
