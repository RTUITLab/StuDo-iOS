//
//  TextFormatter.swift
//  StuDo
//
//  Created by Andrew on 8/31/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class TextFormatter {
    static func additionalInfoAttributedString(for ad: Ad, style: UIFont.TextStyle = .caption2) -> NSAttributedString {
        
        var creator: String!
        if let userName = ad.userName {
            creator = userName
        } else if let organizationName = ad.organizationName {
            creator = organizationName
        } else if let user = ad.user {
            creator = user.firstName + " " + user.lastName
        }
        #warning("When organization handling is implemented, get organization's name")
        
        let currentLanguage = PersistentStore.shared.currentLanguage
        var currentLocale = Locale.current
        if currentLanguage == .English {
            currentLocale = Locale(identifier: "en")
        } else if currentLanguage == .Russian {
            currentLocale = Locale(identifier: "ru")
        }
        
        var dateFormat = "MMM d, H:mm"
        if currentLanguage == .English {
            dateFormat = "MMM d, h:mm a"
        }
        
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = dateFormat
        
        
        
        
        let timeString = formatter.string(from: ad.beginTime)
        
        
        let attributedString = NSMutableAttributedString(string: timeString, attributes: [
            .font: UIFont.preferredFont(forTextStyle: style)
            ])
        attributedString.append(NSAttributedString(string: " ‧ ", attributes: [
            NSAttributedString.Key.font: UIFont.preferredFont(for: style, weight: .bold)
            ]))
        attributedString.append(NSAttributedString(string: creator, attributes: [
            .font : UIFont.preferredFont(for: style, weight: .semibold)
            ]))
        
        return attributedString
    }
}
