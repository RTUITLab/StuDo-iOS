//
//  TabBarController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let showHideAnimationDuration: TimeInterval = 0.35
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    var client = APIClient()
    
    var feedViewController: FeedViewController!
    var accountViewController: AccountViewController!
    
    let actionButtonSize: CGFloat = 58
    var actionButton = NewAdButton()
    
    
    var priorityContentTopAnchor: NSLayoutConstraint!
    let navigationMenuContainer = UIView()
    let dimView = UIView()
    var navigationMenu = NavigationMenu()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        let currentUserId = PersistentStore.shared.user!.id!
        client.getProfiles(forUserWithId: currentUserId)
        
        delegate = self

        feedViewController = FeedViewController()
        let feedNavController = UINavigationController(rootViewController: feedViewController)
        feedNavController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "today"), selectedImage: nil)
        
        let dummyController = DummyViewController()
        
        accountViewController = AccountViewController()
        let profileNavController = UINavigationController(rootViewController: accountViewController)
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
        
        
        
        
        navigationMenuContainer.isHidden = true
        
        
        view.addSubview(navigationMenuContainer)
        navigationMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        navigationMenuContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationMenuContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigationMenuContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        priorityContentTopAnchor = navigationMenuContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        priorityContentTopAnchor.isActive = true
        
        navigationMenuContainer.clipsToBounds = true
        
        
        navigationMenuContainer.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dimView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        dimView.backgroundColor = .init(white: 0, alpha: 0.7)
        
        
        navigationMenuContainer.addSubview(navigationMenu)
        let menuHeight = navigationMenu.calculatedMenuHeight
        navigationMenu.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: menuHeight)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimViewTapped(_:)))
        dimView.addGestureRecognizer(tap)

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
        hapticFeedback.impactOccurred()
        
        let newAdVC = AdViewController(with: nil, isOwner: true)
        newAdVC.currentMode = .editing
        newAdVC.shouldAppearFullScreen = true
        
        newAdVC.modalPresentationStyle = .fullScreen
        self.present(newAdVC, animated: true, completion: nil)
    }
    
    
    var tabBarIsHidden = false
    
    override func hideTabBar() {
        guard tabBarIsHidden == false else { return }
        
        let offsetTransform = CGAffineTransform(translationX: 0, y: view.frame.height / 2)
        
        UIView.animate(withDuration: showHideAnimationDuration, animations: {
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
        
        UIView.animate(withDuration: showHideAnimationDuration) {
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




extension TabBarController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func apiClient(_ client: APIClient, didRecieveProfiles profiles: [Profile]) {
        accountViewController.ownProfiles = profiles
    }
    
    
}





extension TabBarController {
    
    @objc func dimViewTapped(_ tap: UITapGestureRecognizer) {
        feedViewController.titleView.changeState()
    }
    
    func showNavigationMenu() {
        self.navigationMenuContainer.isHidden = false
        navigationMenu.transform = CGAffineTransform(translationX: 0, y: -navigationMenu.calculatedMenuHeight)
            
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha = 1
            self.navigationMenu.transform = .identity
        }
    }
    
    func hideNavigationMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.dimView.alpha = 0
            self.navigationMenu.transform = CGAffineTransform(translationX: 0, y: -self.navigationMenu.calculatedMenuHeight)
        }) { _ in
            self.navigationMenuContainer.isHidden = true
        }
    }
}
