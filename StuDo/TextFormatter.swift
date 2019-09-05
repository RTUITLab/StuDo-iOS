//
//  TextFormatter.swift
//  StuDo
//
//  Created by Andrew on 8/31/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class TextFormatter {
    
    static func mediumString(from date: Date) -> String {
        
        let currentLanguage = PersistentStore.shared.currentLanguage
        var currentLocale = Localizer.currentLocale
        
        var dateFormat = "MMM d, H:mm"
        if currentLanguage == .English {
            dateFormat = "MMM d, h:mm a"
        }
        
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: date)
    }
    
    
    static func additionalInfoAttributedString(for ad: Ad, style: UIFont.TextStyle = .caption2) -> NSAttributedString {
        
        var creator: String!
        if let userName = ad.userName {
            creator = userName
        } else if let organizationName = ad.organizationName {
            creator = organizationName
        } else if let user = ad.user {
            creator = user.firstName + " " + user.lastName
        } else if let organization = ad.organization {
            creator = organization.name
        }
        
        let timeString = TextFormatter.mediumString(from: ad.beginTime)
        
        
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
