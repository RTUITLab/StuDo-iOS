//
//  UITableViewExtension.swift
//  StuDo
//
//  Created by Andrew on 8/9/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

extension UITableView {

    func centerTableView() {
        if contentSize.height < bounds.size.height {
            
            let yOffset = floor(bounds.size.height - contentSize.height) / 2
            contentOffset = CGPoint(x: 0, y: -yOffset)
        }
    }
    

}
