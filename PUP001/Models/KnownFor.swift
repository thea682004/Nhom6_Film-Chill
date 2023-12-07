//
//  KnownFor.swift
//  PUP001
//
//  Created by chuottp on 13/06/2023.
//

import Foundation

struct KnownForActor: Hashable {
    let id: Int?
    let name: String?
    let poster_path: String?
    var checkType: checkTypeActor = .movie
}
