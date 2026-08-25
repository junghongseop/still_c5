//
//  TMDBImageService.swift
//  Still
//
//  Created by 정홍섭 on 8/24/26.
//

import Foundation

final class TMDBImageService {
    private let client = TMDBClient()
    
    func movieImage(id: Int) async throws -> TMDBMovieImageResponse {
        try await client.request(
            .movieImage(id: id)
        )
    }
}
