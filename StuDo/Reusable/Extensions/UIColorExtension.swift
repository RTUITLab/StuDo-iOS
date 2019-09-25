//
//  UIColorExtension.swift
//  StuDo
//
//  Created by Andrew on 9/1/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension UIColor {
    
    
    static var globalTintColor: UIColor {
        return tintColor(for: PersistentStore.shared.currentTheme)
    }
    
    
    static func tintColor(for theme: StuDoAvailableThemes) -> UIColor {
        switch theme {
        case .red:
            return UIColor(red:0.998, green:0.058, blue:0.098, alpha:1.000)
        case .orange:
            return UIColor(red:1.000, green:0.563, blue:0.000, alpha:1.000)
        case .yellow:
            return UIColor(red:0.999, green:0.795, blue:0.015, alpha:1.000)
        case .green:
            return UIColor(red:0.009, green:0.870, blue:0.317, alpha:1.000)
        case .tealBlue:
            return UIColor(red:0.101, green:0.791, blue:1.000, alpha:1.000)
        case .blue:
            return UIColor(red:0.000, green:0.473, blue:0.999, alpha:1.000)
        case .purple:
            return UIColor(red:0.355, green:0.319, blue:0.870, alpha:1.000)
        case .pink:
            return UIColor(red:0.998, green:0.008, blue:0.311, alpha:1.000)
        }
    }
        
}
