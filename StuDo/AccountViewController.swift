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

fileprivate enum SectionName: String {
    case myAccount
    case myAds = "My ads"
    case myProfiles = "My profiles"
    case logOut = "Log out"
}

class AccountViewController: UIViewController {
    
    var account: PrivateAccountInfo?
    
    var animator = CardTransitionAnimator()
    
    var tableView: UITableView!
    
    private var sections: [SectionName] = [.myAccount, .myProfiles, .myAds]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = DataMockup().getPrototypeAccount()
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: accountInfoCellID)
        tableView.register(AdTableViewCell.self, forCellReuseIdentifier: adCellID)
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
            cell.textLabel?.text = account?.profiles?[indexPath.row].briefDescription
            return cell
        } else if sectionInfo == .myAds {
            let cell = tableView.dequeueReusableCell(withIdentifier: adCellID, for: indexPath) as! AdTableViewCell
            cell.titleLabel.text = account?.ads?[indexPath.row].headline
            cell.shortDescriptionLabel.text = account?.ads?[indexPath.row].description
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
            
            // Here the code changed ad's id so that it equals to current user's id
            // and enables the user to edit the ad. Change it in the real app
            
            if let adToShow = account?.ads?[indexPath.row] {
                
                let detailVC = AdViewController()

                detailVC.showedAd = Ad(id: "", name: adToShow.headline, description: adToShow.description, shortDescription: adToShow.description, beginTime: nil, endTime: nil, userId: PersistentStore.shared.user!.id!, user: nil, organizationId: nil, organization: nil)
                
                detailVC.transitioningDelegate = self
                self.present(detailVC, animated: true, completion: nil)
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension AccountViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        return animator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        return animator
    }
}





