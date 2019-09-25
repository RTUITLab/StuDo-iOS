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
    
    private var defaultContainerInsets: UIEdgeInsets!
    
    var shouldAppearFullScreen = false
    var isFullscreen = false {
        didSet {
            switch isFullscreen {
            case true:
                UIView.animate(withDuration: 0.3, animations: {
                    self.containerView.contentOffset = .zero
                }) { _ in
                    // keep the previousBottomInset in case if keyboard show notification fires first
                    let previousContentInset = self.containerView.contentInset
                    self.containerView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: previousContentInset.bottom, right: 0)
                    self.didEnterFullscreen()
                }
            case false:
                // if keyboard is present, handle the insets change when the keyboard is being dismissed for proper layout behavior
                if visibleKeyboardHeight == 0 {
                    containerView.contentInset = defaultContainerInsets
                }
            }
        }
    }
    
    private var visibleKeyboardHeight: CGFloat = 0
    var contentHeight: CGFloat {
        return 0
    }
    
    private var minimumContentHeight: CGFloat = 0
    private let containerFrameYOffset: CGFloat = UIApplication.shared.statusBarFrame.height
    private let cardTopOffset: CGFloat = 44
    
    private var previousContentOffset: CGFloat = CGFloat.leastNormalMagnitude
    private var statusBarStyle: UIStatusBarStyle = .default
    
    let containerView = UIScrollView()
    let cardView = UIView()
    let contentView = UIView()
    let dimView = UIView()
    
    let headerView = UIView()
    private let horizontalHandle = UIView()
    private let headerSeparator = UIView()
    private let headerLabel = UILabel()
    
    override var title: String? {
        didSet {
            if title != nil {
                headerLabel.isHidden = false
                horizontalHandle.isHidden = true
            } else {
                headerLabel.isHidden = true
                horizontalHandle.isHidden = false
            }
            
            headerLabel.text = title
        }
        
    }
    
    
    override func viewDidLoad() {
        
        let cornerRadius: CGFloat = 8
        let initialYOffset: CGFloat = -view.frame.height + view.frame.height / 2
        previousContentOffset = initialYOffset
        minimumContentHeight = view.frame.height - containerFrameYOffset
        
        defaultContainerInsets = UIEdgeInsets(top: view.frame.height, left: 0, bottom: 0, right: 0)
        adjustContentLayout()
        
        view.addSubview(containerView)
        containerView.frame = CGRect(x: 0, y: containerFrameYOffset, width: view.frame.width, height: view.frame.height - containerFrameYOffset)
        containerView.contentInsetAdjustmentBehavior = .never
        containerView.contentInset = defaultContainerInsets
        containerView.contentOffset = CGPoint(x: 0, y: initialYOffset)
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true
        
        containerView.addSubview(cardView)
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = cornerRadius
        cardView.layer.masksToBounds = true
        
        
        cardView.addSubview(contentView)
        contentView.backgroundColor = .white
        
        
        view.insertSubview(dimView, belowSubview: containerView)
        dimView.frame = view.frame
        dimView.backgroundColor = .init(white: 0, alpha: 0.7)
        dimView.alpha = 0
        
        
        cardView.addSubview(headerView)
        headerView.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: cardTopOffset))
        headerView.backgroundColor = .white
        headerView.layer.shadowColor = UIColor(red:0.447, green:0.447, blue:0.443, alpha:0.4).cgColor
        headerView.layer.shadowRadius = 5
        
        
        
        let handleHeight: CGFloat = 5
        headerView.addSubview(horizontalHandle)
        horizontalHandle.translatesAutoresizingMaskIntoConstraints = false
        horizontalHandle.widthAnchor.constraint(equalToConstant: 50).isActive = true
        horizontalHandle.heightAnchor.constraint(equalToConstant: handleHeight).isActive = true
        horizontalHandle.centerXAnchor.constraint(equalTo: cardView.centerXAnchor).isActive = true
        horizontalHandle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        horizontalHandle.layer.cornerRadius = handleHeight / 2
        horizontalHandle.backgroundColor = UIColor(red:0.815, green:0.819, blue:0.837, alpha:1.000)
        
        
        headerView.addSubview(headerSeparator)
        headerSeparator.translatesAutoresizingMaskIntoConstraints = false
        headerSeparator.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 1).isActive = true
        headerSeparator.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        headerSeparator.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        headerSeparator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        headerSeparator.backgroundColor = UIColor(red:0.816, green:0.816, blue:0.816, alpha:1.000)
        headerSeparator.alpha = 0
        
        
        
        
        headerView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.centerXAnchor.constraint(equalTo: horizontalHandle.centerXAnchor).isActive = true
        headerLabel.centerYAnchor.constraint(equalTo: horizontalHandle.centerYAnchor).isActive = true
        
        headerLabel.textColor = .lightGray
        headerLabel.font = .systemFont(ofSize: 16, weight: .light)

        
        containerView.keyboardDismissMode = .interactive
        containerView.alwaysBounceVertical = true
        containerView.showsVerticalScrollIndicator = false
        containerView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOnContainer(_:)))
        containerView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func didEnterFullscreen() {}
    func shouldAllowDismissOnSwipe() -> Bool { return true }

    func adjustContentLayout() {
        let contentHeight = max(self.contentHeight, minimumContentHeight - visibleKeyboardHeight)
        let cardViewSize = CGSize(width: view.frame.width, height: contentHeight + view.frame.height / 2)
        let contentSize = CGSize(width: cardViewSize.width, height: contentHeight)
        let containerContentSize = CGSize(width: cardViewSize.width, height: contentHeight)
        
        containerView.contentSize = containerContentSize
        cardView.frame = CGRect(origin: .zero, size: cardViewSize)
        contentView.frame = CGRect(origin: CGPoint(x: 0, y: cardTopOffset), size: contentSize)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isFullscreen {
            return .lightContent
        }
        return statusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
}






extension CardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === containerView {
            let offsetY = containerView.contentOffset.y
            if offsetY < -view.frame.height + view.frame.height / 3 && !isFullscreen {
                self.dismiss(animated: true, completion: nil)
            }
            
            if offsetY >= 0 && previousContentOffset < 0 {
                statusBarStyle = .lightContent
                setNeedsStatusBarAppearanceUpdate()
            } else if offsetY < 0 && previousContentOffset >= 0 {
                statusBarStyle = .default
                setNeedsStatusBarAppearanceUpdate()
            }
            
            if offsetY > 0 && previousContentOffset <= 0 {
                UIView.animate(withDuration: 0.3) {
                    self.horizontalHandle.alpha = 0
                }
            } else if offsetY <= 0 && previousContentOffset > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.horizontalHandle.alpha = 1
                }
            }
            
            var separatorAnimationTime: TimeInterval = 0.3
            var headerShadowAnimationTime: TimeInterval = 0.8
            
            var separatorAlpha: CGFloat = 1
            var initialHeaderShadowOpacity: Float = 0
            var headerShadowOpacity: Float = 1
            if offsetY > 0 {
                headerView.frame.origin = CGPoint(x: 0, y: offsetY)
            } else {
                headerView.frame.origin = .zero
                separatorAlpha = 0
                initialHeaderShadowOpacity = 1
                headerShadowOpacity = 0
                
                separatorAnimationTime = 0.3
                headerShadowAnimationTime = 0.2
            }
            
            UIView.animate(withDuration: separatorAnimationTime) {
                self.headerSeparator.alpha = separatorAlpha
            }
            
            if headerView.layer.shadowOpacity != headerShadowOpacity {
                let shadowOpacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.shadowOpacity))
                shadowOpacityAnimation.fromValue = initialHeaderShadowOpacity
                shadowOpacityAnimation.toValue = headerShadowOpacity
                shadowOpacityAnimation.duration = headerShadowAnimationTime
                headerView.layer.shadowOpacity = headerShadowOpacity
                headerView.layer.add(shadowOpacityAnimation, forKey: #keyPath(CALayer.shadowOpacity))
            }
            
            previousContentOffset = offsetY
            
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






extension CardViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        visibleKeyboardHeight = keyboardSize.height + 5
        containerView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: visibleKeyboardHeight, right: 0)
        containerView.contentOffset = CGPoint(x: 0, y: 0)
        adjustContentLayout()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        visibleKeyboardHeight = 0
        adjustContentLayout()
        
        if shouldAllowDismissOnSwipe() {
            containerView.contentInset = defaultContainerInsets
            containerView.setContentOffset(.zero, animated: true)
        } else {
            containerView.contentInset = .zero
        }
    }
}
