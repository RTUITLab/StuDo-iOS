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
    
    private(set) var selectedOption: MenuItemName = .allAds
    var previouslySelectedOptionIndexPath: IndexPath!
    
    let menuItemHeight: CGFloat = 60
    var calculatedMenuHeight: CGFloat {
        return CGFloat(menuItems.count) * menuItemHeight
    }
    
    enum MenuItemName: String {
        case allAds = "All news"
        case myAds = "Only my ads"
    }
    let menuItems: [MenuItemName] = [.allAds, .myAds]

    init() {
        super.init(frame: .zero, style: .plain)
        
        register(NavigationMenuCell.self, forCellReuseIdentifier: navigationMenuCellId)
        
        delegate = self
        dataSource = self
        
        rowHeight = menuItemHeight
        
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
        cell.textLabel?.text = currentMenuItem.rawValue
        
        if currentMenuItem == selectedOption {
            cell.tickGlyph.alpha = 1
            previouslySelectedOptionIndexPath = indexPath
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath != previouslySelectedOptionIndexPath else { return }
        
        let oldCell = tableView.cellForRow(at: previouslySelectedOptionIndexPath) as! NavigationMenuCell
        guard let newCell = tableView.cellForRow(at: indexPath) as? NavigationMenuCell else { return }
        
        UIView.animate(withDuration: 0.2) {
            oldCell.tickGlyph.alpha = 0
            newCell.tickGlyph.alpha = 1
        }
        
        previouslySelectedOptionIndexPath = indexPath
        selectedOption = menuItems[indexPath.row]
        menuDelegate?.navigationMenu(self, didChangeOption: selectedOption)
    }
    
    
    
}
