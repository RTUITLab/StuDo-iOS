//
//  FeedViewController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let feedItemCellID = "feedItemCellID"

class FeedViewController: UIViewController {
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: Data & Logic
    
    var feedItems = [Ad]()
    var client = APIClient()
    
    enum FeedMode {
        case allAds
        case myAds
    }
    var currentMode: FeedMode = .allAds
        
    
    // MARK: Visible properties

    var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var shouldRefreshOnAppear: Bool = true
    
    
    var titleView = FoldingTitleView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self

        tableView = UITableView(frame: view.frame, style: .plain)
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AdTableViewCell.self, forCellReuseIdentifier: feedItemCellID)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        refreshControl.addTarget(self, action: #selector(refreshAds), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        titleView.delegate = self
        titleView.titleLabel.text = "News"
        navigationItem.titleView = titleView
                
        tableView.separatorStyle = .none
        
        if let tabBarVC = tabBarController as? TabBarController {
            let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
            tabBarVC.priorityContentTopAnchor.constant = navigationBarHeight + 1
            tabBarVC.navigationMenu.menuDelegate = self
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldRefreshOnAppear {
            shouldRefreshOnAppear = false
            refreshAds()
        } else if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
//            shouldRefreshOnAppear = true
        }
    }
    
    @objc func refreshAds() {
        if currentMode == .allAds {
            client.getAds()
        } else if currentMode == .myAds {
            client.getAds(forUserWithId: PersistentStore.shared.user!.id!)
        }
    }

}


extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: feedItemCellID, for: indexPath) as! AdTableViewCell
        cell.set(ad: feedItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAd = feedItems[indexPath.row]
        let detailVC = AdViewController(with: selectedAd)
        detailVC.delegate = self
        
        impactFeedback.impactOccurred()
        shouldRefreshOnAppear = false
        self.present(detailVC, animated: true, completion: nil)
    }
}



extension FeedViewController: AdViewControllerDelegate {
    func adViewController(_ adVC: AdViewController, didDeleteAd deletedAd: Ad) {
        guard let selectedRowsIndexPath = tableView.indexPathsForSelectedRows else { return }
        
        for indexPath in selectedRowsIndexPath {
            if feedItems[indexPath.row].id == deletedAd.id {
                feedItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func adViewController(_ adVC: AdViewController, didUpdateAd updatedAd: Ad) {
        guard let selectedRowsIndexPath = tableView.indexPathsForSelectedRows else { return }
        
        for indexPath in selectedRowsIndexPath {
            if feedItems[indexPath.row].id == updatedAd.id {
                feedItems[indexPath.row] = updatedAd
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
}


extension FeedViewController: APIClientDelegate {
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print("Feed VC: \(error.localizedDescription)")
        refreshControl.endRefreshing()
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        if currentMode == .allAds {
            feedItems = ads
            tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forUserWithId: String) {
        if currentMode == .myAds {
            feedItems = ads
            tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    
}




extension FeedViewController: FoldingTitleViewDelegate {
    func foldingTitleView(_ foldingTitleView: FoldingTitleView, didChangeState newState: FoldingTitleView.FoldingTitleState) {
        guard let tabBarVC = tabBarController as? TabBarController else { return }
        
        if newState == .unfolded {
            tabBarVC.showNavigationMenu()
        } else {
            tabBarVC.hideNavigationMenu()
        }
    }
    
}




extension FeedViewController: NavigationMenuDelegate {
    func navigationMenu(_ navigationMenu: NavigationMenu, didChangeOption newOption: NavigationMenu.MenuItemName) {
        if newOption == .allAds {
            currentMode = .allAds
            client.getAds()
            titleView.titleLabel.text = "News"
        } else if newOption == .myAds {
            currentMode = .myAds
            client.getAds(forUserWithId: PersistentStore.shared.user!.id!)
            titleView.titleLabel.text = "My Ads"
        }
        
        titleView.changeState()

    }
    
    
}
