//
//  StillTabView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI

struct StillTabView: View {
    @Environment(AppRouter.self) private var router
    
    private func navigationTab<Content: View>(
        _ tab: AppTab,
        path: Binding<[AppRoute]>,
        role: TabRole? = nil,
        @ViewBuilder content: () -> Content
    ) -> some TabContent<AppTab> {
        Tab(value: tab, role: role) {
            NavigationStack(path: path) {
                content()
            }
        } label: {
            Image(systemName: tab.systemImage)
        }
    }
    
    var body: some View {
        @Bindable var router = router
        
        TabView(selection: $router.selectedTab) {
            navigationTab(
                .home,
                path: $router.homePath
            ) {
                HomeView()
            }
            
            navigationTab(
                .collection,
                path: $router.collectionPath
            ) {
                CollectionView()
            }
            
            navigationTab(
                .recommendation,
                path: $router.recommendationPath
            ) {
                RecommendationView()
            }
            
            navigationTab(
                .my,
                path: $router.myPath
            ) {
                MyView()
            }
            
            navigationTab(
                .ticketRegistration,
                path: $router.ticketRegistrationPath,
                role: .search
            ) {
                TicketRegistrationView()
            }
        }
        .tint(StillColors.Accent.primary)
    }
}

#Preview {
    StillTabView()
        .environment(AppRouter())
}
