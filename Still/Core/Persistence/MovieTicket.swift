//
//  MovieTicket.swift
//  Still
//

import Foundation
import SwiftData

@Model
final class MovieTicket {
    @Attribute(.unique) var id: UUID

    var movieID: Int
    var movieTitle: String
    var posterPath: String?
    var watchedDate: Date
    var placeRawValue: String
    var theater: String
    var seat: String
    var platform: String

    var rating: Double
    var tasteFitRawValue: String
    var note: String
    var storyAnswerRawValue: String?
    var actingAnswerRawValue: String?
    var directingAnswerRawValue: String?
    var visualsAnswerRawValue: String?
    var musicAnswerRawValue: String?
    var moodAnswerRawValue: String?

    var backdropIndex: Int
    var backdropPath: String
    @Attribute(.externalStorage) var backdropImageData: Data
    @Attribute(.externalStorage) var logoImageData: Data?
    var logoVerticalCenterRatio: Double

    init(
        id: UUID = UUID(),
        movieID: Int,
        movieTitle: String,
        posterPath: String?,
        watchedDate: Date,
        place: WatchingPlace,
        theater: String,
        seat: String,
        platform: String,
        rating: Double,
        tasteFit: TasteFitOption,
        note: String,
        storyAnswer: MovieReviewQuestionAnswer?,
        actingAnswer: MovieReviewQuestionAnswer?,
        directingAnswer: MovieReviewQuestionAnswer?,
        visualsAnswer: MovieReviewQuestionAnswer?,
        musicAnswer: MovieReviewQuestionAnswer?,
        moodAnswer: MovieReviewQuestionAnswer?,
        backdropIndex: Int,
        backdropPath: String,
        backdropImageData: Data,
        logoImageData: Data?,
        logoVerticalCenterRatio: Double
    ) {
        self.id = id
        self.movieID = movieID
        self.movieTitle = movieTitle
        self.posterPath = posterPath
        self.watchedDate = watchedDate
        placeRawValue = place.rawValue
        self.theater = theater
        self.seat = seat
        self.platform = platform
        self.rating = rating
        tasteFitRawValue = tasteFit.rawValue
        self.note = note
        storyAnswerRawValue = storyAnswer?.rawValue
        actingAnswerRawValue = actingAnswer?.rawValue
        directingAnswerRawValue = directingAnswer?.rawValue
        visualsAnswerRawValue = visualsAnswer?.rawValue
        musicAnswerRawValue = musicAnswer?.rawValue
        moodAnswerRawValue = moodAnswer?.rawValue
        self.backdropIndex = backdropIndex
        self.backdropPath = backdropPath
        self.backdropImageData = backdropImageData
        self.logoImageData = logoImageData
        self.logoVerticalCenterRatio = logoVerticalCenterRatio
    }

    var place: WatchingPlace? {
        WatchingPlace(rawValue: placeRawValue)
    }
}
