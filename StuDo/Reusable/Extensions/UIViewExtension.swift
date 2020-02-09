//
//  UIViewExtension.swift
//  StuDo
//
//  Created by Andrew on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension UIView {
    func animateVisibility(shouldHide: Bool, duration: TimeInterval = 0.2) {
        guard self.isHidden != shouldHide else { return }
        self.isHidden = false

        if shouldHide {
            self.alpha = 1
        } else {
            self.alpha = 0
        }
        
        UIView.animate(withDuration: duration, animations: {
            if shouldHide {
                self.alpha = 0
            } else {
                self.alpha = 1
            }
        }, completion: { _ in
            self.isHidden = shouldHide
        })
    }
}
