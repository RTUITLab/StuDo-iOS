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

enum SectionName: String {
    case myAccount
    case myAds = "My ads"
    case myProfiles = "My profiles"
    case logOut = "Log out"
}

class AccountViewController: UIViewController {
    
    var account: PrivateAccountInfo?
    
    var tableView: UITableView!
    
    var sections: [SectionName] = [.myAccount, .myProfiles, .myAds, .logOut]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = DataMockup().getPrototypeAccount()
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: accountInfoCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: adCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: profileCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reusableCellID)

        
        navigationItem.title = "My Account"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(handleSettingsButtonTap))
//        navigationItem.rightBarButtonItem = settingsButton
    }
    
    @objc func handleSettingsButtonTap() {
        let detailVC = UIViewController()
        detailVC.view.backgroundColor = .white
        detailVC.hidesBottomBarWhenPushed = true
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailVC, animated: true)
    }

}


extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = sections[section]

        if sectionInfo == .myProfiles || sectionInfo == .myAds {
            return sectionInfo.rawValue
        }
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = sections[section]
        
        if sectionInfo == .myProfiles, let profiles = account?.profiles {
            return profiles.count
        } else if sectionInfo == .myAds, let ads = account?.ads {
            return ads.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = sections[indexPath.section]
        if sectionInfo == .myAccount {
            let cell = tableView.dequeueReusableCell(withIdentifier: accountInfoCellID, for: indexPath)
            let user = PersistentStore.shared.user!
            cell.textLabel?.text = user.firstName + " " + user.lastName
            cell.accessoryType = .disclosureIndicator
            return cell
        } else if sectionInfo == .myProfiles {
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellID, for: indexPath)
            cell.textLabel?.text = account?.profiles?[indexPath.row].briefDescription
            return cell
        } else if sectionInfo == .myAds {
            let cell = tableView.dequeueReusableCell(withIdentifier: adCellID, for: indexPath)
            cell.textLabel?.text = account?.ads?[indexPath.row].headline
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellID, for: indexPath)
        cell.textLabel?.text = sectionInfo.rawValue
        cell.accessoryType = .disclosureIndicator
        
        if sectionInfo == .logOut {
            cell.textLabel?.textColor = .red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .myAccount {
            let detailVC = AccountDetailViewController()
            detailVC.hidesBottomBarWhenPushed = true
            detailVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
