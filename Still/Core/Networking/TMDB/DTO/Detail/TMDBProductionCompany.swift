//
//  TMDBProductionCompany.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

struct TMDBProductionCompany: Decodable {
    let id: Int
    let logoPath: String
    let name: String
    let originCountry: String
}
