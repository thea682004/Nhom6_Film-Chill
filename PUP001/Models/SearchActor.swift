//
//  SearchActor.swift
//  PUP001
//
//  Created by chuottp on 26/05/2023.
//

import Foundation

struct ResponseSearchActor: Codable {
    let page: Int?
    let results: [ItemSearchActor]?
    let total_pages: Int?
    let total_results: Int?
}

struct ItemSearchActor: Codable {
    let id: Int?
    let name: String?
    let profile_path: String?
}
