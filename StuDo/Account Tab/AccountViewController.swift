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

fileprivate enum CellButtonTag: Int {
    case newProfile = 1
    case newAd = 2
}

class AccountViewController: UIViewController {
    
    var tableView: UITableView!
    
    var client = APIClient()
    
    var ownAds = [Ad]()
    var ownProfiles = [Profile]()
    
    var shouldRefreshOnAppear: Bool = true
    
    private var sections: [SectionName] = [.myAccount, .myProfiles, .myAds]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        view.backgroundColor = .white
        
        
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
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if shouldRefreshOnAppear {
            refreshInfo()
        } else if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
            shouldRefreshOnAppear = true
        }
    }
    
    @objc func cellButtonTapped(_ button: UIButton) {
        if button.tag == CellButtonTag.newProfile.rawValue {
            createNewProfile()
        } else if button.tag == CellButtonTag.newAd.rawValue {
            presentAdViewer(for: nil)
        }
    }
    
    func createNewProfile() {
        let alert = UIAlertController(title: "New Profile", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Description"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let name = alert!.textFields!.first!.text!
            let description = alert!.textFields!.last!.text!
            self.client.create(profile: Profile(name: name, description: description))
            print("Name: \(name)")
            print("Description: \(description)")
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAdViewer(for ad: Ad?) {
        let detailVC = AdViewController(with: ad)
        detailVC.delegate = self
        if ad == nil {
            detailVC.currentMode = .editing
            detailVC.shouldAppearFullScreen = true
        }
        
        self.present(detailVC, animated: true, completion: nil)
        shouldRefreshOnAppear = false
    }
    
    
    
    func refreshInfo() {
        if GCIsUsingFakeData {
            let mockup = DataMockup()
            ownAds = mockup.getPrototypeAds(count: 1, withUserId: "fakeUserID")
        } else {
            if tableView != nil {
                client.getAds(forUserWithId: PersistentStore.shared.user!.id!)
            }
        }
    }

}




extension AccountViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print("Account VC: \(error.localizedDescription)")
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        ownAds = ads
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
            
            if sectionInfo == .myProfiles {
                header.actionButton.setTitle("New Profile", for: .normal)
                header.actionButton.tag = CellButtonTag.newProfile.rawValue
            } else if sectionInfo == .myAds {
                header.actionButton.setTitle("New Ad", for: .normal)
                header.actionButton.tag = CellButtonTag.newAd.rawValue
            }
            
            header.actionButton.addTarget(self, action: #selector(cellButtonTapped(_:)), for: .touchUpInside)

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
            let detailVC = AccountDetailViewController(style: .grouped)
            detailVC.hidesBottomBarWhenPushed = true
            detailVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(detailVC, animated: true)
        } else if sectionInfo == .myAds {
            let selectedAd = ownAds[indexPath.row]
            presentAdViewer(for: selectedAd)
        }
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





extension AccountViewController: AdViewControllerDelegate {
    func adViewController(_ adVC: AdViewController, didDeleteAd deletedAd: Ad) {
        guard let selectedRowsIndexPath = tableView.indexPathsForSelectedRows else { return }
        
        for indexPath in selectedRowsIndexPath {
            if ownAds[indexPath.row].id == deletedAd.id {
                ownAds.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func adViewController(_ adVC: AdViewController, didUpdateAd updatedAd: Ad) {
        guard let selectedRowsIndexPath = tableView.indexPathsForSelectedRows else { return }
        
        for indexPath in selectedRowsIndexPath {
            if ownAds[indexPath.row].id == updatedAd.id {
                ownAds[indexPath.row] = updatedAd
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func adViewController(_ adVC: AdViewController, didCreateAd createdAd: Ad) {
        ownAds.insert(createdAd, at: 0)
        let myAdsSectionNumber = 2 // Change it later to more understandable constant
        let indexPath = IndexPath(row: 0, section: myAdsSectionNumber)
        tableView.insertRows(at: [indexPath], with: .top)
    }
    
}
