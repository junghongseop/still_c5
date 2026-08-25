//
//  TMDBEndpoint.swift
//  Still
//
//  Created by 정홍섭 on 8/20/26.
//

import Foundation

enum TMDBEndpoint {
    case searchMovie(query: String)
    case detailMovie(id: Int)
    case movieWatchProviders(id: Int)
    case movieImage(id: Int)
    
    private var baseURL: String {
        "https://api.themoviedb.org/3"
    }
    
    func url(apiKey: String) -> URL? {
        switch self {
        case .searchMovie(let query):
            var components = URLComponents(string: "\(baseURL)/search/movie")
            
            components?.queryItems = [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "language", value: "ko-KR"),
                URLQueryItem(name: "include_adult", value: "true")
            ]
            
            return components?.url
            
        case .detailMovie(let id):
            var components = URLComponents(string: "\(baseURL)/movie/\(id)")
            
            components?.queryItems = [
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "language", value: "ko-KR"),
            ]
            
            return components?.url
            
        case .movieWatchProviders(let id):
            let components = URLComponents(string: "\(baseURL)/movie/\(id)/watch/providers")
            
            return components?.url
            
        case .movieImage(let id):
            let components = URLComponents(string: "\(baseURL)/movie/\(id)/images")
            
            return components?.url
        }
    }
}
