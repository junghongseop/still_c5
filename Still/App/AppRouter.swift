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
    var settingPath: [AppRoute] = []
    var ticketRegistrationPath: [AppRoute] = []
    
    func push(_ route: AppRoute) {
        switch selectedTab {
        case .home:
            homePath.append(route)
            
        case .collection:
            collectionPath.append(route)
            
        case .recommendation:
            recommendationPath.append(route)
            
        case .setting:
            settingPath.append(route)
            
        case .ticketRegistration:
            ticketRegistrationPath.append(route)
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
            
        case .setting:
            guard !settingPath.isEmpty else { return }
            settingPath.removeLast()
            
        case .ticketRegistration:
            guard !ticketRegistrationPath.isEmpty else { return }
            ticketRegistrationPath.removeLast()
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
            
        case .setting:
            settingPath.removeAll()
            
        case .ticketRegistration:
            ticketRegistrationPath.removeAll()
        }
    }

    @ViewBuilder
    func destination(for route: AppRoute) -> some View {
        switch route {
        case .movieDetail:
            EmptyView()

        case .ticketDetail:
            CollectionDetailView()
        }
    }
}

enum AppTab: Hashable {
    case home
    case collection
    case recommendation
    case setting
    case ticketRegistration
    
    var systemImage: String {
        switch self {
        case .home:
            "house.fill"
            
        case .collection:
            "film.stack.fill"
            
        case .recommendation:
            "sparkles"
            
        case .setting:
            "gearshape.fill"
            
        case .ticketRegistration:
            "plus"
        }
    }
}

enum AppRoute: Hashable {
    case movieDetail(id: Int)
    case ticketDetail(id: UUID)
}
