//
//  CardViewController.swift
//  Card transform
//
//  Created by Andrew on 7/29/19.
//  Copyright © 2019 Andrew Allen. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    
    fileprivate let animator = CardAnimatedTransitioning()
    
    let containerView = UIScrollView()
    let cardView = UIView()
    let contentView = UIView()
    let dimView = UIView()
    
    let horizontalHandle = UIView()
    
    override func viewDidLoad() {
        
        let contentHeight: CGFloat = 1000
        let cornerRadius: CGFloat = 8
        let containerFrameYOffset: CGFloat = UIApplication.shared.statusBarFrame.height
        let initialYOffset: CGFloat = -view.frame.height + view.frame.height / 2
        let cardTopOffset: CGFloat = 24
        
        let cardViewSize = CGSize(width: view.frame.width, height: contentHeight + view.frame.height / 2)
        let containerInset = UIEdgeInsets(top: view.frame.height, left: 0, bottom: 0, right: 0)
        let contentSize = CGSize(width: cardViewSize.width, height: contentHeight + cardTopOffset)
        let containerContentSize = CGSize(width: cardViewSize.width, height: contentHeight + containerFrameYOffset)
        

        
        view.addSubview(containerView)
        containerView.frame = CGRect(x: 0, y: containerFrameYOffset, width: view.frame.width, height: view.frame.height)
        containerView.contentInsetAdjustmentBehavior = .never
        containerView.contentInset = containerInset
        containerView.contentSize = containerContentSize
        containerView.contentOffset = CGPoint(x: 0, y: initialYOffset)
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true
        
        containerView.addSubview(cardView)
        cardView.frame = CGRect(origin: .zero, size: cardViewSize)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = cornerRadius
        cardView.layer.masksToBounds = true
        
        
        cardView.addSubview(contentView)
        contentView.frame = CGRect(origin: CGPoint(x: 0, y: cardTopOffset), size: contentSize)
        contentView.backgroundColor = .white
        
        
        view.insertSubview(dimView, belowSubview: containerView)
        dimView.frame = view.frame
        dimView.backgroundColor = .init(white: 0, alpha: 0.7)
        dimView.alpha = 0
        
        let handleHeight: CGFloat = 5
        contentView.addSubview(horizontalHandle)
        horizontalHandle.translatesAutoresizingMaskIntoConstraints = false
        horizontalHandle.widthAnchor.constraint(equalToConstant: 50).isActive = true
        horizontalHandle.heightAnchor.constraint(equalToConstant: handleHeight).isActive = true
        horizontalHandle.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        horizontalHandle.topAnchor.constraint(equalTo: cardView.topAnchor, constant: cardTopOffset / 2).isActive = true
        
        horizontalHandle.layer.cornerRadius = handleHeight / 2
        horizontalHandle.backgroundColor = .black
        
        
        containerView.showsVerticalScrollIndicator = false
        containerView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOnContainer(_:)))
        containerView.addGestureRecognizer(tap)
        
    }
    
    @objc func handleTapOnContainer(_ tap: UITapGestureRecognizer) {
        let location = tap.location(in: cardView)
        if location.y < 0 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






extension CardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === containerView {
            let offsetY = containerView.contentOffset.y
            if offsetY < -view.frame.height + view.frame.height / 3 {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}






extension CardViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        return animator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        return animator
    }
}
