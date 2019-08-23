//
//  Localizer.swift
//  StuDo
//
//  Created by Andrew on 8/23/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

enum LozalizerString: String {
    
    case feedTitleMyAds
    case feedTitleAllAds
    
    case navigationMenuAllAds
    case navigationMenuMyAds
    
}

class Localizer: NSObject {
    
    private static func getLocalizedStrings(for: StuDoAvailableLanguage) -> [String: String] {
        
        var languageName = "English"
        switch PersistentStore.shared.currentLanguage {
        case .Russian:
            languageName = "Russian"
        default:
            break
        }
        
        // TODO: will saving the plist in memory increase the performance?
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "\(languageName)Strings", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
        }
        
        return nsDictionary as! [String: String]
    }
    
    
    static func string(for text: LozalizerString) -> String {
        let plist = getLocalizedStrings(for: PersistentStore.shared.currentLanguage)
        let keyString = text.rawValue
        return plist[keyString]!
    }
    
}
