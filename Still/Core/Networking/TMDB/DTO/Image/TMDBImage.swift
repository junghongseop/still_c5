//
//  TMDBImage.swift
//  Still
//
//  Created by 정홍섭 on 8/24/26.
//

import Foundation

struct TMDBImage: Decodable {
    let aspectRatio: Int
    let height: Int
    let iso6391: String
    let filePath: String
    let voteAverage: Int
    let voteCount: Int
    let with: Int
}
