//
//  TMDBClient.swift
//  Still
//
//  Created by 정홍섭 on 8/20/26.
//

import Foundation

final class TMDBClient {
    private let apiKey = TMDB_API_KEY
    
    func request<T: Decodable>(
        _ endpoint: TMDBEndpoint
    ) async throws -> T {
        guard let url = endpoint.url(apiKey: apiKey) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }
}
