//
//  MovieDetails.swift
//  PUP001
//
//  Created by chuottp on 15/05/2023.
//

import Foundation

struct ItemMoviesDetail: Codable {
    let adult: Bool?
    let backdropPath: String?
    let belongs_to_collection: BelongsToCollection?
    let id: Int?
    let credits: Credits
    let overview: String?
    let title: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let voteCount: Int?
    let videos: Video
    let recommendations: Recommendation?
    let genre: [Genres]?
    let runtime: Int?
    let profile_path: String?
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case id
        case overview, title
        case credits
        case belongs_to_collection
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case videos
        case recommendations
        case genre = "genres"
        case runtime
        case profile_path
    }
}

struct Recommendation: Codable {
    let page: Int?
    let results: [ResultRecommendation]
}

struct ResultRecommendation: Codable {
    let adult: Bool?
    let backdrop_path: String?
    let id: Int?
    let title: String?
    let original_language: String?
    let original_title: String?
    let overview: String?
    let poster_path: String?
    let media_type: String?
    let genre_ids: [Int]
    let popularity: Double?
    let release_date: String?
    let video: Bool?
    let vote_average: Double?
    let vote_count: Int?
}

struct Video: Codable {
    let results: [Result]
}

struct Result: Codable {
    let iso_639_1: String?
    let iso_3166_1: String?
    let name: String?
    let key: String?
    let site: String?
    let size: Int?
    let type: String?
    let official: Bool?
    let published_at: String?
    let id: String?
}

struct BelongsToCollection: Codable {
    let id: Int?
    let name: String?
    let poster_path: String?
    let backdrop_path: String?
}

struct Genres: Codable {
    let id: Int?
    let name: String?
}

struct Credits: Codable {
    let cast: [ItemActors]
}


