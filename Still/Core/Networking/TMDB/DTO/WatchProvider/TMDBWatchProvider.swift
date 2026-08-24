//
//  TMDBWatchProvider.swift
//  Still
//
//  Created by 정홍섭 on 8/24/26.
//

import Foundation

struct TMDBWatchProvider: Decodable {
    let logoPath: String
    let providerId: Int
    let providerName: String
    let displayPriority: Int
}
