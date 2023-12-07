//
//  MovieInfo.swift
//  PUP001
//
//  Created by chuottp on 08/05/2023.
//

import Foundation
import RealmSwift

class MovieInfo: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    convenience init(name: String, type: String) {
        self.init()
        self.name = name
        self.type = type
    }
}









