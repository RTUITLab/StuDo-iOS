//
//  PublicProfilesViewController.swift
//  StuDo
//
//  Created by Andrew on 4/15/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

fileprivate let profileCellID = "profileCellID"

class PublicProfilesViewController: UITableViewController {
    
    private var profiles = [Profile]()
    private let client = APIClient()
    private let infoView = BackgroundInfoView()
    
    // MARK: Lifecycle
    
    deinit {
        print("PublicProfilesViewController deinitialized")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !profiles.isEmpty {
            requestDataRefresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client.delegate = self
        requestDataRefresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(notification:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(forceUpdate(notification:)), name: AppDelegateNotification.forceDataUpdate.name, object: nil)
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(requestDataRefresh), for: .valueChanged)
        
        tableView.register(TableViewCellWithSubtitle.self, forCellReuseIdentifier: profileCellID)
        tableView.tableFooterView = UIView()
        
        updateBackgroundInfoView()
        tableView.backgroundView = infoView
    }
    
    // MARK: Data
    
    fileprivate func set(_ profiles: [Profile]) {
        self.profiles = profiles
        infoView.isHidden = !profiles.isEmpty
        tableView.reloadData()
    }
    
    @objc private func requestDataRefresh() {
        client.getProfiles()
    }
    
    private func updateBackgroundInfoView() {
        infoView.titleLabel.text = Localizer.string(for: .feedNoProfilesTitle)
        infoView.descriptionLabel.text = Localizer.string(for: .feedNoProfilesDescription)
    }
    
    // MARK: Observers
    
    @objc private func languageDidChange(notification: Notification) {
        navigationItem.title = Localizer.string(for: .back)
        updateBackgroundInfoView()
        tableView.reloadData()
    }
    
    @objc private func forceUpdate(notification: Notification) {
        requestDataRefresh()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: profileCellID, for: indexPath)
        let profile = profiles[indexPath.row]
        cell.textLabel?.text = profile.name
        cell.detailTextLabel?.text = profile.description
        
        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentProfile = profiles[indexPath.row]
        let profileVC = ProfileEditorViewController(profile: currentProfile, canEditProfile: false, shouldShowUserPage: true)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    

}


extension PublicProfilesViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print("Feed VC: \(error.localizedDescription)")
        refreshControl?.endRefreshing()
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    func apiClient(_ client: APIClient, didRecieveProfiles profiles: [Profile]) {
        set(profiles)
        refreshControl?.endRefreshing()
    }
}
