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
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                
    // MARK: Data & Logic
    
    var profiles = [Profile]()
    var feedItems = [Ad]()
    var client = APIClient()
    
    var indexPathUnderChange: IndexPath!
    
//    var adNavigationHeightConstraint: NSLayoutConstraint!
    
    enum FeedMode: Equatable {
        case allAds
        case myAds
        case bookmarks
        case organization(String)
        case profiles
    }
    var currentMode: FeedMode = .allAds
    func switchMode(newMode: FeedMode) {
        currentMode = newMode
        switch currentMode {
        case .allAds:
            client.getAds()
            titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        case .myAds:
            client.getAds(forUserWithId: PersistentStore.shared.user.id!)
            titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        case .bookmarks:
            client.getBookmarkedAds()
            titleView.titleLabel.text = Localizer.string(for: .feedTitleAllAds)
        case .profiles:
            client.getProfiles()
            titleView.titleLabel.text = Localizer.string(for: .feedTitleProfiles)
        default:
            break
        }
    }
        
    
    // MARK: Visible properties
    
    private let sectionHeaderHeight: CGFloat = 40

    var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    
    var shouldRefreshOnAppear: Bool = true
    
    
    var titleView = FoldingTitleView()
    let placeholderView = UIView()
    let noAdsTitleLabel = UILabel()
    let noAdsDescriptionLabel = UILabel()
    
//    var adNavigationView: AdNavigationView! = nil
    
    deinit {
        print("FeedViewController deinitialized")
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemFill
        
        client.delegate = self

        tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: feedItemCellID)
        tableView.register(TableViewCellWithSubtitle.self, forCellReuseIdentifier: profileCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: emptyCellID)
        
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
        
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

//        adNavigationView = AdNavigationView(frame: .zero)
//
//        adNavigationView.actionClosure = { [unowned self] index in
//            if index == 0 {
//                self.switchMode(newMode: .allAds)
//            } else if index == 1 {
//                self.switchMode(newMode: .myAds)
//            } else if index == 2 {
//                self.switchMode(newMode: .bookmarks)
//            }
//            self.tableView.reloadData()
//        }
//
//        view.addSubview(adNavigationView)
//        adNavigationView.translatesAutoresizingMaskIntoConstraints = false
//        adNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        adNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        adNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//
//        adNavigationHeightConstraint = adNavigationView.heightAnchor.constraint(equalToConstant: sectionHeaderHeight)
//        adNavigationHeightConstraint.isActive = true
        
        
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
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        blurView.frame = CGRect(x: 0, y: 0, width: 100, height: 400)
        tableView.backgroundView = blurView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        } else {
            client.getOrganizations([.canPublish])
            refreshAds()
        }
        
        if indexPathUnderChange != nil {
            indexPathUnderChange = nil
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
        case .profiles:
            client.getProfiles()
        case .myAds:
            client.getAds(forUserWithId: PersistentStore.shared.user!.id!)
        case .bookmarks:
            client.getBookmarkedAds()
        case .organization(let id):
            client.getAds(forOrganizationWithId: id)
            break
        }
    }
    
    
    func removeIndexUnderChange() {
        feedItems.remove(at: indexPathUnderChange.row)
        tableView.deleteRows(at: [indexPathUnderChange], with: .fade)
        indexPathUnderChange = nil
    }
    
    func updateIndexUnderChange(_ newAd: Ad) {
        guard let newAdIndex = feedItems.enumerated().filter({ $0.element.id == newAd.id }).first?.offset else { return }
        feedItems[newAdIndex] = newAd
        tableView.reloadRows(at: [IndexPath(row: newAdIndex, section: 0)], with: .none)
        indexPathUnderChange = nil
    }
    
    
    // MARK: Touch Control
    
//    var firstLocation: CGPoint?
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let firstTouch = touches.first!
//        firstLocation = firstTouch.location(in: view)
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first, let firstLocation = firstLocation else { return }
//        let location = touch.location(in: view)
//        print(abs(location.x - firstLocation.x))
//        guard abs(location.x - firstLocation.x) > 70 else { return }
//        if (location.x > firstLocation.x) {
//            handle(.right)
//        } else if (location.x < firstLocation.x) {
//            handle(.left)
//        }
//        self.firstLocation = nil
//        print(tableView.frame)
//    }
    
//    func handle(_ swipe: SwipeDirection) {
//        var shouldUpdate = true
//        var direction: UIView.AnimationOptions = .transitionCrossDissolve
//        switch swipe {
//        case .left:
//            if currentMode == .allAds {
//                switchMode(newMode: .myAds)
//            } else if currentMode == .myAds {
//                switchMode(newMode: .bookmarks)
//            } else {
//                shouldUpdate = false
//            }
//            direction = .transitionFlipFromRight
//        case .right:
//            if currentMode == .bookmarks {
//                switchMode(newMode: .myAds)
//            } else if currentMode == .myAds {
//                switchMode(newMode: .allAds)
//            } else {
//                shouldUpdate = false
//            }
//            direction = .transitionFlipFromLeft
//        }
//
//        if shouldUpdate {
//            UIView.transition(with: tableView,
//            duration: 0.35,
//            options: direction,
//            animations: { self.tableView.reloadData() })
//        }
//    }
//
//    enum SwipeDirection {
//        case right
//        case left
//    }

}


extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentMode == .profiles {
            return profiles.count
        }
        return feedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentMode == .profiles {
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellID, for: indexPath)
            let profile = profiles[indexPath.row]
            cell.textLabel?.text = profile.name
            cell.detailTextLabel?.text = profile.description
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: feedItemCellID, for: indexPath) as! AdTableViewCell
        
        let currentAd = feedItems[indexPath.row]
        cell.titleLabel.text = currentAd.name
        cell.creatorLabel.text = Localizer.string(for: .feedPublishedBy) + " " + currentAd.creatorName
        cell.descriptionTextView.attributedText = TextFormatter.parseMarkdownString(currentAd.shortDescription, fontWeight: .light)
        cell.dateLabel.text = currentAd.dateRange
        cell.moreButtonCallback = { [weak self] in
            guard let self = self else { return }
            self.moreButtonTappedInCell(with: indexPath)
        }
        
        cell.layoutIfNeeded()
                
        return cell
    }
    
    fileprivate func presentAdViewer(_ selectedAd: Ad, startInEditorMode: Bool = false) {
        
        let detailVC = AdViewController(ad: selectedAd)
        
        if startInEditorMode {
            detailVC.currentState = .editing
        }
        
        impactFeedback.impactOccurred()
        shouldRefreshOnAppear = false
        
        self.present(detailVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentMode == .profiles {
            let currentProfile = profiles[indexPath.row]
            let profileVC = ProfileEditorViewController(profile: currentProfile, canEditProfile: false, shouldShowUserPage: true)
            navigationController?.pushViewController(profileVC, animated: true)
            return
        }
        let selectedAd = feedItems[indexPath.row]
        indexPathUnderChange = indexPath
        presentAdViewer(selectedAd)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        case .bookmarks:
            noAdsDescriptionLabel.text = Localizer.string(for: .feedNoBookmarkedAdsDescription)
        case .organization:
            noAdsDescriptionLabel.text = Localizer.string(for: .feedNoOrganizationAdsDescription)
        default:
            break
        }
        
        placeholderView.isHidden = !feedItems.isEmpty
        
        tableView.contentInset = .zero
//        tableView.contentInset = UIEdgeInsets(top: sectionHeaderHeight, left: 0, bottom: 0, right: 0)
//        adNavigationHeightConstraint.constant = sectionHeaderHeight
        
//        switch currentMode {
//        case .allAds:
//            adNavigationView.selectedIndex = 0
//        case .myAds:
//            adNavigationView.selectedIndex = 1
//        case .bookmarks:
//            adNavigationView.selectedIndex = 2
//        default:
//            break
//        }
    }
    
    fileprivate func set(_ profiles: [Profile]) {
        self.profiles = profiles
        noAdsDescriptionLabel.text = Localizer.string(for: .feedNoProfilesDescription)
        placeholderView.isHidden = !profiles.isEmpty
        tableView.contentInset = .zero
//        adNavigationHeightConstraint.constant = 0
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
    
    func apiClient(_ client: APIClient, didRecieveBookmarkedAds ads: [Ad]) {
        if currentMode == .bookmarks {
            setAds(ads)
            tableView.reloadData()
            refreshControl.endRefreshing()
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
    
    func apiClient(_ client: APIClient, didRecieveProfiles profiles: [Profile]) {
        if currentMode == .profiles {
            set(profiles)
            tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        removeIndexUnderChange()
    }
    
    
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization) {
        let orgVC = OrganizationViewController(organization: organization)
        navigationController?.pushViewController(orgVC, animated: true)
    }
    
    func apiClient(_ client: APIClient, didRecieveUser user: User) {
        let userVC = UserPublicController(user: user)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    func apiClient(_ client: APIClient, didBookmarkAdWithId adId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        guard let itemIndex = feedItems.enumerated().filter({ $1.id == adId}).map({ $0.offset}).first else { return }
        feedItems[itemIndex].isFavorite = true
    }
    
    func apiClient(_ client: APIClient, didUnbookmarkAdWithId adId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        guard let itemIndex = feedItems.enumerated().filter({ $1.id == adId}).map({ $0.offset}).first else { return }
        feedItems[itemIndex].isFavorite = false
        if currentMode == .bookmarks {
            DispatchQueue.main.async {
                self.feedItems.remove(at: itemIndex)
                self.tableView.deleteRows(at: [IndexPath(row: itemIndex, section: 0)], with: .fade)
                self.placeholderView.animateVisibility(shouldHide: !self.feedItems.isEmpty)
            }
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
        case .ads:
            switchMode(newMode: .allAds)
        case .profiles:
            switchMode(newMode: .profiles)
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
        
        if currentAd.isFavorite {
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorRemoveFromBookmarks), style: .default, handler: { _ in
                self.client.unbookmarkAd(withId: currentAd.id!)
                RootViewController.startLoadingIndicator()
            }))
        } else {
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorAddToBookmarks), style: .default, handler: { _ in
                self.client.bookmarkAd(withId: currentAd.id!)
                RootViewController.startLoadingIndicator()
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
        case .bookmarks:
            titleView.titleLabel.text = Localizer.string(for: .feedTitleBookmarks)
        case .organization(_):
            break
        case .profiles:
            titleView.titleLabel.text = Localizer.string(for: .feedTitleProfiles)
        }
        noAdsTitleLabel.text = Localizer.string(for: .feedNoAdsTitle)
        navigationItem.title = Localizer.string(for: .back)
    }
}

