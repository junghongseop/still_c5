//
//  TMDBWatchProviderResponse.swift
//  Still
//
//  Created by 정홍섭 on 8/24/26.
//

import Foundation

struct TMDBWatchProviderResponse: Decodable {
    let id: Int
    let results: [String: TMDBWatchProviderRegion]
}
