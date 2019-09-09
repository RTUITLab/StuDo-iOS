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
    
    enum FeedMode: Equatable {
        case allAds
        case myAds
        case organization(String)
    }
    var currentMode: FeedMode = .allAds
        
    
    // MARK: Visible properties

    var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var shouldRefreshOnAppear: Bool = true
    
    
    var titleView = FoldingTitleView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

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
        titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        navigationItem.titleView = titleView
                
        tableView.separatorStyle = .none
        
        if let tabBarVC = tabBarController as? TabBarController {
            let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
            tabBarVC.priorityContentTopAnchor.constant = navigationBarHeight
            tabBarVC.navigationMenu.menuDelegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(notification:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
        
        let userDeletedOrganizationName = OrganizationViewController.OrganizationNotifications.userDidDeleteOrganization.name
        NotificationCenter.default.addObserver(self, selector: #selector(userDidDeleteOrganization(notification:)), name: userDeletedOrganizationName, object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        } else {
            client.getOrganizations([.canPublish])
            refreshAds()
        }
    }
    
    @objc func refreshAds() {
        switch currentMode {
        case .allAds:
            client.getAds()
        case .myAds:
            client.getAds(forUserWithId: PersistentStore.shared.user!.id!)
        case .organization(let id):
            client.getAds(forOrganizationWithId: id)
            break
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
    
    func apiClient(_ client: APIClient, didRecieveOrganizations organizations: [Organization], withOptions options: [APIClient.OrganizationRequestOption]?) {
        if let tabBarVC = tabBarController as? TabBarController {
            if let options = options {
                for item in options {
                    switch item {
                    case .canPublish:
                        tabBarVC.navigationMenu.set(organizations: organizations)
                        
                        let menuHeight = tabBarVC.navigationMenu.calculatedMenuHeight
                        tabBarVC.navigationMenu.frame.size = CGSize(width: view.frame.width, height: menuHeight)
                    default:
                        break
                    }
                }
            }
        }
    }
    
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forOrganizationWithId: String) {
        switch currentMode {
        case .organization(_):
            feedItems = ads
            tableView.reloadData()
            refreshControl.endRefreshing()
        default:
            break
        }
    }
    
    
}




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




extension FeedViewController: NavigationMenuDelegate {
    func navigationMenu(_ navigationMenu: NavigationMenu, didChangeOption newOption: NavigationMenu.MenuItemName) {
        switch newOption {
        case .allAds:
            currentMode = .allAds
            client.getAds()
            titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        case .myAds:
            currentMode = .myAds
            client.getAds(forUserWithId: PersistentStore.shared.user!.id!)
            titleView.titleLabel.text = Localizer.string(for: .feedTitleMyAds)
        case .organization(let id, let name):
            currentMode = .organization(id)
            titleView.titleLabel.text = name
            client.getAds(forOrganizationWithId: id)
        }
        
        titleView.changeState()

    }
    
    
}





extension FeedViewController {
    @objc func languageDidChange(notification: Notification) {
        tableView.reloadData()
        switch currentMode {
        case .allAds:
            titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        case .myAds:
            titleView.titleLabel.text = Localizer.string(for: .feedTitleMyAds)
        default:
            break
        }
    }
    
    @objc func userDidDeleteOrganization(notification: Notification) {
        guard let userInfo = notification.userInfo, let deletedOrganizationId = userInfo[OrganizationViewController.organizationIdKey] as? String else { return }
        switch currentMode {
        case .organization(let id):
            if deletedOrganizationId == id {
                if let tabBarVC = tabBarController as? TabBarController {
                    titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
                    tabBarVC.navigationMenu.resetSelectedOption()
                }
            }
        default:
            break
        }
    }
}
