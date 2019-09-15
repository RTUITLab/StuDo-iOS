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

class FeedViewController: UIViewController {
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: Data & Logic
    
    var feedItems = [Ad]()
    var client = APIClient()
    
    var indexPathUnderChange: IndexPath!
    
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
    let placeholderView = UIView()
    let noAdsTitleLabel = UILabel()
    let noAdsDescriptionLabel = UILabel()
    
    deinit {
        print("FeedViewController deinitialized")
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self

        tableView = UITableView(frame: view.frame, style: .plain)
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: feedItemCellID)
        
        tableView.estimatedRowHeight = 140
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
                
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        
        if let tabBarVC = tabBarController as? TabBarController {
            let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
            tabBarVC.priorityContentTopAnchor.constant = navigationBarHeight
            tabBarVC.navigationMenu.menuDelegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(notification:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
        
        let userDeletedOrganizationName = OrganizationViewController.OrganizationNotifications.userDidDeleteOrganization.name
        NotificationCenter.default.addObserver(self, selector: #selector(userDidDeleteOrganization(notification:)), name: userDeletedOrganizationName, object: nil)
        
        
        
        
        view.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        placeholderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        placeholderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        placeholderView.isHidden = true
        
        
        
        placeholderView.addSubview(noAdsTitleLabel)
        noAdsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        noAdsTitleLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor).isActive = true
        noAdsTitleLabel.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor, constant: -50).isActive = true
        noAdsTitleLabel.widthAnchor.constraint(equalTo: placeholderView.widthAnchor, multiplier: 0.9).isActive = true
        
        placeholderView.addSubview(noAdsDescriptionLabel)
        noAdsDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        noAdsDescriptionLabel.centerXAnchor.constraint(equalTo: noAdsTitleLabel.centerXAnchor).isActive = true
        noAdsDescriptionLabel.topAnchor.constraint(equalTo: noAdsTitleLabel.bottomAnchor, constant: 15).isActive = true
        noAdsDescriptionLabel.widthAnchor.constraint(equalTo: placeholderView.widthAnchor, multiplier: 0.9).isActive = true
        
        
        noAdsTitleLabel.textAlignment = .center
        noAdsTitleLabel.text = Localizer.string(for: .feedNoAdsTitle)
        noAdsTitleLabel.font = .preferredFont(forTextStyle: .headline)
        
        noAdsDescriptionLabel.textAlignment = .center
        noAdsDescriptionLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        noAdsDescriptionLabel.textColor = .lightGray
        noAdsDescriptionLabel.numberOfLines = 3
        
        navigationItem.title = Localizer.string(for: .back)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        } else {
            client.getOrganizations([.canPublish])
            refreshAds()
        }
        tabBarController?.showTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.showTabBar()
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
        
        let currentAd = feedItems[indexPath.row]
        cell.titleLabel.text = currentAd.name
        cell.creatorLabel.text = Localizer.string(for: .feedPublishedBy) + " " + currentAd.creatorName
        cell.descriptionTextView.text = currentAd.shortDescription
        cell.dateLabel.text = currentAd.dateRange
        cell.moreButtonCallback = { [weak self] in
            guard let self = self else { return }
            self.moreButtonTappedInCell(with: indexPath)
        }
        
        return cell
    }
    
    fileprivate func presentAdViewer(_ selectedAd: Ad, startInEditorMode: Bool = false) {
        let detailVC = AdViewController(with: selectedAd, isOwner: startInEditorMode)
        if startInEditorMode {
            detailVC.currentMode = .editing
            detailVC.shouldAppearFullScreen = true
        }
        detailVC.delegate = self
        
        impactFeedback.impactOccurred()
        shouldRefreshOnAppear = false
        self.present(detailVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAd = feedItems[indexPath.row]
        presentAdViewer(selectedAd)
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
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    fileprivate func setAds(_ ads: [Ad]) {
        feedItems = ads
        
        switch currentMode {
        case .allAds:
            noAdsDescriptionLabel.text = Localizer.string(for: .feedNoAdsDescription)
        case .myAds:
            noAdsDescriptionLabel.text = Localizer.string(for: .feedNoOwnAdsDescription)
        case .organization:
            noAdsDescriptionLabel.text = Localizer.string(for: .feedNoOrganizationAdsDescription)
        }
        
        placeholderView.isHidden = !feedItems.isEmpty
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        if currentMode == .allAds {
            setAds(ads)
            tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forUserWithId: String) {
        if currentMode == .myAds {
            setAds(ads)
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
            setAds(ads)
            tableView.reloadData()
            refreshControl.endRefreshing()
        default:
            break
        }
    }
    
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        feedItems.remove(at: indexPathUnderChange.row)
        tableView.deleteRows(at: [indexPathUnderChange], with: .fade)
        indexPathUnderChange = nil
    }
    
    
    
    
    
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization) {
        let orgVC = OrganizationViewController(organization: organization)
        navigationController?.pushViewController(orgVC, animated: true)
    }
    
    func apiClient(_ client: APIClient, didRecieveUser user: User) {
        let userVC = UserPublicController(user: user)
        navigationController?.pushViewController(userVC, animated: true)
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
    
    func moreButtonTappedInCell(with indexPath: IndexPath) {
        
        let currentAd = feedItems[indexPath.row]
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if Notifications.checkIfCanSetNotifications(for: currentAd.beginTime) {
            alert.addAction(UIAlertAction(title: Localizer.string(for: .notificationSetReminder), style: .default, handler: { _ in
                let notificationAlert = Notifications.notificationAlert(for: currentAd, in: self)
                self.present(notificationAlert, animated: true, completion: nil)
            }))
        }
        
        let title = Localizer.string(for: .feedCreatorPage)
        if let userId = currentAd.userId, userId != PersistentStore.shared.user.id {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                self.client.getUser(id: userId)
            }))
        } else if let organizationId = currentAd.organizationId {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                self.client.getOrganization(withId: organizationId)
            }))
        }
        
        if currentAd.userId == PersistentStore.shared.user.id {
            let currentAd = feedItems[indexPath.row]
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorEditAd), style: .default, handler: { _ in
                self.presentAdViewer(currentAd, startInEditorMode: true)
            }))
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorDeleteAd), style: .destructive, handler: { _ in
                self.indexPathUnderChange = indexPath
                self.client.deleteAd(withId: currentAd.id)
                RootViewController.startLoadingIndicator()
            }))
        }
        
        alert.addAction(UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
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
        noAdsTitleLabel.text = Localizer.string(for: .feedNoAdsTitle)
        navigationItem.title = Localizer.string(for: .back)
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
            currentMode = .allAds
        default:
            break
        }
    }
}
