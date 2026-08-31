//
//  MovieSearchView.swift
//  Still
//

import SwiftUI

struct MovieSearchView: View {
    let place: WatchingPlace

    @Environment(AppRouter.self) private var router

    var body: some View {
        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            MovieSearchContent(
                title: title,
                subtitle: subtitle,
                onSelect: handleSelection
            )
            .padding(.top, 16)
            .padding(.horizontal, 24)
            .frame(maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var title: String {
        switch place {
        case .theater:
            "영화관에서 본 영화를 찾아요"

        case .home:
            "집에서 본 영화를 찾아요"
        }
    }

    private var subtitle: String {
        switch place {
        case .theater:
            "티켓이 없는 예전 관람도 영화 제목으로 찾아요"

        case .home:
            "티켓 없이 영화 제목으로 바로 선택해요"
        }
    }

    private func handleSelection(
        _ result: MovieSearchViewModel.SearchResult
    ) {
        let context = TicketRegistrationContext(
            place: place,
            draft: TicketRegistrationDraft(
                movieID: result.id,
                movieTitle: result.title
            )
        )
        router.push(.ticketRegistrationInput(context))
    }
}

#Preview("Theater") {
    MovieSearchView(place: .theater)
        .environment(AppRouter())
}

#Preview("Home") {
    MovieSearchView(place: .home)
        .environment(AppRouter())
}
