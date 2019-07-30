//
//  CardAnimatedTransitioning.swift
//  Card transform
//
//  Created by Andrew on 7/30/19.
//  Copyright © 2019 Andrew Allen. All rights reserved.
//

import UIKit

class CardAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    static let defaultDuration: TimeInterval = 0.33
    
    var duration: TimeInterval = CardAnimatedTransitioning.defaultDuration
    var isPresenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        
        let initialView = isPresenting ? fromView : toView
        let cardView = isPresenting ? toView : fromView
        let cardVC = isPresenting ? toVC as! CardViewController : fromVC as! CardViewController
        
        container.addSubview(toView)
        if isPresenting {
            if let snapshot = initialView.snapshotView(afterScreenUpdates: true) {
                container.addSubview(snapshot)
            }
        }
        
        container.bringSubviewToFront(cardView)
        
    
        let hideTranslation = CGAffineTransform(translationX: 0, y: container.frame.height)
        let initialTranslation: CGAffineTransform = isPresenting ? hideTranslation : .identity
        let finalTranslation: CGAffineTransform = isPresenting ? .identity : hideTranslation
        
        let initialAlpha: CGFloat = isPresenting ? 0 : 1
        let finalAlpha: CGFloat = isPresenting ? 1 : 0
            
        cardVC.cardView.transform = initialTranslation
        cardVC.dimView.alpha = initialAlpha
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            cardVC.cardView.transform = finalTranslation
            cardVC.dimView.alpha = finalAlpha
        }) { didComplete in
            transitionContext.completeTransition(didComplete)
        }
    }
}
