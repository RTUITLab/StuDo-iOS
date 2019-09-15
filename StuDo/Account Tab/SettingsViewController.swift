//
//  SettingsViewController.swift
//  StuDo
//
//  Created by Andrew on 8/23/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let cellWithAccessoryType = "cellWithAccessoryType"
fileprivate let cellForColorScheme = "cellForColorScheme"

class SettingsViewController: UITableViewController {
    
    enum InfoUnit: String {
        case language = "Current Language"
        case theme = "Appearance style"
    }
    
    let infoPositions: [[InfoUnit]] = [[.language], [.theme]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localizer.string(for: .settingsTitle)
        tabBarController?.hideTabBar()
        
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: cellWithAccessoryType)
        tableView.register(SettingsColorSchemeCell.self, forCellReuseIdentifier: cellForColorScheme)
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(notification:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.hideTabBar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        if info == .language {
            cell.textLabel?.text = Localizer.string(for: .settingsLanguage)
            cell.detailTextLabel?.text = PersistentStore.shared.currentLanguage.rawValue
        } else if info == .theme {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellForColorScheme, for: indexPath) as! SettingsColorSchemeCell
            cell.accessoryType = .disclosureIndicator

            cell.textLabel?.text = Localizer.string(for: .settingsAccentColor)
            
            return cell
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




extension SettingsViewController {
    @objc func languageDidChange(notification: Notification) {
        navigationItem.title = Localizer.string(for: .settingsTitle)
    }
}




class SettingsColorSchemeCell: TableViewCellValue1Style {
    
    let colorPreview = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        colorPreview.backgroundColor = .globalTintColor

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    var initialLayout = true
    override func layoutSubviews() {
        super.layoutSubviews()
        if initialLayout {
            initialLayout = false
            
            contentView.addSubview(colorPreview)
            colorPreview.translatesAutoresizingMaskIntoConstraints = false
            colorPreview.widthAnchor.constraint(equalToConstant: 25).isActive = true
            colorPreview.heightAnchor.constraint(equalTo: colorPreview.widthAnchor).isActive = true
            colorPreview.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            colorPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
            
            layoutIfNeeded()
        }
        
        colorPreview.layer.cornerRadius = colorPreview.frame.width / 2
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        colorPreview.backgroundColor = .globalTintColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        colorPreview.backgroundColor = .globalTintColor
    }
    
}
