//
//  FeedViewController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import UserNotifications

fileprivate let feedItemCellID = "feedItemCellID"
fileprivate let profileCellID = "profileCellID"
fileprivate let emptyCellID = "emptyCellID"

class FeedViewController: UIViewController {
    
    // -------------------------------------
    // MARK: - Properties
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                
    // MARK: Data & Logic
    
    enum FeedMode: Int, Equatable {
        case ads
        case profiles
    }
    
    var currentMode: FeedMode!
        
    
    // MARK: Visible properties
    
    var visibleViewController: UIViewController!
    let titleView = FoldingTitleView()
    
    
    
    
    // -------------------------------------
    // MARK: - Methods

    
    
    // MARK: Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeMode(newMode: .ads)
        
        view.backgroundColor = .secondarySystemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        titleView.delegate = self
        titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        navigationItem.titleView = titleView
        navigationItem.title = Localizer.string(for: .back)
        
        if let tabBarVC = tabBarController as? TabBarController {
            let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
            tabBarVC.priorityContentTopAnchor.constant = navigationBarHeight
            tabBarVC.navigationMenu.menuDelegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(notification:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.showTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.showTabBar()
    }
    
    // MARK: Observers
    
    @objc private func languageDidChange(notification: Notification) {
        navigationItem.title = Localizer.string(for: .back)
        switch currentMode {
        case .ads:
            titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        case .profiles:
            titleView.titleLabel.text = Localizer.string(for: .feedTitleProfiles)
        default:
            break
        }
    }
    
    // MARK: Mode Control
    
    private func changeMode(newMode: FeedMode) {
        guard newMode != currentMode else { return }
        currentMode = newMode
        
        if visibleViewController != nil {
            removeContentController(visibleViewController)
        }
        
        switch currentMode {
        case .ads:
            visibleViewController = AdsViewController()
            titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        case .profiles:
            visibleViewController = PublicProfilesViewController(style: .plain)
            titleView.titleLabel.text = Localizer.string(for: .feedTitleProfiles)
        default:
            break
        }
        
        addContentController(visibleViewController)
    }
    
    // MARK: Embedded Controllers
    
    private func addContentController(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    private func removeContentController(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

}




// MARK: - Extensions



// MARK: FoldingTitleViewDelegate
extension FeedViewController: FoldingTitleViewDelegate {
    func foldingTitleView(_ foldingTitleView: FoldingTitleView, didChangeState newState: FoldingTitleView.FoldingTitleState) {
        guard let tabBarVC = tabBarController as? TabBarController else { return }
        
        if newState == .unfolded {
            tabBarVC.showNavigationMenu()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                tabBarVC.hideNavigationMenu()
            }
        }
    }
    
}

// MARK: NavigationMenuDelegate
extension FeedViewController: NavigationMenuDelegate {
    func navigationMenu(_ navigationMenu: NavigationMenu, didChangeOption newOption: NavigationMenu.MenuItemName) {
        switch newOption {
        case .ads:
            changeMode(newMode: .ads)
        case .profiles:
            changeMode(newMode: .profiles)
        }
        
        titleView.changeState()
    }
    
}
