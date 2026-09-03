//
//  TMDBDetailService.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

final class TMDBDetailService {
    private let client = TMDBClient()
    
    func detailMovie(id: Int) async throws -> TMDBMovieDetailResponse {
       try await client.request(
            .detailMovie(id: id)
        )
    }
}
