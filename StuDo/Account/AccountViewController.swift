//
//  AccountViewController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let accountInfoCellID = "accountInfoCellID"
fileprivate let profileCellID = "profileCellID"
fileprivate let adCellID = "adCellID"
fileprivate let reusableCellID = "reusableCellID"
fileprivate let accountHeaderID = "accountHeaderID"
fileprivate let standartFooterID = "standartFooterID"


fileprivate enum SectionName: String {
    case myAccount
    case myProfiles = "My profiles"
    case organizations = "Organizations"
    case settingsAbout = "Settings & About"
}

fileprivate enum CellButtonTag: Int {
    case newProfile = 1
    case newAd = 2
}

class AccountViewController: UIViewController {
    
    var tableView: UITableView!
    
    var client = APIClient()
    
    let profilesInTableInitialLimit = 3
    var hideAllProfiles = true
    var ownProfiles = [Profile]()
    
    private var sections: [SectionName] = [.myAccount, .myProfiles, .settingsAbout]
    
    var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        view.backgroundColor = .white
        
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: accountInfoCellID)
        tableView.register(TableViewCellWithSubtitle.self, forCellReuseIdentifier: profileCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reusableCellID)

        tableView.register(AccountHeaderView.self, forHeaderFooterViewReuseIdentifier: accountHeaderID)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: standartFooterID)
        
        navigationItem.title = Localizer.string(for: .accountTitle)
        navigationItem.largeTitleDisplayMode = .never
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(_:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(forceUpdate(notification:)), name: AppDelegateNotification.forceDataUpdate.name, object: nil)
        
        requestDataUpdate()
        
    }
    
    deinit {
        print("AccountViewController deinitialized")
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func requestDataUpdate() {
        let currentUserId = PersistentStore.shared.user!.id!
        client.getProfiles(forUserWithId: currentUserId)
        client.getUser(id: currentUserId)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
        tabBarController?.showTabBar()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.showTabBar()
    }
    
    @objc func cellButtonTapped(_ button: UIButton) {
        if button.tag == CellButtonTag.newProfile.rawValue {
            presentProfileEditor(for: nil)
        }
    }
    
    func presentProfileEditor(for profile: Profile?) {
        let profileVC = ProfileEditorViewController(profile: profile)
        profileVC.delegate = self
        navigationController?.pushViewController(profileVC, animated: true)
    }

}




extension AccountViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print("Account VC: \(error.localizedDescription)")
    }
    
    func apiClient(_ client: APIClient, didReceiveProfiles profiles: [Profile]) {
        ownProfiles = profiles
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    func apiClient(_ client: APIClient, didDeleteProfileWithId profileId: String) {
        
        var deletedIndex: Int = -1
        for (index, profile) in ownProfiles.enumerated() {
            if profile.id == profileId {
                deletedIndex = index
                break
            }
        }
        
        let _ = ownProfiles.remove(at: deletedIndex)
        tableView.deleteRows(at: [IndexPath(row: deletedIndex, section: 1)], with: .automatic)
        
    }
    
    
    func apiClient(_ client: APIClient, didReceiveUser user: User) {
        PersistentStore.shared.user = user
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
}




extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .myProfiles {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section]

        if sectionInfo == .myProfiles && editingStyle == .delete {
            let profileToRemove = ownProfiles[indexPath.row]
            client.deleteProfile(withId: profileToRemove.id!)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    

    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionInfo = sections[section]
        
        if sectionInfo == .myProfiles {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: accountHeaderID) as! AccountHeaderView
            
            header.sectionTitle = Localizer.string(for: .accountMyProfiles)
            
            if sectionInfo == .myProfiles {
                header.actionButton.setTitle(Localizer.string(for: .accountAddNewProfile), for: .normal)
                header.actionButton.tag = CellButtonTag.newProfile.rawValue
            }
            
            header.actionButton.addTarget(self, action: #selector(cellButtonTapped(_:)), for: .touchUpInside)

            return header
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionInfo = sections[section]
        if sectionInfo == .myProfiles {
            return Localizer.string(for: .accountProfileSectionDescription)
        } else if sectionInfo == .organizations {
            return Localizer.string(for: .accountOrganizationsSectionDescription)
        }
        return nil
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionInfo = sections[section]

        if sectionInfo == .myAccount {
            return 0
        } else if sectionInfo == .myProfiles {
            return 44
        }
        
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        let sectionInfo = sections[section]
        if sectionInfo == .myAccount {
            return 28
        }
        
        return UITableView.automaticDimension
    }
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = sections[section]
        
        if sectionInfo == .myProfiles {
            if hideAllProfiles {
                return min(ownProfiles.count, profilesInTableInitialLimit + 1)
            }
            return ownProfiles.count
        } else if sectionInfo == .settingsAbout {
            return 2
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = sections[indexPath.section]
        if sectionInfo == .myAccount {
            let cell = tableView.dequeueReusableCell(withIdentifier: accountInfoCellID, for: indexPath) as! CurrentUserTableViewCell
            let user = PersistentStore.shared.user!
            cell.fullnameLabel.text = user.firstName + " " + user.lastName
            cell.generateProfileImage(for: user)
            cell.emailLabel.text = user.email
            emailLabel = cell.emailLabel
            cell.setupCell()
            cell.accessoryType = .disclosureIndicator
            return cell
        } else if sectionInfo == .myProfiles {
            if hideAllProfiles && indexPath.row == profilesInTableInitialLimit {
                let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellID, for: indexPath)
                cell.accessoryType = .none
                cell.textLabel!.text = Localizer.string(for: .userShowAllProfiles)
                cell.textLabel!.textColor = .globalTintColor
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellID, for: indexPath)
            let profile = ownProfiles[indexPath.row]
            cell.textLabel?.text = profile.name
            cell.detailTextLabel?.text = profile.description
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellID, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel!.textColor = .label
        
        if sectionInfo == .organizations {
            cell.textLabel?.text = Localizer.string(for: .accountOrganizations)
        } else if sectionInfo == .settingsAbout {
            if indexPath.row == 0 {
                cell.textLabel?.text = Localizer.string(for: .accountSettings)
            } else if indexPath.row == 1 {
                cell.textLabel?.text = Localizer.string(for: .accountAbout)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .myAccount {
            let detailVC = AccountDetailViewController(style: .grouped)
            detailVC.accountViewController = self
            navigationController?.pushViewController(detailVC, animated: true)
        } else if sectionInfo == .myProfiles {
            if hideAllProfiles && indexPath.row == profilesInTableInitialLimit {
                hideAllProfiles = false
                var pathsToUpdate = [IndexPath]()
                for i in profilesInTableInitialLimit + 1 ..< ownProfiles.count {
                    pathsToUpdate.append(IndexPath(item: i, section: indexPath.section))
                }
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(item: profilesInTableInitialLimit, section: indexPath.section)], with: .fade)
                tableView.insertRows(at: pathsToUpdate, with: .fade)
                tableView.endUpdates()
                return
            }
            let selectedProfile = ownProfiles[indexPath.row]
            presentProfileEditor(for: selectedProfile)
        } else if sectionInfo == .organizations {
            let organizationsVC = OrganizationListController(style: .plain)
            navigationController?.pushViewController(organizationsVC, animated: true)
        } else if sectionInfo == .settingsAbout {
            if indexPath.row == 0 {
                let settingsVC = SettingsViewController(style: .grouped)
                navigationController?.pushViewController(settingsVC, animated: true)
            } else if indexPath.row == 1 {
                let aboutVC = AboutViewController(style: .grouped)
                navigationController?.pushViewController(aboutVC, animated: true)
            }
        }
    }
    
    
    
}







extension AccountViewController: ProfileEditorVCDelegate {
    func profileEditorViewController(_ profileVC: ProfileEditorViewController, didCreateProfile createdProfile: Profile) {
        ownProfiles.append(createdProfile)
        let lastItemIndex = ownProfiles.count - 1
        let indexPath = IndexPath(row: lastItemIndex, section: 1)
        tableView.insertRows(at: [indexPath], with: .top)
    }
    
    func profileEditorViewController(_ profileVC: ProfileEditorViewController, didDeleteProfile deletedProfile: Profile) {
        guard let selectedRowsIndexPath = tableView.indexPathsForSelectedRows else { return }
        
        for indexPath in selectedRowsIndexPath {
            if ownProfiles[indexPath.row].id == deletedProfile.id {
                ownProfiles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func profileEditorViewController(_ profileVC: ProfileEditorViewController, didUpdateProfile updatedProfile: Profile) {
        guard let selectedRowsIndexPath = tableView.indexPathsForSelectedRows else { return }
        
        for indexPath in selectedRowsIndexPath {
            if ownProfiles[indexPath.row].id == updatedProfile.id {
                ownProfiles[indexPath.row] = updatedProfile
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    
}





extension AccountViewController {
    @objc func languageDidChange(_ nofication: Notification) {
        tableView.reloadData()
        navigationItem.title = Localizer.string(for: .accountTitle)
    }
    
    @objc private func forceUpdate(notification: Notification) {
        requestDataUpdate()
    }
}
