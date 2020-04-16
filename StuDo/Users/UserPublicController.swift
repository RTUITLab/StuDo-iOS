//
//  UserPublicController.swift
//  StuDo
//
//  Created by Andrew on 9/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let userCellId = "userCellId"
fileprivate let profileCellId = "profileCellId"
fileprivate let adCellId = "adCellId"
fileprivate let reusableCellID = "reusableCellID"

class UserPublicController: UITableViewController {
    
    let client = APIClient()
    
    enum SectionInfo: String {
        case profileDescription
        case profiles
        case ads
    }
    
    let infoPositions: [SectionInfo] = [.profileDescription, .profiles, .ads]
    
    var user: User
    var profiles = [Profile]()
    var ads = [Ad]()
    
    let profilesInTableInitialLimit = 3
    var hideAllProfiles = true
    
    init(user: User) {
        self.user = user
        super.init(style: .grouped)
        client.delegate = self
        
        client.getProfiles(forUserWithId: user.id!)
        client.getAds(forUserWithId: user.id!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: userCellId)
        tableView.register(TableViewCellWithSubtitle.self, forCellReuseIdentifier: profileCellId)
        tableView.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: adCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reusableCellID)
        
        tableView.allowsMultipleSelection = false
        
        tabBarController?.hideTabBar()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.hideTabBar()
        if let selectedCellIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedCellIndexPath, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return infoPositions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = infoPositions[section]
        
        if currentSection == .profiles {
            if hideAllProfiles {
                return min(profiles.count, profilesInTableInitialLimit + 1)
            }
            return profiles.count
        } else if currentSection == .ads {
            return ads.count
        }
        
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = infoPositions[indexPath.section]
        
        switch currentSection {
        case .profileDescription:
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! CurrentUserTableViewCell
            cell.fullnameLabel.text = "\(user.firstName) \(user.lastName)"
            cell.generateProfileImage(for: user)
            cell.emailLabel.text = user.email
            cell.setupCell()
            cell.selectionStyle = .none
            return cell
        case .profiles:
            if hideAllProfiles && indexPath.row == profilesInTableInitialLimit {
                let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellID, for: indexPath)
                cell.accessoryType = .none
                cell.textLabel!.text = Localizer.string(for: .userShowAllProfiles)
                cell.textLabel!.textColor = .globalTintColor
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellId, for: indexPath)
            let currentProfile = profiles[indexPath.row]
            cell.textLabel?.text = currentProfile.name
            cell.detailTextLabel?.text = currentProfile.description
            return cell
        case .ads:
            let cell = tableView.dequeueReusableCell(withIdentifier: adCellId, for: indexPath) as! AdTableViewCell
            let currentAd = ads[indexPath.row]
            cell.titleLabel.text = currentAd.name
            cell.creatorLabel.text = Localizer.string(for: .feedPublishedBy) + " " + currentAd.creatorName
            cell.descriptionTextView.text = currentAd.shortDescription
            cell.dateLabel.text = currentAd.dateRange
            cell.moreButton.isHidden = true
            return cell
        }

    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = infoPositions[indexPath.section]
        
        if currentSection == .ads {
            let currentAd = ads[indexPath.row]
            let adVC = AdViewController(ad: currentAd)
            present(adVC, animated: true, completion: nil)
        } else if currentSection == .profiles {
            if hideAllProfiles && indexPath.row == profilesInTableInitialLimit {
                hideAllProfiles = false
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
                return
            }
            let currentProfile = profiles[indexPath.row]
            let profileVC = ProfileEditorViewController(profile: currentProfile, canEditProfile: false)
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentSection = infoPositions[section]
        
        if currentSection == .profiles && !profiles.isEmpty {
            return Localizer.string(for: .userPublicProfilesSectionHeader)
        } else if currentSection == .ads && !ads.isEmpty {
            return Localizer.string(for: .userPublicAdsSectionHeader)
        }
        return nil
    }

}


extension UserPublicController: APIClientDelegate {
    func apiClient(_ client: APIClient, didRecieveUser user: User) {
        self.user = user
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func apiClient(_ client: APIClient, didRecieveProfiles profiles: [Profile]) {
        self.profiles = profiles
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forUserWithId: String) {
        self.ads = ads
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
}
