//
//  TMDBCollection.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

struct TMDBCollection: Decodable {
    let id: Int
    let name: String
    let posterPath: String
    let backdropPath: String
}
