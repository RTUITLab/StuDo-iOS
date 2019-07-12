//
//  PersistentStore.swift
//  StuDo
//
//  Created by Andrew on 6/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit


extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}


let kPersistentStoreUser = "com.StuDo.user"



struct PersistentStore {
    static var shared = PersistentStore()
    
    var user: User?
    
    var isUsingFakeData = true
    
    init() {
        let defaults = UserDefaults.standard
        
        if let userDictionary = defaults.object([String: String].self, with: kPersistentStoreUser), let user = User(fromUserDefaultsDictionary: userDictionary) {
            self.user = user
        } else {
            self.user = nil
        }
    }
    
    static func save() {
        let defaults = UserDefaults.standard
        
        let shared = PersistentStore.shared

        defaults.set(object: shared.user?.userDefaultsFormat, forKey: kPersistentStoreUser)
    }
}

