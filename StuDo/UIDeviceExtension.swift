//
//  UIDeviceExtension.swift
//  StuDo
//
//  Created by Andrew on 5/31/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension UIDevice {
    static func phoneHasRoundedCorners() -> Bool {
        if UIDevice().userInterfaceIdiom != .phone {
            fatalError("Fatal error: phoneHasRoundedCorners() implemented only for phones")
        }
        
        switch UIScreen.main.nativeBounds.height {
        case 1136, 1334, 1920, 2208:
            return false
        case 2436, 2688, 1792:
            return true
        default:
            return false
        }
    }
}
