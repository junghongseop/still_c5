//
//  TMDBMovieDetailResponse.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

struct TMDBMovieDetailResponse: Decodable {
    let adult: Bool
    let backdropPath: String?
    let belongsToCollection: TMDBCollection?
    let budget: Int
    let genres: [TMDBGenre]
    let homepage: String?
    let id: Int
    let imdbId: String?
    let originCountry: [String]
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let productionCompanies: [TMDBProductionCompany]
    let productionCountries: [TMDBProductionCountry]
    let releaseDate: String
    let revenue: Int
    let runtime: Int?
    let spokenLanguages: [TMDBSpokenLanguage]
    let status: String
    let tagline: String?
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
}
