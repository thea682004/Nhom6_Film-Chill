//
//  MovieRealm.swift
//  PUP001
//
//  Created by chuottp on 15/06/2023.
//

import Foundation
import RealmSwift

class MovieRealm: Object {
    @Persisted var id: Int?
    @Persisted var image: String?
    @Persisted var name: String?
    @Persisted var checkType: Bool = false // false is movie

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id: Int, image: String?, name: String?, checkType: Bool = false) {
        self.init()
        self.id = id
        self.image = image
        self.name = name
        self.checkType = checkType
    }
}
