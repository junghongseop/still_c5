//
//  AppRouter.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import Foundation
import Observation

@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
    
    var homePath: [AppRoute] = []
    var collectionPath: [AppRoute] = []
    var recommendationPath: [AppRoute] = []
    var myPath: [AppRoute] = []
    var ticketRegistrationPath: [AppRoute] = []
    
    //    var sheet: AppSheet?
    
    func push(_ route: AppRoute) {
        switch selectedTab {
        case .home:
            homePath.append(route)
            
        case .collection:
            collectionPath.append(route)
            
        case .recommendation:
            recommendationPath.append(route)
            
        case .my:
            myPath.append(route)
            
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
            
        case .my:
            guard !myPath.isEmpty else { return }
            myPath.removeLast()
            
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
            
        case .my:
            myPath.removeAll()
            
        case .ticketRegistration:
            ticketRegistrationPath.removeAll()
        }
    }
}

enum AppTab: Hashable {
    case home
    case collection
    case recommendation
    case my
    case ticketRegistration
}

enum AppRoute: Hashable {
    case movieDetail(id: Int)
    case ticketDetail(id: UUID)
}
