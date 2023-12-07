//
//  Genre.swift
//  PUP001
//
//  Created by chuottp on 08/05/2023.
//

import Foundation

struct GenresResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable {
    let id: Int
    let name: String
}
