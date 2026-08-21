//
//  TMDBMovieSearchResponse.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

struct TMDBMovieSearchResponse: Decodable {
    let page: Int
    let results: [TMDBMovieSearchResult]
    let totalPages: Int
    let totalResults: Int
}
