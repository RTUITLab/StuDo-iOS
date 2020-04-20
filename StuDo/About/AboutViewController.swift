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
        case instruction = "Instruction"
        case sourceCode = "Source Code"
        case websiteLink = "Website link"
    }
    let infoPosition: [[AboutInfoUnit]]
    
    override init(style: UITableView.Style) {
        
        var contactSection: [AboutInfoUnit] = [.rate]
        if MFMailComposeViewController.canSendMail() {
            contactSection = [.feedback, .rate]
        }
        
        var infoPosition = [contactSection, [.vkLink, .websiteLink], [.sourceCode]]
        #if !DEBUG
        infoPosition.insert([.instruction], at: 0)
        #endif
        self.infoPosition = infoPosition
        
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var appVersion: String = {
        let nsObject: Any? = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        return nsObject as! String
    }()
    
    lazy var appBuild: String = {
        let nsObject: Any? = Bundle.main.infoDictionary?["CFBundleVersion"]
        return nsObject as! String
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.hideTabBar()

        tableView.register(AboutHeaderView.self, forHeaderFooterViewReuseIdentifier: aboutHeaderViewID)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: cellValue1Style)
        
        navigationItem.title = Localizer.string(for: .aboutTitle)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.hideTabBar()
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
        } else if info == .websiteLink {
            cell.textLabel?.text = Localizer.string(for: .aboutWebsite)
        } else if info == .sourceCode {
            cell.textLabel?.text = Localizer.string(for: .aboutSourceCode)
        } else if info == .instruction {
            cell.textLabel?.text = Localizer.string(for: .aboutInstruction)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: aboutHeaderViewID) as! AboutHeaderView
            header.setVersion(appVersion, appBuild)
            return header
        }
        
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = infoPosition[indexPath.section][indexPath.row]
        
        if info == .vkLink {
            
            let vkURL = URL(string: "https://vk.com/rtuitlab")!
            UIApplication.shared.open(vkURL, options: [:], completionHandler: nil)
            
        } else if info == .websiteLink {
            let url = URL(string: "https://rtuitlab.dev")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if info == .feedback {
            
            if MFMailComposeViewController.canSendMail() {
                let feedbackEmail = "studo.bugreport@icloud.com"
                let subject = "StuDo v\(appVersion) (\(appBuild))"
                
                let mailVC = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                mailVC.setSubject(subject)
                mailVC.setToRecipients([feedbackEmail])
                
                present(mailVC, animated: true, completion: nil)
            }
            
        } else if info == .rate {
            SKStoreReviewController.requestReview()
        } else if info == .sourceCode {
            let vkURL = URL(string: "https://github.com/RTUITLab/StuDo-iOS")!
            UIApplication.shared.open(vkURL, options: [:], completionHandler: nil)
        } else if info == .instruction {
            let instructionAd = Ad(id: "d36ae6bc-1836-404c-9907-4a995a02ffb4", name: "", description: "", shortDescription: "", beginTime: Date(), endTime: Date())
            self.present(AdViewController(ad: instructionAd), animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

   

}





extension AboutViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
