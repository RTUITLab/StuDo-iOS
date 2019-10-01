//
//  RootViewController.swift
//  StuDo
//
//  Created by Andrew on 8/10/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    var isInitialSetup = true
    let loadingIndicator = LoadingIndicator()
    
    private var mainController: TabBarController!
    private var authorizationController: AuthorizationViewController!
    
    static var main: RootViewController!
    
    private let fadeAnimator = FadeAnimatedTransitioning()
    private let flipAnimator: UIViewControllerAnimatedTransitioning! = nil
    
    enum RootViewControllerTransitionStyle {
        case fade
        case flip
    }
    private var preferredTransitionStyle: RootViewControllerTransitionStyle = .fade
    private var currentTransitionAnimator: UIViewControllerAnimatedTransitioning {
        switch preferredTransitionStyle {
        case .fade:
            return fadeAnimator
        case .flip:
            return flipAnimator
        }
    }
    
    private let darkBlue = UIColor(red:0.209, green:0.409, blue:0.695, alpha:1.000)
    private let lightBlue = UIColor(red:0.313, green:0.549, blue:0.921, alpha:1.000)
    private var gradientLayer: CAGradientLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [darkBlue.cgColor, lightBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.addSublayer(gradientLayer)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 10)) {
            self.proceed()
        }
        
        

    }
    
    override func viewDidLayoutSubviews() {
        if isInitialSetup {
            isInitialSetup = false
            
            if let appWindow = UIApplication.shared.delegate?.window! {
                appWindow.addSubview(loadingIndicator)
                loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
                let loadingIndicatorSize: CGFloat = 60
                loadingIndicator.heightAnchor.constraint(equalToConstant: loadingIndicatorSize).isActive = true
                loadingIndicator.widthAnchor.constraint(greaterThanOrEqualToConstant: loadingIndicatorSize).isActive = true
                loadingIndicator.centerXAnchor.constraint(equalTo: appWindow.centerXAnchor, constant: 0).isActive = true
                loadingIndicator.centerYAnchor.constraint(equalTo: appWindow.centerYAnchor, constant: -loadingIndicatorSize / 2).isActive = true
            }
            
        }
    }
    
    
    
    func proceed() {
        authorizationController = nil
        mainController = nil
        
        if PersistentStore.shared.user == nil {
            proceedToAuthorizationController()
        } else {
            proceedToMainController()
        }
    }
    
    
    
    func proceedToAuthorizationController() {
        authorizationController = AuthorizationViewController()
        authorizationController.transitioningDelegate = self
        
        authorizationController.modalPresentationStyle = .fullScreen
        present(authorizationController, animated: true, completion: nil)
    }
    
    
    
    func proceedToMainController() {
        mainController = TabBarController()
        mainController.transitioningDelegate = self
        mainController.modalPresentationStyle = .fullScreen
        present(mainController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    func login() {
        gradientLayer.removeFromSuperlayer()
        authorizationController.dismiss(animated: true, completion: nil)
        proceed()
    }
    
    
    
    
    func logout() {
        
        PersistentStore.cleanUserRelatedPersistentData()
        
        view.layer.addSublayer(gradientLayer)

        mainController.dismiss(animated: true, completion: nil)
        proceed()
    }
    
    
    
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}





extension RootViewController: UIViewControllerTransitioningDelegate {
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return currentTransitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return currentTransitionAnimator
    }
    
    
}




extension RootViewController {
    
    static func startLoadingIndicator() {
        if let appWindow = UIApplication.shared.delegate?.window! {
            appWindow.bringSubviewToFront(RootViewController.main.loadingIndicator)
        }
        RootViewController.main.loadingIndicator.startIndicator()
    }
    
    static func stopLoadingIndicator(with stopReason: LoadingIndicator.StopIndicatorType, completion: (() -> ())? = nil) {
        RootViewController.main.loadingIndicator.stopIndicator(with: stopReason, completion: completion)
    }
}
