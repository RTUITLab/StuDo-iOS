//
//  GlobalConstants.swift
//  StuDo
//
//  Created by Andrew on 7/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//


enum StuDoAvailableLanguage: String {
    case English = "English"
    case Russian = "Русский"
//    case German = "Deutsch"
}

extension StuDoAvailableLanguage: CaseIterable {}



enum StuDoAvailableThemes: String {
    case blue = "Blue"
    case red = "Red"
    case greed = "Green"
}

extension StuDoAvailableThemes: CaseIterable {}
