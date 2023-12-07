//
//  Chart.swift
//  PUP001
//
//  Created by chuottp on 16/06/2023.
//

import Foundation
import RealmSwift

public class ItemChart {
    var id: Int?
    var name: String?
    var date: Date?
    var time: Int?
    var poster: String?
    var genres = [String]()
    var type: Bool?
    var title: String?
    var description: String?
    
    init(id: Int? = nil, name: String? = nil, date: Date? = nil, time: Int? = nil, poster: String? = nil, genres: [String] = [], type: Bool? = nil, title: String? = nil, description: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.time = time
        self.poster = poster
        self.type = type
        self.title = title
        self.description = description
        self.genres = genres
    }
}
