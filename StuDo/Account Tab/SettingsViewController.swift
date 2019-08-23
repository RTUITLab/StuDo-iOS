//
//  SettingsViewController.swift
//  StuDo
//
//  Created by Andrew on 8/23/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let cellWithAccessoryType = "cellWithAccessoryType"

class SettingsViewController: UITableViewController {
    
    enum InfoUnit: String {
        case language = "Current Language"
        case theme = "Appearance style"
    }
    
    let infoPositions: [[InfoUnit]] = [[.language], [.theme]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        tabBarController?.hideTabBar()
        
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: cellWithAccessoryType)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return infoPositions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoPositions[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellWithAccessoryType, for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = infoPositions[indexPath.section][indexPath.row].rawValue

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = infoPositions[indexPath.section][indexPath.row]
        
        if info == .language {
            let languageVC = LanguageListViewController(style: .plain)
            languageVC.view.backgroundColor = .white
            navigationController?.pushViewController(languageVC, animated: true)
        } else if info == .theme {
            let detailVC = UIViewController()
            detailVC.view.backgroundColor = .white
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }

}
