//
//  TMDBSearchService.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

final class TMDBSearchService {
    private let client = TMDBClient()
    
    func searchMovie(title: String) async throws -> [TMDBMovieSearchResult] {
        let response: TMDBMovieSearchResponse = try await client.request(
            .searchMovie(query: title)
        )
        
        return response.results
    }
}
