//
//  FadeAnimatedTransitioning.swift
//  StuDo
//
//  Created by Andrew on 8/7/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class FadeAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var duration: TimeInterval = 0.33
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        
        container.addSubview(toView)

        toView.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            toView.alpha = 1
        }) { _ in
            transitionContext.completeTransition(true)
        }
        
    }
}
