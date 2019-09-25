//
//  SlideUpTransition.swift
//  StuDo
//
//  Created by Andrew on 9/2/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit


protocol DimmableController {
    var dimView: UIView! { get set }
    var contentView: UIView! { get set }
}

class SlideUpTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.5
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
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        if isPresenting {
            if let snapshot = fromView.snapshotView(afterScreenUpdates: true) {
                container.addSubview(snapshot)
            }
            container.bringSubviewToFront(toView)
        } else {
            container.bringSubviewToFront(fromView)
        }
        
        
        
        let presentedView = isPresenting ? toVC as! DimmableController : fromVC as! DimmableController
        
        let initialTransform: CGAffineTransform = isPresenting ? .init(translationX: 0, y: container.frame.height) : .identity
        let finalTransform: CGAffineTransform = isPresenting ? .identity : .init(translationX: 0, y: container.frame.height)
        
        let initialAlpha: CGFloat = isPresenting ? 0 : 1
        let finalAlpha: CGFloat = isPresenting ? 1 : 0
        
        
        
        presentedView.contentView.transform = initialTransform
        presentedView.dimView.alpha = initialAlpha
        
        UIView.animate(withDuration: 0.3, animations: {
            presentedView.contentView.transform = finalTransform
            presentedView.dimView.alpha = finalAlpha
        }) { _ in
            transitionContext.completeTransition(true)
        }
        
        
    }
    
}
