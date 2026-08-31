//
//  HomeMovieSearchView.swift
//  Still
//
//  Created by 정홍섭 on 8/30/26.
//

import SwiftUI

struct HomeMovieSearchView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()
            
            MovieSearchContent(
                title: "집에서 본 영화를 찾아요",
                subTitle: "티켓 없이 영화 제목으로 바로 선택해요",
                onSelect: handleSelection
            )
            .padding(.top, 16)
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private func handleSelection(
        _ result: MovieSearchViewModel.SearchResult
    ) {
        let context = TicketRegistrationContext(
            place: .home,
            draft: TicketRegistrationDraft(movieTitle: result.title)
        )
        router.push(.ticketRegistrationInput(context))
    }
}

#Preview {
    HomeMovieSearchView()
        .environment(AppRouter())
}
