//
//  TMDBMovieSearchResult.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

struct TMDBMovieSearchResult: Decodable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: String?
    let posterPath: String?
}
