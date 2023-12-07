//
//  FavoriteRealm.swift
//  PUP001
//
//  Created by chuottp on 12/10/2023.
//
import Foundation
import RealmSwift
import Realm

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    //MARK: - Get All Movie
    func getAllObjects<T: Object>(_ objectType: T.Type) -> Array<T> {
        return Array(realm.objects(objectType))
    }
    
    // MARK: - Create
    func create(object: Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error creating object: \(error)")
        }
    }
    
    // MARK: - Read
    func getObjects<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    func getById<T: Object>(ofType type: T.Type, id: Int) -> T? {
        do {
            let realm = try Realm()
            let result = realm.objects(type.self).filter("id == %@", id).first
            return result
        } catch {
            return nil
        }
    }
    
    func getObject<T: Object, KeyType>(ofType type: T.Type, forPrimaryKey key: KeyType) -> T? {
        return realm.object(ofType: type, forPrimaryKey: key)
    }
    
    // MARK: - Update
    func update(object: Object, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary {
                    if let value = value {
                        object.setValue(value, forKey: key)
                    }
                }
            }
        } catch {
            print("Error updating object: \(error)")
        }
    }
    
    // MARK: - Delete
    func delete(object: Object) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting object: \(error)")
        }
    }
    
    func getByUUID<T: Object>(ofType type: T.Type, uuid: String) -> T? {
        do {
            let realm = try Realm()
            let result = realm.objects(type.self).filter("uuid == %@", uuid).first
            return result
        } catch {
            return nil
        }
    }
    
    func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error deleting all objects: \(error)")
        }
    }
}

