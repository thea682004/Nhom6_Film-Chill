//
//  GenresID.swift
//  PUP001
//
//  Created by chuottp on 12/06/2023.
//

import Foundation

struct GenresIDResponse: Codable {
    let page: Int?
    let results: [ItemGenresID]?
}

struct ItemGenresID: Codable {
    let genre_ids: [Int]?
    let id: Int?
    let title: String?
    let poster_path: String?
    let overview: String?
}

