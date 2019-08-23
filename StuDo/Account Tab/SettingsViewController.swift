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
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
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
        
        let info = infoPositions[indexPath.section][indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = info.rawValue
        
        if info == .language {
            cell.detailTextLabel?.text = PersistentStore.shared.currentLanguage.rawValue
        } else if info == .theme {
            cell.detailTextLabel?.text = PersistentStore.shared.currentTheme.rawValue
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = infoPositions[indexPath.section][indexPath.row]
        
        if info == .language {
            let languageVC = LanguageListViewController(style: .plain)
            navigationController?.pushViewController(languageVC, animated: true)
        } else if info == .theme {
            let detailVC = ThemesListViewController(style: .plain)
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }

}
