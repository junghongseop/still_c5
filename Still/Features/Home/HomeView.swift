//
//  HomeView.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Button("검색") {
            Task {
                do {
                    let service = TMDBSearchService()
                    let movies = try await service.searchMovie(title: "스파이더맨")
                    
                    for movie in movies {
                        Log.debug(movie.id, movie.title)
                    }
                } catch {
                    Log.debug(error)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
