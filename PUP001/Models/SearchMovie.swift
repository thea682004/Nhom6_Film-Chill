//
//  SearchMovie.swift
//  PUP001
//
//  Created by chuottp on 25/05/2023.
//

import Foundation

struct ResponseSearchMovie: Codable {
    let page: Int?
    let results: [ItemSearchMovie]?
    let total_pages: Int?
    let total_results: Int?
}

struct ItemSearchMovie: Codable {
    let id: Int?
    let overview: String?
    let popularity: Double?
    let release_date: String?
    let poster_path: String?
    let title: String?
    let video: Bool?
    let vote_average: Double?
    let vote_count: Int?
}
