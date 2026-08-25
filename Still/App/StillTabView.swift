//
//  StillTabView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI

struct StillTabView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        @Bindable var router = router
        
        TabView(selection: $router.selectedTab) {
            Tab(value: AppTab.home) {
                NavigationStack(path: $router.homePath) {
                    HomeView()
                }
            } label: {
                Image(systemName: "house.fill")
            }

            Tab(value: AppTab.collection) {
                NavigationStack(path: $router.collectionPath) {
                    CollectionView()
                }
            } label: {
                Image(systemName: "film.stack.fill")
            }

            Tab(value: AppTab.recommendation) {
                NavigationStack(path: $router.recommendationPath) {
                    RecommendationView()
                }
            } label: {
                Image(systemName: "sparkles")
            }

            Tab(value: AppTab.my) {
                NavigationStack(path: $router.myPath) {
                    MyView()
                }
            } label: {
                Image(systemName: "person.fill")
            }

            Tab(value: AppTab.ticketRegistration, role: .search) {
                NavigationStack(path: $router.ticketRegistrationPath) {
                    TicketRegistrationView()
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    StillTabView()
        .environment(AppRouter())
}
