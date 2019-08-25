//
//  AboutViewController.swift
//  StuDo
//
//  Created by Andrew on 8/19/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import MessageUI
import StoreKit

fileprivate let aboutHeaderViewID = "aboutHeaderViewID"
fileprivate let cellValue1Style = "cellValue1Style"

class AboutViewController: UITableViewController {
    
    enum AboutInfoUnit: String {
        case feedback = "Submit feedback"
        case rate = "Rate on App Store"
        case vkLink = "RTU IT Lab"
    }
    let infoPosition: [[AboutInfoUnit]] = [[.feedback, .rate, .vkLink]]
    
    lazy var appVersion: String = {
        let nsObject: Any? = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        return nsObject as! String
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.hideTabBar()

        tableView.register(AboutHeaderView.self, forHeaderFooterViewReuseIdentifier: aboutHeaderViewID)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: cellValue1Style)
        
        navigationItem.title = Localizer.string(for: .aboutTitle)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return infoPosition.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoPosition[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellValue1Style, for: indexPath)
        
        let info = infoPosition[indexPath.section][indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        if info == .feedback {
            cell.textLabel?.text = Localizer.string(for: .aboutFeedback)
        } else if info == .rate {
            cell.textLabel?.text = Localizer.string(for: .aboutRate)
        } else if info == .vkLink {
            cell.textLabel?.text = Localizer.string(for: .aboutRTULab)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: aboutHeaderViewID) as! AboutHeaderView
            header.setVersion(appVersion)
            return header
        }
        
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = infoPosition[indexPath.section][indexPath.row]
        
        if info == .vkLink {
            
            let vkURL = URL(string: "https://vk.com/rtuitlab")!
            UIApplication.shared.open(vkURL, options: [:], completionHandler: nil)
            
        } else if info == .feedback {
            
            if MFMailComposeViewController.canSendMail() {
                let feedbackEmail = "message.mrfoggz@gmail.com"
                let subject = "StuDo v\(appVersion)"
                
                let mailVC = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                mailVC.setSubject(subject)
                mailVC.setToRecipients([feedbackEmail])
                
                present(mailVC, animated: true, completion: nil)
            }
            
        } else if info == .rate {
            SKStoreReviewController.requestReview()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

   

}





extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
