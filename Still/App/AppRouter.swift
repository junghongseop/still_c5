//
//  AppRouter.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
    
    var homePath: [AppRoute] = []
    var collectionPath: [AppRoute] = []
    var recommendationPath: [AppRoute] = []
    
    func push(_ route: AppRoute, on tab: AppTab? = nil) {
        let targetTab = tab ?? selectedTab
        
        switch targetTab {
        case .home:
            homePath.append(route)
            
        case .collection:
            collectionPath.append(route)
            
        case .recommendation:
            recommendationPath.append(route)
            
        case .ticketRegistration:
            break
        }
    }
    
    func pop() {
        switch selectedTab {
        case .home:
            guard !homePath.isEmpty else { return }
            homePath.removeLast()
            
        case .collection:
            guard !collectionPath.isEmpty else { return }
            collectionPath.removeLast()
            
        case .recommendation:
            guard !recommendationPath.isEmpty else { return }
            recommendationPath.removeLast()
            
        case .ticketRegistration:
            break
        }
    }
    
    func popToRoot() {
        switch selectedTab {
        case .home:
            homePath.removeAll()
            
        case .collection:
            collectionPath.removeAll()
            
        case .recommendation:
            recommendationPath.removeAll()
            
        case .ticketRegistration:
            break
        }
    }

    func showCollectionDetailAfterTicketSave(ticketID: UUID) {
        homePath.removeAll()
        recommendationPath.removeAll()
        collectionPath = [.ticketDetail(id: ticketID)]
        selectedTab = .collection
    }

    func showHomeAfterTicketFailure() {
        homePath.removeAll()
        selectedTab = .home
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .movieDetail:
            RecommendationDetailView()

        case let .ticketDetail(id):
            CollectionDetailView(id: id)
            
        case .ticketRegistration:
            TicketRegistrationView()

        case .homeMovieSearch:
            MovieSearchView(place: .home)
            
        case .theaterMovieSearch:
            MovieSearchView(place: .theater)

        case let .ticketRegistrationInput(context):
            TicketRegistrationInputView(context: context)
                .id(context)

        case let .movieReview(context):
            MovieReviewView(context: context)

        case let .ticketComplete(review):
            TicketCompleteView(review: review)
            
        case .setting:
            SettingView()
        }
    }
}

enum AppTab: Hashable {
    case home
    case collection
    case recommendation
    case ticketRegistration
    
    var systemImage: String {
        switch self {
        case .home:
            "house.fill"
            
        case .collection:
            "film.stack.fill"
            
        case .recommendation:
            "sparkles"
            
        case .ticketRegistration:
            "plus"
        }
    }
}

enum AppRoute: Hashable {
    case movieDetail(id: Int)
    case ticketDetail(id: UUID)
    case ticketRegistration
    case homeMovieSearch
    case theaterMovieSearch
    case ticketRegistrationInput(TicketRegistrationContext)
    case movieReview(context: TicketRegistrationContext)
    case ticketComplete(review: MovieReviewDraft)
    case setting
}
