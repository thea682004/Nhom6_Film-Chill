//
//  TvShowDetails.swift
//  PUP001
//
//  Created by chuottp on 19/05/2023.
//

import Foundation

struct ItemTVShowDetails: Codable {
    let backdrop_path: String?
    let episode_run_time: [Int]?
    let first_air_date: String?
    let genres: [Genres]?
    let homepage: String?
    let id: Int?
    let last_air_date: String?
    let last_episode_to_air: LastEpisode?
    let name: String?
    let number_of_episodes: Int?
    let number_of_seasons: Int?
    let overview: String?
    let popularity: Double?
    let poster_path: String?
    let seasons: [Season]?
    let status: String?
    let tagline: String?
    let type: String?
    let vote_average: Double?
    let vote_count: Int?
    let videos: VideoTVDetail?
    let credits: CreditTVDetail?
    let recommendations: RecomdationTVDetail?
}

struct RecomdationTVDetail: Codable {
    let page: Int?
    let results: [ResultRecommendationTVDetail]?
    let total_pages: Int?
    let total_results: Int?
}

struct ResultRecommendationTVDetail: Codable {
    let adult: Bool?
    let backdrop_path: String?
    let id: Int?
    let name: String?
    let original_language: String?
    let original_name: String?
    let overview: String?
    let poster_path: String?
    let media_type: String?
    let genre_ids: [Int]?
    let popularity: Double?
    let first_air_date: String?
    let vote_average: Double?
    let vote_count: Int?
}

struct CreditTVDetail: Codable {
    let cast: [ItemActors]
}

struct VideoTVDetail: Codable {
    let results: [ResultTVDetail]?
}

struct ResultTVDetail: Codable {
    let name: String?
    let key: String?
    let site: String?
    let size: Int?
    let type: String?
    let official: Bool?
    let published_at: String?
    let id: String?
}

struct Season: Codable {
    let air_date: String?
    let episode_count: Int?
    let id: Int?
    let name: String?
    let overview: String?
    let poster_path: String?
    let season_number: Int?
}

struct LastEpisode: Codable {
    let id: Int?
    let name: String?
    let overview: String?
    let vote_average: Double?
    let vote_count: Int?
    let air_date: String?
    let episode_number: Int?
    let production_code: String?
    let runtime: Int?
    let season_number: Int?
    let show_id: Int?
    let still_path: String?
}

struct GenreTVDetails: Codable {
    let id: Int?
    let name: String?
}
