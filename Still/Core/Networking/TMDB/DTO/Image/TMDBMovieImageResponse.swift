//
//  TMDBMovieImageResponse.swift
//  Still
//
//  Created by 정홍섭 on 8/24/26.
//

import Foundation

struct TMDBMovieImageResponse: Decodable {
    let backdrops: [TMDBImage]
    let id: Int
    let logos: [TMDBImage]
    let posters: [TMDBImage]
}
