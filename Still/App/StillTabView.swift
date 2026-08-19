//
//  StillTabView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI

struct StillTabView: View {
    var body: some View {
        TabView {
            Tab {
                HomeView()
            } label: {
                Image(systemName: "house.fill")
            }

            Tab {
                CollectionView()
            } label: {
                Image(systemName: "film.stack.fill")
            }

            Tab {
                RecommendationView()
            } label: {
                Image(systemName: "sparkles")
            }

            Tab {
                MyView()
            } label: {
                Image(systemName: "person.fill")
            }

            Tab(role: .search) {
                TicketRegistrationView()
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    StillTabView()
}
