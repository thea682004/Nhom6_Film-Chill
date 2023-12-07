//
//  Episode.swift
//  PUP001
//
//  Created by chuottp on 31/05/2023.
//

import Foundation

struct ResponseEpisode: Codable {
    let air_date: String?
    let episodes: [ItemEpisode]
    let name: String?
    let overview: String?
    let id: Int?
    let poster_path: String?
    let season_number: Int?
}

struct ItemEpisode: Codable {
    let air_date: String?
    let episode_number: Int?
    let id: Int?
    let name: String?
    let overview: String?
    let runtime: Int?
    let season_number: Int?
    let show_id: Int?
    let still_path: String?
    let vote_average: Double?
    let vote_count: Int?
}

