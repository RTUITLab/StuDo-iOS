//
//  NavigationMenu.swift
//  StuDo
//
//  Created by Andrew on 8/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit



protocol NavigationMenuDelegate: class {
    func navigationMenu(_ navigationMenu: NavigationMenu, didChangeOption newOption: NavigationMenu.MenuItemName)
}



fileprivate let navigationMenuCellId = "navigationMenuCellId"

class NavigationMenu: UITableView {
    
    weak var menuDelegate: NavigationMenuDelegate?
    
    func resetSelectedOption() {
        selectedOption = .allAds
    }
    private(set) var selectedOption: MenuItemName = .allAds
    var previouslySelectedOptionIndexPath: IndexPath!
    
    let menuItemHeight: CGFloat = 60
    var calculatedMenuHeight: CGFloat {
        return min(CGFloat(menuItems.count) * menuItemHeight,  menuItemHeight * 6)
    }
    
    enum MenuItemName: Equatable {
        case allAds
        case myAds
        case organization(String, String)
    }
    private let defaultMenuItems: [MenuItemName] = [.allAds, .myAds]
    private lazy var menuItems = {
        return defaultMenuItems
    }()
    
    func set(organizations: [Organization]) {
        menuItems = defaultMenuItems
        for org in organizations {
            menuItems.append(.organization(org.id, org.name))
        }
        reloadData()
    }
    

    init() {
        super.init(frame: .zero, style: .plain)
        
        register(NavigationMenuCell.self, forCellReuseIdentifier: navigationMenuCellId)
        
        delegate = self
        dataSource = self
        
        rowHeight = menuItemHeight
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(notification:)), name: PersistentStoreNotification.languageDidChange.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(notification:)), name: PersistentStoreNotification.themeDidChange.name, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension NavigationMenu: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: navigationMenuCellId, for: indexPath) as! NavigationMenuCell
        
        let currentMenuItem = menuItems[indexPath.row]
        
        switch currentMenuItem {
        case .allAds:
            cell.textLabel?.text = Localizer.string(for: .navigationMenuAllAds)
        case .myAds:
            cell.textLabel?.text = Localizer.string(for: .navigationMenuMyAds)
        case .organization(_, let name):
            cell.textLabel?.text = name
        }
        
        cell.tickGlyph.tintColor = .globalTintColor
        
        if currentMenuItem == selectedOption {
            cell.tickGlyph.alpha = 1
            previouslySelectedOptionIndexPath = indexPath
        } else {
            cell.tickGlyph.alpha = 0
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath != previouslySelectedOptionIndexPath else { return }
        
        let oldCell = tableView.cellForRow(at: previouslySelectedOptionIndexPath) as? NavigationMenuCell
        guard let newCell = tableView.cellForRow(at: indexPath) as? NavigationMenuCell else { return }
        
        UIView.animate(withDuration: 0.2) {
            oldCell?.tickGlyph.alpha = 0
            newCell.tickGlyph.alpha = 1
        }
        
        previouslySelectedOptionIndexPath = indexPath
        selectedOption = menuItems[indexPath.row]
        menuDelegate?.navigationMenu(self, didChangeOption: selectedOption)
    }
    
    
    
}






class NavigationMenuCell: ListItemCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let tickImage = #imageLiteral(resourceName: "tick").withRenderingMode(.alwaysTemplate)
        tickGlyph.image = tickImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension NavigationMenu {
    @objc func languageDidChange(notification: Notification) {
        reloadData()
    }
    
    @objc func themeDidChange(notification: Notification) {
        reloadData()
    }
}
