//
//  AdsViewController.swift
//  StuDo
//
//  Created by Andrew on 4/15/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

fileprivate let adNavigationCellID = "adNavigationCellID"
fileprivate let collectionCellID = "collectionCellID"
fileprivate let adCellID = "adCellID"

class AdsViewController: UICollectionViewController {
    
    // -------------------------------------
    // MARK: - Properties
    
    enum AdSection: Int, Equatable, CaseIterable {
        case all = 0
        case own
        case bookmarked
    }
    
    private let contentSections: [AdSection] = [.all, .own, .bookmarked]
    private var currentSection: Int = 0
    
    lazy private var feedItems: [[Ad]] = {
        var items = [[Ad]]()
        for _ in contentSections {
            items.append([])
        }
        return items
    }()
    
    private let client = APIClient()
    
    var isInitialTableViewLoad = true
    
    let adNavigationCollectionViewHeight: CGFloat = 44
    let adNavigationView = AdNavigationView()
    var adNavigationCollectionView: UICollectionView {
        adNavigationView.collectionView
    }
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // -------------------------------------
    // MARK: - Methods
    
    
    
    // MARK: Lifecycle
    
    init() {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        super.init(collectionViewLayout: layout)
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(notification:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(notification:)), name: PersistentStoreNotification.themeDidChange.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(forceUpdate(notification:)), name: AppDelegateNotification.forceDataUpdate.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    deinit {
        print("AdsViewController deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        collectionView!.register(CollectionViewCellWithTableView.self, forCellWithReuseIdentifier: collectionCellID)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemBackground
        
        setupAdNavigationCollectionView()

        client.delegate = self
        requestUpdate(adSection: .all)
        requestUpdate(adSection: .own)
        requestUpdate(adSection: .bookmarked)
        
        initialLayout()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideRefreshControls()
    }
    
    // MARK: Data
    
    private func setCurrentSection(from offset: CGPoint) {
        let newSection = Int(offset.x / self.collectionView.frame.width)
        guard currentSection != newSection else { return }
        
        adNavigationCollectionView.deselectItem(at: IndexPath(item: currentSection, section: 0), animated: true)
        adNavigationCollectionView.selectItem(at: IndexPath(item: newSection, section: 0), animated: true, scrollPosition: .right)
        print("section: \(currentSection) to \(newSection)")
        currentSection = newSection
    }
    
    public func requestUpdateForAllSections() {
        let sections = AdSection.allCases
        for section in sections {
            requestUpdate(adSection: section)
        }
    }
    
    private func reloadAllTables() {
        collectionView.reloadData()
    }
    
    private func reloadTable(for index: Int, fullReload: Bool = false) {
        DispatchQueue.main.async {
            print("trying update: \(index)")
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CollectionViewCellWithTableView {
                print("updated section: \(index) - background hidden \(!self.feedItems[index].isEmpty)")
                cell.tableView.backgroundView?.isHidden = !self.feedItems[index].isEmpty
                cell.tableView.refreshControl?.endRefreshing()
                if fullReload {
                    cell.tableView.reloadData()
                }
            }
        }
    }
    
    fileprivate func update(ads: [Ad], for adSection: AdSection, shouldUpdateTable: Bool = true) {
        isInitialTableViewLoad = false
        let index = adSection.rawValue
        feedItems[index] = ads
        reloadTable(for: index, fullReload: shouldUpdateTable)
    }
    
    fileprivate func requestUpdate(adSection: AdSection) {
        switch adSection {
        case .all:
            client.getAds()
        case .own:
            client.getAds(forUserWithId: PersistentStore.shared.user.id!)
        case .bookmarked:
            client.getBookmarkedAds()
        }
    }
    
    fileprivate func requestUpdate(adSection: AdSection, ifContains adId: String) {
        if feedItems[adSection.rawValue].contains(where: {$0.id == adId}) {
            requestUpdate(adSection: .all)
        }
    }
    
    fileprivate func requestUpdate(forAllSectionsExcept excludedSection: AdSection) {
        let sections = AdSection.allCases.filter({ $0 != excludedSection})
        for section in sections {
            requestUpdate(adSection: section)
        }
    }
    
    // MARK: Views & Layout
    
    private func initialLayout() {
        view.addSubview(adNavigationView)
        adNavigationView.translatesAutoresizingMaskIntoConstraints = false
        adNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        adNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        adNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        adNavigationView.heightAnchor.constraint(equalToConstant: adNavigationCollectionViewHeight).isActive = true
    }
    
    private func hideRefreshControls() {
        for index in 0...2 {
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CollectionViewCellWithTableView {
                cell.tableView.refreshControl?.beginRefreshing()
                cell.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func infoView(for section: AdSection) -> BackgroundInfoView {
        let infoView = BackgroundInfoView()
        switch section {
        case .all:
            infoView.titleLabel.text = Localizer.string(for: .feedNoAdsTitle)
            infoView.descriptionLabel.text = Localizer.string(for: .feedNoAdsDescription)
        case .own:
            infoView.titleLabel.text = Localizer.string(for: .feedNoAdsTitle)
            infoView.descriptionLabel.text = Localizer.string(for: .feedNoOwnAdsDescription)
        case .bookmarked:
            infoView.titleLabel.text = Localizer.string(for: .feedNoAdsTitle)
            infoView.descriptionLabel.text = Localizer.string(for: .feedNoBookmarkedAdsDescription)
        }
        infoView.isHidden = true
        return infoView
    }
    
    fileprivate func presentAdViewer(_ selectedAd: Ad, userInfo: [String: Any]? = nil, startInEditorMode: Bool = false) {
        
        let detailVC = AdViewController(ad: selectedAd)
        detailVC.clientUserInfo = userInfo
        
        if startInEditorMode {
            detailVC.currentState = .editing
        }
        
        impactFeedback.impactOccurred()
        
        self.present(detailVC, animated: true, completion: nil)
    }
    
    fileprivate func setupAdNavigationCollectionView() {
        
        adNavigationCollectionView.register(AdNavigationCell.self, forCellWithReuseIdentifier: adNavigationCellID)
        adNavigationCollectionView.dataSource = self
        adNavigationCollectionView.delegate = self
        
        adNavigationCollectionView.selectItem(at: IndexPath(item: currentSection, section: 0), animated: false, scrollPosition: .right)
    }
    
    // MARK: Observers & Actions
    
    @objc private func languageDidChange(notification: Notification) {
        navigationItem.title = Localizer.string(for: .back)
        adNavigationView.reloadCollectionView()
        setupAdNavigationCollectionView()
        reloadAllTables()
    }
    
    @objc private func themeDidChange(notification: Notification) {
        adNavigationView.reloadCollectionView()
        setupAdNavigationCollectionView()
        reloadAllTables()
    }
    
    @objc private func forceUpdate(notification: Notification) {
        requestUpdateForAllSections()
    }
    
    @objc private func appWillResignActive(notification: Notification) {
        hideRefreshControls()
    }
    
    @objc private func refreshTriggered(_ refreshControl: UIRefreshControl) {
        requestUpdateForAllSections()
    }
    
}

// MARK: - APIClientDelegate

extension AdsViewController: APIClientDelegate {
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print("Feed VC: \(error.localizedDescription)")
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    func apiClient(_ client: APIClient, didReceiveAds ads: [Ad]) {
        update(ads: ads, for: .all)
    }
    
    func apiClient(_ client: APIClient, didReceiveAds ads: [Ad], forUserWithId: String) {
        update(ads: ads, for: .own)
    }
    
    func apiClient(_ client: APIClient, didReceiveBookmarkedAds ads: [Ad]) {
        update(ads: ads, for: .bookmarked)
    }
    
    
    
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String, userInfo: [String : Any]? = nil) {
        RootViewController.stopLoadingIndicator(with: .success)
        
        guard let tableView = userInfo?["tableView"] as? UITableView,
            let indexPath = userInfo?["indexPath"] as? IndexPath,
            let currentSection = AdSection(rawValue: tableView.tag) else { return }
        
        DispatchQueue.main.async {
            var updatedFeedItems = self.feedItems[tableView.tag]
            updatedFeedItems.remove(at: indexPath.row)
            self.update(ads: updatedFeedItems, for: currentSection, shouldUpdateTable: false)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        requestUpdate(forAllSectionsExcept: currentSection)
        
    }
    
    func apiClient(_ client: APIClient, didUnbookmarkAdWithId adId: String, userInfo: [String : Any]?) {
        RootViewController.stopLoadingIndicator(with: .success)
        let section = AdSection(rawValue: currentSection)!
        if section == .bookmarked {
            if let tableView = userInfo?["tableView"] as? UITableView,
                let indexPath = userInfo?["indexPath"] as? IndexPath {
                DispatchQueue.main.async {
                    var updatedFeedItems = self.feedItems[AdSection.bookmarked.rawValue]
                    updatedFeedItems.remove(at: indexPath.row)
                    self.update(ads: updatedFeedItems, for: .bookmarked, shouldUpdateTable: false)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        } else {
            requestUpdate(adSection: .bookmarked)
        }
        requestUpdate(adSection: .all, ifContains: adId)
        requestUpdate(adSection: .own, ifContains: adId)
    }
    
    func apiClient(_ client: APIClient, didBookmarkAdWithId adId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        requestUpdate(adSection: .all, ifContains: adId)
        requestUpdate(adSection: .own, ifContains: adId)
        requestUpdate(adSection: .bookmarked)
    }
    
    func apiClient(_ client: APIClient, didReceiveUser user: User) {
        let userVC = UserPublicController(user: user)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    
    
}

// MARK: - Collection View

extension AdsViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentSections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === adNavigationCollectionView {
            return dequeueNavigationCell(indexPath: indexPath)
        }
        return dequeueCellWithTable(indexPath: indexPath)
        
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === self.collectionView {
            let yInsets = view.safeAreaInsets.top + view.safeAreaInsets.bottom
            return CGSize(width: collectionView.frame.width, height: view.frame.height - yInsets)
        }
        
        return CGSize(width: 80, height: collectionView.frame.height)
        
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard collectionView === adNavigationCollectionView else { return false }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView === adNavigationCollectionView else { return }
        self.collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView === self.collectionView,
            let cell = cell as? CollectionViewCellWithTableView else { return }
        if !isInitialTableViewLoad {
            cell.tableView.backgroundView?.isHidden = !self.feedItems[indexPath.item].isEmpty
        } else {
            cell.tableView.backgroundView?.isHidden = true
        }
        cell.tableView.refreshControl?.endRefreshing()
        cell.tableView.reloadData()
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === self.collectionView else { return }
        let targetOffset = targetContentOffset.pointee
        setCurrentSection(from: targetOffset)
    }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        setCurrentSection(from: scrollView.contentOffset)
//    }
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === self.collectionView else { return }
        setCurrentSection(from: scrollView.contentOffset)
    }
    
    
    // MARK: Support methods
    
    private func dequeueCellWithTable(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID, for: indexPath) as! CollectionViewCellWithTableView
        
        let tableView = cell.tableView
        
        cell.tableSetupClosure = { [unowned self] in
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: adCellID)
            
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(self.refreshTriggered(_:)), for: .valueChanged)
            tableView.refreshControl = refreshControl
            
            tableView.separatorInset = .zero
            tableView.tableFooterView = UIView()
            tableView.estimatedRowHeight = 140
            tableView.rowHeight = UITableView.automaticDimension
            tableView.showsVerticalScrollIndicator = false
            
            tableView.contentInset = UIEdgeInsets(top: self.adNavigationCollectionViewHeight, left: 0, bottom: 0, right: 0)
            
            tableView.reloadData()
        }
        
        tableView.tag = indexPath.item
        
        tableView.backgroundView = nil
        if let section = AdSection(rawValue: indexPath.item) {
            tableView.backgroundView = infoView(for: section)
        }
        
        return cell
    }
    
    private func dequeueNavigationCell(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = adNavigationCollectionView.dequeueReusableCell(withReuseIdentifier: adNavigationCellID, for: indexPath) as! AdNavigationCell
        
        if let section = AdSection(rawValue: indexPath.item) {
            switch section {
            case .all:
                cell.label.text = Localizer.string(for: .navigationMenuAllAds)
            case .own:
                cell.label.text = Localizer.string(for: .navigationMenuMyAds)
            case .bookmarked:
                cell.label.text = Localizer.string(for: .navigationMenuBookmarks)
            }
        }
                        
        return cell
    }
    
    
}



// MARK: - Table View

extension AdsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems[tableView.tag].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: adCellID, for: indexPath) as! AdTableViewCell
        
        let currentAd = feedItems[tableView.tag][indexPath.row]
        cell.titleLabel.text = currentAd.name
        cell.creatorLabel.text = Localizer.string(for: .feedPublishedBy) + " " + currentAd.creatorName
        cell.descriptionTextView.attributedText = TextFormatter.parseMarkdownString(currentAd.shortDescription, fontWeight: .light)
        cell.dateLabel.text = currentAd.dateRange
        cell.moreButtonCallback = { [weak self] in
            guard let self = self else { return }
            self.moreButtonTappedInCell(tableView: tableView, adId: currentAd.id)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAd = feedItems[tableView.tag][indexPath.row]
        let userInfo: [String: Any] = [
            "indexPath": indexPath,
            "tableView": tableView
        ]
        presentAdViewer(selectedAd, userInfo: userInfo)
    }
    
    
}

// MARK: - Views Responses

extension AdsViewController {
    
    fileprivate func moreButtonTappedInCell(tableView: UITableView, adId: String) {
        guard let rowIndex = feedItems[tableView.tag].firstIndex(where: {$0.id == adId}) else { return }
        let currentAd = feedItems[tableView.tag][rowIndex]
        
        let userInfo: [String: Any] = [
            "indexPath": IndexPath(row: rowIndex, section: 0),
            "tableView": tableView
        ]
        
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
                self.client.unbookmarkAd(withId: currentAd.id!, userInfo: userInfo)
                RootViewController.startLoadingIndicator()
            }))
        } else {
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorAddToBookmarks), style: .default, handler: { _ in
                self.client.bookmarkAd(withId: currentAd.id!)
                RootViewController.startLoadingIndicator()
            }))
        }
        
        if currentAd.userId == PersistentStore.shared.user.id {
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorEditAd), style: .default, handler: { _ in
                self.presentAdViewer(currentAd, userInfo: userInfo, startInEditorMode: true)
            }))
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorDeleteAd), style: .destructive, handler: { _ in
                self.client.deleteAd(withId: currentAd.id, userInfo: userInfo)
                RootViewController.startLoadingIndicator()
            }))
        }
        
        alert.addAction(UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
