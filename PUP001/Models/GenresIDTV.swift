//
//  GenresIDTV.swift
//  PUP001
//
//  Created by chuottp on 17/07/2023.
//

import Foundation

struct GenresIDTVResponse: Codable {
    let page: Int?
    let results: [ItemGenresIDTV]?
}

struct ItemGenresIDTV: Codable {
    let genre_ids: [Int]?
    let id: Int?
    let name: String?
    let poster_path: String?
    let overview: String?
}
