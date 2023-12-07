//
//  SearchTV.swift
//  PUP001
//
//  Created by chuottp on 26/05/2023.
//

import Foundation

struct ResponseSearchTV: Codable {
    let page: Int?
    let results: [ItemSearchTV]?
    let total_pages: Int?
    let total_results: Int?
}

struct ItemSearchTV: Codable {
    let id: Int?
    let name: String?
    let poster_path: String?
    let vote_average: Double?
}
