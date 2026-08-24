//
//  TMDBWatchProviderService.swift
//  Still
//
//  Created by 정홍섭 on 8/24/26.
//

import Foundation

final class TMDBWatchProviderService {
    private let client = TMDBClient()
    
    func watchProviders(id: Int) async throws -> [TMDBWatchProvider] {
        let response: TMDBWatchProviderResponse = try await client.request(
            .movieWatchProviders(id: id)
        )
        
        return response.results["KR"]?.flatrate ?? []
    }
}
