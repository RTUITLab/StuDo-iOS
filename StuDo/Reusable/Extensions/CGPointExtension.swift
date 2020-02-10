//
//  CGPointExtension.swift
//  StuDo
//
//  Created by Andrew on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension CGPoint {
    mutating func offset(x: CGFloat, y: CGFloat = 0) {
        let prevVal = self
        self = CGPoint(x: prevVal.x + x, y: prevVal.y + y)
    }
    
    mutating func offset(y: CGFloat = 0) {
        offset(x: 0, y: y)
    }
}
