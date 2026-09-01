//
//  TMDBImage.swift
//  Still
//
//  Created by 정홍섭 on 8/24/26.
//

import Foundation

struct TMDBImage: Decodable {
    let aspectRatio: Double
    let height: Int
    let iso6391: String?
    let filePath: String
    let voteAverage: Double
    let voteCount: Int
    let width: Int
}
