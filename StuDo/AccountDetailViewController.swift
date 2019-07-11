//
//  AccountDetailViewController.swift
//  StuDo
//
//  Created by Andrew on 6/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let usualStyleCellId = "usualStyleCellId"
fileprivate let currentUserCellId = "currentUserCellId"
fileprivate let usualStyleHeaderFooterId = "usualStyleHeaderFooterId"

class AccountDetailViewController: UITableViewController {
    
    
    fileprivate enum SectionName: String {
        case nameAndSurname
        case password
        case logout
    }
    
    private var sections: [SectionName] = [.nameAndSurname, .password, .logout]
    
    init() {
        super.init(style: .grouped)
        view.backgroundColor = UIColor(red:0.937, green:0.937, blue:0.959, alpha:1.000)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: usualStyleCellId)
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: currentUserCellId)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: usualStyleHeaderFooterId)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem = doneButton
        
    }
    
    @objc func doneButtonPressed(_ doneButton: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionInfo = sections[section]
        
        switch sectionInfo {
        case .nameAndSurname:
            return "Edit your name and surname."
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .nameAndSurname {
            let cell = tableView.dequeueReusableCell(withIdentifier: currentUserCellId, for: indexPath) as! CurrentUserTableViewCell
            cell.profileImage.image = #imageLiteral(resourceName: "person")
            cell.isEditingAlailable = true
            let user = PersistentStore.shared.user!
            cell.nameField.text = user.firstName
            cell.surnameField.text = user.lastName
            cell.setupCell()
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: usualStyleCellId, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        switch sectionInfo {
        case .logout:
            cell.textLabel?.text = "Log out"
            cell.textLabel?.textColor = .red
        case .password:
            cell.textLabel?.text = "Change password"
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .logout {
            PersistentStore.shared.user = nil
            PersistentStore.save()
            
            let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
            
            let authVC = storyboard.instantiateViewController(withIdentifier: "CustomViewController")
            
            self.present(authVC, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionInfo = sections[indexPath.section]
        
        switch sectionInfo {
        case .nameAndSurname:
            return UITableView.automaticDimension
        default:
            return 46
        }
    }

}
