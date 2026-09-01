//
//  StillTabView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftData
import SwiftUI

struct StillTabView: View {
    @Environment(AppRouter.self) private var router
    
    private var tabSelection: Binding<AppTab> {
        Binding(
            get: {
                router.selectedTab
            },
            set: { newTab in
                guard newTab == .ticketRegistration else {
                    router.selectedTab = newTab
                    return
                }
                
                let currentTab = router.selectedTab
                
                Task { @MainActor in
                    await Task.yield()
                    router.push(.ticketRegistration, on: currentTab)
                }
            }
        )
    }
    
    private func navigationTab<Content: View>(
        _ tab: AppTab,
        path: Binding<[AppRoute]>,
        role: TabRole? = nil,
        @ViewBuilder content: () -> Content
    ) -> some TabContent<AppTab> {
        Tab(value: tab, role: role) {
            NavigationStack(path: path) {
                content()
                    .navigationDestination(for: AppRoute.self) { route in
                        router.destination(for: route)
                    }
            }
        } label: {
            Image(systemName: tab.systemImage)
        }
    }
    
    var body: some View {
        @Bindable var router = router
        
        TabView(selection: tabSelection) {
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
            
            Tab(value: .ticketRegistration, role: .search) {
                EmptyView()
            } label: {
                Image(systemName: "plus")
            }
        }
        .tint(StillColors.Accent.primary)
    }
}

#Preview {
    StillTabView()
        .environment(AppRouter())
        .modelContainer(for: MovieTicket.self, inMemory: true)
}
