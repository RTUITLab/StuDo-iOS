//
//  CardTransitionAnimator.swift
//  StuDo
//
//  Created by Andrew on 5/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class CardTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.2
    var isPresenting: Bool = true

    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        let adView = isPresenting ? toView : fromView
        let parentView = isPresenting ? fromView : toView
        
        let adVC = isPresenting ? toVC as? AdViewController : fromVC as? AdViewController
        
        let parentViewSnapshot = parentView.snapshotView(afterScreenUpdates: true)
        if let snapshot = parentViewSnapshot {
            container.addSubview(snapshot)
            snapshot.layer.masksToBounds = true
            container.bringSubviewToFront(adView)
        }
        
        parentView.removeFromSuperview()
        if isPresenting {
            container.addSubview(adView)
        }
        
        let finalOffsetY: CGFloat = isPresenting ? 300 : 0
        let finalAlpha: CGFloat = isPresenting ? adVC?.calculateShadowViewAlpha(forOffsetY: finalOffsetY) ?? 0 : 0
        
        adVC?.isBeingTransitioned = true
        UIView.animate(withDuration: duration, animations: {
            adVC?.containerView.contentOffset.y = finalOffsetY
            adVC?.shadowView.alpha = finalAlpha
            
        }) { (success) in
            adVC?.isBeingTransitioned = false
            if !self.isPresenting {
                container.addSubview(parentView)
            }
            transitionContext.completeTransition(success)
        }
    }
    
    
}
