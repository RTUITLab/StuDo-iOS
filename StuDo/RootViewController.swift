//
//  RootViewController.swift
//  StuDo
//
//  Created by Andrew on 8/10/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
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
        
        present(authorizationController, animated: true, completion: nil)
    }
    
    
    
    func proceedToMainController() {
        mainController = TabBarController()
        mainController.transitioningDelegate = self
        
        present(mainController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    func login() {
        gradientLayer.removeFromSuperlayer()
        authorizationController.dismiss(animated: true, completion: nil)
        proceed()
    }
    
    
    
    
    func logout() {
        
        try? APIClient.deleteAccessTokenFromKeychain()
        PersistentStore.shared.user = nil
        PersistentStore.shared.profilePictureGradientIndex = nil
        if !GCIsUsingFakeData {
            PersistentStore.save()
        }
        
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
