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




enum PersistentStoreNotification: String, NotificationName {
    case languageDidChange
    case themeDidChange
}




class PersistentStore: NSObject {
    static var shared = PersistentStore()
    
    private let currentUserKey = "ru.rtuitlab.studo.user"
    var user: User! {
        didSet {
            UserDefaults.standard.set(object: user?.userDefaultsFormat, forKey: currentUserKey)
        }
    }
    
    
    fileprivate let pofilePictureGradientIndexKey = "ru.rtuitlab.studo.profilePictureGradientIndex"
    fileprivate let shouldRestoreProfilePictureKey = "ru.rtuitlab.studo.shouldRestoreProfilePicture"
    var profilePictureGradientIndex: Int? {
        didSet {
            let defaults = UserDefaults.standard
            
            if let profilePictureIndex = profilePictureGradientIndex {
                defaults.set(profilePictureIndex, forKey: pofilePictureGradientIndexKey)
                defaults.set(true, forKey: shouldRestoreProfilePictureKey)
            } else {
                defaults.set(false, forKey: shouldRestoreProfilePictureKey)
            }
        }
    }
    
    
    private let currentLanguageKey = "ru.rtuitlab.studo.currentLanguage"
    var currentLanguage: StuDoAvailableLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: currentLanguageKey)
            NotificationCenter.default.post(name: PersistentStoreNotification.languageDidChange.name, object: nil)
        }
    }
    
    
    
    private let currentThemeKey = "ru.rtuitlab.studo.currentTheme"
    var currentTheme: StuDoAvailableThemes {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: currentThemeKey)
            NotificationCenter.default.post(name: PersistentStoreNotification.themeDidChange.name, object: nil)
            
            UINavigationBar.appearance().tintColor = .globalTintColor
        }
    }
    
    
    
    
    
    
    override init() {
        
        
        let defaults = UserDefaults.standard
        
        
        if let userDictionary = defaults.object([String: String].self, with: currentUserKey), let user = User(fromUserDefaultsDictionary: userDictionary) {
            self.user = user
        } else {
            self.user = nil
        }
        
        
        if defaults.bool(forKey: shouldRestoreProfilePictureKey) {
            profilePictureGradientIndex = defaults.integer(forKey: pofilePictureGradientIndexKey)
        } else {
            profilePictureGradientIndex = nil
        }
        
        if let storedLanguage = defaults.string(forKey: currentLanguageKey) {
            currentLanguage = StuDoAvailableLanguage(rawValue: storedLanguage)!
        } else {
            var language: StuDoAvailableLanguage = .English
            if let locale = Locale.preferredLanguages.first {
                if locale.contains("ru") {
                    language = .Russian
                } else if locale.contains("de") {
                    language = .German
                }
            }
            currentLanguage = language
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: currentLanguageKey)
        }
        
        
        if let storedTheme = defaults.string(forKey: currentThemeKey), let theme = StuDoAvailableThemes(rawValue: storedTheme) {
            currentTheme = theme
        } else {
            currentTheme = .blue
        }
        
    }
    
    
    
    
    
    
    
    
    
    static func cleanUserRelatedPersistentData() {
        
        APIClient.deleteTokens()
        PersistentStore.shared.user = nil
        PersistentStore.shared.profilePictureGradientIndex = nil
        UserGradient.cleanSavedCurrent()
        
    }
    
    
    
}

