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
    
    enum AdSection: Int, Equatable {
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
        collectionView.backgroundColor = .secondarySystemBackground
        
        adNavigationCollectionView.register(AdNavigationCell.self, forCellWithReuseIdentifier: adNavigationCellID)
        adNavigationCollectionView.dataSource = self
        adNavigationCollectionView.delegate = self
        adNavigationCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)

        client.delegate = self
        requestUpdate(adSection: .all)
        requestUpdate(adSection: .own)
        requestUpdate(adSection: .bookmarked)
        
        initialLayout()
        
    }
    
    // MARK: Data
    
    private func updateTable(for index: Int) {
        DispatchQueue.main.async {
            if let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CollectionViewCellWithTableView {
                cell.tableView.reloadData()
                cell.tableView.backgroundView?.isHidden = !self.feedItems[index].isEmpty
                cell.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    fileprivate func update(ads: [Ad], for adSection: AdSection) {
        isInitialTableViewLoad = false
        let index = adSection.rawValue
        feedItems[index] = ads
        updateTable(for: index)
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
    
    // MARK: Views & Layout
    
    private func initialLayout() {
        view.addSubview(adNavigationView)
        adNavigationView.translatesAutoresizingMaskIntoConstraints = false
        adNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        adNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        adNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        adNavigationView.heightAnchor.constraint(equalToConstant: adNavigationCollectionViewHeight).isActive = true
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
        return infoView
    }
    
    // MARK: Observers & Actions
    
    @objc private func languageDidChange(notification: Notification) {
        navigationItem.title = Localizer.string(for: .back)
        adNavigationCollectionView.reloadData()
    }
    
    @objc private func refreshTriggered(_ refreshControl: UIRefreshControl) {
        guard let tableView = refreshControl.superview as? UITableView,
            let section = AdSection(rawValue: tableView.tag) else { return }
        requestUpdate(adSection: section)
    }
    
}

// MARK: - APIClientDelegate

extension AdsViewController: APIClientDelegate {
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print("Feed VC: \(error.localizedDescription)")
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        update(ads: ads, for: .all)
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forUserWithId: String) {
        update(ads: ads, for: .own)
    }
    
    func apiClient(_ client: APIClient, didRecieveBookmarkedAds ads: [Ad]) {
        update(ads: ads, for: .bookmarked)
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
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard scrollView === self.collectionView else { return }
        let targetOffset = targetContentOffset.pointee
        let index = Int(targetOffset.x / self.collectionView.frame.width)
        adNavigationCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .right)
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
        
        if let section = AdSection(rawValue: indexPath.item) {
            tableView.backgroundView = infoView(for: section)
            if !isInitialTableViewLoad {
                tableView.backgroundView!.isHidden = !self.feedItems[indexPath.item].isEmpty
            }
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
            self.moreButtonTappedInCell(tableIndex: tableView.tag, rowIndex: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    
    
}

// MARK: - Views Responses

extension AdsViewController {
    
    fileprivate func moreButtonTappedInCell(tableIndex: Int, rowIndex: Int) {
        
        let currentAd = feedItems[tableIndex][rowIndex]
        
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
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorEditAd), style: .default, handler: { _ in
                //                self.presentAdViewer(currentAd, startInEditorMode: true)
            }))
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorDeleteAd), style: .destructive, handler: { _ in
                //                self.indexPathUnderChange = indexPath
                self.client.deleteAd(withId: currentAd.id)
                RootViewController.startLoadingIndicator()
            }))
        }
        
        alert.addAction(UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
