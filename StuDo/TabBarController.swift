//
//  TabBarController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var feedViewController: FeedViewController!
    var profileViewController: AccountViewController!
    
    let actionButtonSize: CGFloat = 58
    var actionButton = NewAdButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self

        feedViewController = FeedViewController()
        let feedNavController = UINavigationController(rootViewController: feedViewController)
        feedNavController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "today"), selectedImage: nil)
        
        let dummyController = DummyViewController()
        
        profileViewController = AccountViewController()
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        profileNavController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "user_male"), selectedImage: nil)
        
        viewControllers = [feedNavController, dummyController, profileNavController]
        
        
        tabBar.barTintColor = .init(white: 0.04, alpha: 1)
        tabBar.tintColor = .white
        
        
        view.insertSubview(actionButton, aboveSubview: tabBar)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor, constant: 0).isActive = true
        actionButton.centerYAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.centerYAnchor, constant: -10).isActive = true
        actionButton.widthAnchor.constraint(equalToConstant: actionButtonSize).isActive = true
        actionButton.heightAnchor.constraint(equalTo: actionButton.widthAnchor).isActive = true
                
        actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButton.layer.cornerRadius = actionButtonSize / 2
        actionButton.layer.masksToBounds = true
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: DummyViewController.self) {
            return false
        }
        return true
    }
    
    
    @objc func actionButtonTapped(_ button: UIButton) {
        let newAdVC = AdViewController(with: nil, isOwner: true)
        newAdVC.currentMode = .editing
        newAdVC.shouldAppearFullScreen = true
        
        self.present(newAdVC, animated: true, completion: nil)
    }
    
    
    var tabBarIsHidden = false
    
    override func hideTabBar() {
        guard tabBarIsHidden == false else { return }
        
        let offsetTransform = CGAffineTransform(translationX: 0, y: view.frame.height / 2)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.tabBar.transform = offsetTransform
            self.actionButton.transform = offsetTransform
        }) { _ in
            self.tabBar.isHidden = true
            self.actionButton.isHidden = true
        }
        tabBarIsHidden = true
    }
    
    override func showTabBar() {
        guard tabBarIsHidden == true else { return }
        
        self.tabBar.isHidden = false
        self.actionButton.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.tabBar.transform = .identity
            self.actionButton.transform = .identity
        }
        
        tabBarIsHidden = false
    }

}


extension UITabBarController {
    @objc func isTabBarHidden() -> Bool { return tabBar.isHidden }
    @objc func hideTabBar() {}
    @objc func showTabBar() {}
}


fileprivate class DummyViewController: UIViewController {}
