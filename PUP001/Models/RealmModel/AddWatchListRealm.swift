//
//  AddWatchListRealm.swift
//  PUP001
//
//  Created by chuottp on 16/06/2023.
//

import Foundation
import Realm
import RealmSwift

class AddWatchListRealm: Object {
    @Persisted var uuid: String?
    @Persisted var id: Int?
    @Persisted var name: String?
    @Persisted var date: String?
    @Persisted var time: Int?
    @Persisted var poster: String?
    @Persisted var genres = List<String>()
    @Persisted var checkType: Bool = false
    @Persisted var title: String?
    @Persisted var descriptionAdd: String?
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    convenience init(id: Int? = nil, name: String? = nil, date: String? = nil, time: Int? = nil, poster: String? = nil, genres: [String]?, checkType: Bool, title: String? = nil, descriptionAdd: String? = nil) {
        self.init()
        self.uuid = UUID().uuidString
        self.id = id
        self.name = name
        self.date = date
        self.time = time
        self.poster = poster
        self.checkType = checkType
        self.title = title
        self.descriptionAdd = descriptionAdd
        genres?.forEach({ string in
            self.genres.append(string)
        })
    }
}

