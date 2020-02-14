//
//  TextFormatter.swift
//  StuDo
//
//  Created by Andrew on 8/31/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import MarkdownKit

class TextFormatter {
    
    static func mediumString(from date: Date) -> String {
        
        let currentLanguage = PersistentStore.shared.currentLanguage
        let currentLocale = Localizer.currentLocale
        
        var dateFormat = "MMM d, H:mm"
        if currentLanguage == .English {
            dateFormat = "MMM d, h:mm a"
        }
        
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: date)
    }
    
    static func parseMarkdownString(_ string: String, textStyle: UIFont.TextStyle = .body, fontWeight: UIFont.Weight = .regular) -> NSAttributedString {
        parseMarkdownString(NSAttributedString(string: string), textStyle: textStyle, fontWeight: fontWeight)
    }
    
    static func parseMarkdownString(_ string: NSAttributedString, textStyle: UIFont.TextStyle = .body, fontWeight: UIFont.Weight = .regular) -> NSAttributedString {
        
        let markdownParser = MarkdownParser(font: UIFont.preferredFont(for: textStyle, weight: fontWeight), color: .label)
        
        markdownParser.enabledElements = .all
        markdownParser.bold.font = UIFont.preferredFont(for: textStyle, weight: .medium)
        markdownParser.italic.font = UIFont.preferredFont(forTextStyle: textStyle).italic()
        markdownParser.header.font = UIFont.preferredFont(for: .title3, weight: .medium)
        markdownParser.quote.font = UIFont.preferredFont(forTextStyle: textStyle).italic()
        markdownParser.quote.color = .lightGray
        markdownParser.link.color = .globalTintColor
        
        return markdownParser.parse(string)
    }
}
