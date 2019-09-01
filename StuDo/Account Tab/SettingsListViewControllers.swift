//
//  SettingsListViewControllers.swift
//  StuDo
//
//  Created by Andrew on 8/23/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class SettingsListViewController<ListItem: RawRepresentable>: UITableViewController {
    
    private let listCellIdentifier = "listCellIdentifier"
    
    private var previousItemIndex: IndexPath?
    var currentItem: ListItem!
    var listItems = [[ListItem]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SettingsListItemCell.self, forCellReuseIdentifier: listCellIdentifier)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listItems.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath) as! SettingsListItemCell
        
        let listItem = listItems[indexPath.section][indexPath.row]
        if let listItemStringValue = listItem.rawValue as? String {
            if let localizerString = LozalizerString(rawValue: listItemStringValue) {
                cell.textLabel?.text = Localizer.string(for: localizerString)
            } else {
                cell.textLabel?.text = listItemStringValue
            }
            
            if let currentItemStringValue = currentItem.rawValue as? String {
                if listItemStringValue == currentItemStringValue {
                    cell.tickGlyph.alpha = 1
                    previousItemIndex = indexPath
                }
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let previousIndex = previousItemIndex {
            let cell = tableView.cellForRow(at: previousIndex) as! SettingsListItemCell
            UIView.animate(withDuration: 0.2) {
                cell.tickGlyph.alpha = 0
            }
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentItem = listItems[indexPath.section][indexPath.row]
        previousItemIndex = indexPath
        
        let cell = tableView.cellForRow(at: indexPath) as! SettingsListItemCell
        UIView.animate(withDuration: 0.2) {
            cell.tickGlyph.alpha = 1
        }
    }
    
}






class SettingsListItemCell: ListItemCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let tickImage = #imageLiteral(resourceName: "check").withRenderingMode(.alwaysTemplate)
        tickGlyph.image = tickImage
        tickGlyph.tintColor = .globalTintColor
        
        let scale: CGFloat = 0.74
        tickGlyph.transform = .init(scaleX: scale, y: scale)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}










class LanguageListViewController: SettingsListViewController<StuDoAvailableLanguage> {
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        
        var languageOptions = [StuDoAvailableLanguage]()
        StuDoAvailableLanguage.allCases.forEach {
            languageOptions.append($0)
        }
        listItems.append(languageOptions)
        
        currentItem = PersistentStore.shared.currentLanguage
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let selectedLanguage = listItems[indexPath.section][indexPath.row]
        PersistentStore.shared.currentLanguage = selectedLanguage
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
}







class ThemesListViewController: SettingsListViewController<StuDoAvailableThemes> {
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        
        var themes = [StuDoAvailableThemes]()
        StuDoAvailableThemes.allCases.forEach {
            themes.append($0)
        }
        listItems.append(themes)
        
        currentItem = PersistentStore.shared.currentTheme
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let selectedTheme = listItems[indexPath.section][indexPath.row]
        PersistentStore.shared.currentTheme = selectedTheme
        
        let currentTintColor: UIColor = .tintColor(for: selectedTheme)
        navigationController?.navigationBar.tintColor = currentTintColor
        
        let cell = tableView.cellForRow(at: indexPath) as! SettingsListItemCell
        cell.tickGlyph.tintColor = currentTintColor
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.imageView?.image = #imageLiteral(resourceName: "circle").withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = .tintColor(for: listItems[indexPath.section][indexPath.row])
        return cell
    }
    
}
