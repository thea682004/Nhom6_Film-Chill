//
//  HistoryTextRealm.swift
//  PUP001
//
//  Created by chuottp on 26/05/2023.
//

import Foundation
import RealmSwift
import Realm

class RecentlyText: Object {
    
    @Persisted var text: String?
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
    //MARK: Actions
}

extension RecentlyText {
    
    static func delete(model: [RecentlyText]) {
        let realm = try! Realm()
        try! realm.write({
            realm.delete(model)
        })
    }
    
    static func add(text: String) {
        let realm = try! Realm()
        let item = RecentlyText(text: text)
        try! realm.write {
            realm.add(item)
        }
    }
    
    static func getAll() -> [RecentlyText] {
        let realm = try! Realm()
        return Array(realm.objects(RecentlyText.self))
    }
}

