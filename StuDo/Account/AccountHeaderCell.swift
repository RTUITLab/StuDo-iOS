//
//  AccountHeaderView.swift
//  StuDo
//
//  Created by Andrew on 7/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AccountHeaderView: UITableViewHeaderFooterView {
    
    let sectionTitleLabel = UILabel()
    let actionButton = UIButton()
    
    var sectionTitle: String? {
        didSet {
            sectionTitleLabel.text = sectionTitle?.uppercased()
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 13, *) {
            contentView.backgroundColor = .secondarySystemGroupedBackground
        } else {
            contentView.backgroundColor = UIColor.white
        }
        
        contentView.addSubview(sectionTitleLabel)
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        sectionTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        actionButton.setTitleColor(actionButton.tintColor, for: .normal)
        
        sectionTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        sectionTitleLabel.textColor = UIColor(red:0.631, green:0.631, blue:0.631, alpha:1.000)
        
        actionButton.setTitleColor(.globalTintColor, for: .normal)
        actionButton.setTitleColor(UIColor.globalTintColor.withAlphaComponent(0.5), for: .highlighted)
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(notification:)), name: PersistentStoreNotification.themeDidChange.name, object: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



extension AccountHeaderView {
    @objc func themeDidChange(notification: Notification) {
        actionButton.setTitleColor(.globalTintColor, for: .normal)
        actionButton.setTitleColor(UIColor.globalTintColor.withAlphaComponent(0.5), for: .highlighted)
    }
}
