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

fileprivate enum SectionName: String {
    case myAccount
    case myAds = "My ads"
    case myProfiles = "My profiles"
    case logOut = "Log out"
}

class AccountViewController: UIViewController {
    
    
    var tableView: UITableView!
    
    var client = APIClient()
    
    var ownAds = [Ad]()
    var ownProfiles = [Profile]()
    
    private var sections: [SectionName] = [.myAccount, .myProfiles, .myAds]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: accountInfoCellID)
        tableView.register(AdTableViewCell.self, forCellReuseIdentifier: adCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: profileCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reusableCellID)

        tableView.register(AccountHeaderView.self, forHeaderFooterViewReuseIdentifier: accountHeaderID)
        
        navigationItem.title = "My Account"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if PersistentStore.shared.user != nil {
            refreshInfo()
        }
        
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
    
    @objc func newProfileButtonTapped(_ button: UIButton) {
        
    }
    
    @objc func newAddButtonTapped(_ button: UIButton) {
        
    }
    
    
    
    func refreshInfo() {
        if GCIsUsingFakeData {
            let mockup = DataMockup()
            ownAds = mockup.getPrototypeAds(count: 1, withUserId: "fakeUserID")
            ownProfiles = mockup.getPrototypePeople(count: 2)
        } else {
            client.delegate = self
            if tableView != nil {
                client.getAdds()
            }
        }
    }

}


extension AccountViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error)
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        for ad in ads {
            if ad.userId == PersistentStore.shared.user?.id {
                ownAds.append(ad)
            }
        }
        
        tableView.reloadData()
    }
}


extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .myAds {
            return 100
        } else if sectionInfo == .myAccount{
            return UITableView.automaticDimension
        } else {
            return 46
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionInfo = sections[section]
        
        if sectionInfo == .myProfiles || sectionInfo == .myAds {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: accountHeaderID) as! AccountHeaderView
            
            header.sectionTitle = sectionInfo.rawValue
            
            let title: String = "Add New"
            if sectionInfo == .myProfiles {
                
                header.actionButton.addTarget(self, action: #selector(newProfileButtonTapped(_:)), for: .touchUpInside)

            } else if sectionInfo == .myAds {
                
                header.actionButton.addTarget(self, action: #selector(newAddButtonTapped(_:)), for: .touchUpInside)
            }
            
            header.actionButton.setTitle(title, for: .normal)
            
            return header
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionInfo = sections[section]
        
        if sectionInfo == .myAds || sectionInfo == .myProfiles {
            return 60
        }
        
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = sections[section]
        
        if sectionInfo == .myProfiles {
            return ownProfiles.count
        } else if sectionInfo == .myAds {
            return ownAds.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = sections[indexPath.section]
        if sectionInfo == .myAccount {
            let cell = tableView.dequeueReusableCell(withIdentifier: accountInfoCellID, for: indexPath) as! CurrentUserTableViewCell
            let user = PersistentStore.shared.user!
            cell.fullnameLabel.text = user.firstName + " " + user.lastName
            cell.profileImage.image = #imageLiteral(resourceName: "person")
            cell.emailLabel.text = user.email
            cell.setupCell()
            cell.accessoryType = .disclosureIndicator
            return cell
        } else if sectionInfo == .myProfiles {
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellID, for: indexPath)
            cell.textLabel?.text = ownProfiles[indexPath.row].briefDescription
            return cell
        } else if sectionInfo == .myAds {
            let cell = tableView.dequeueReusableCell(withIdentifier: adCellID, for: indexPath) as! AdTableViewCell
            let ad = ownAds[indexPath.row]
            cell.titleLabel.text = ad.name
            cell.shortDescriptionLabel.text = ad.shortDescription
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
        } else if sectionInfo == .myAds {
            let detailVC = AdViewController()
            detailVC.advertisement = ownAds[indexPath.row]
            self.present(detailVC, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        let sectionInfo = sections[section]
//
//        if sectionInfo == .myAds {
//            return "The active ads that you created."
//        } else if sectionInfo == .myProfiles {
//            return "The profiles you create help others find you by the skills you have. Add as many profiles as you like."
//        }
//
//        return nil
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 70
//    }
}




