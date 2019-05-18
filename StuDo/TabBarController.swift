//
//  TabBarController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var feedViewController: FeedViewController!
    var peopleViewController: ProfilesViewController!
    var profileViewController: AccountViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        feedViewController = FeedViewController()
        let feedNavController = UINavigationController(rootViewController: feedViewController)
        feedNavController.tabBarItem = UITabBarItem(title: "Feed", image: nil, selectedImage: nil)
        
        peopleViewController = ProfilesViewController()
        let peopleNavController = UINavigationController(rootViewController: peopleViewController)
        peopleNavController.tabBarItem = UITabBarItem(title: "People", image: nil, selectedImage: nil)
        
        let profileViewController = AccountViewController()
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        profileNavController.tabBarItem = UITabBarItem(title: "Account", image: nil, selectedImage: nil)
        
        viewControllers = [feedNavController, peopleNavController, profileNavController]
        
    }

}
