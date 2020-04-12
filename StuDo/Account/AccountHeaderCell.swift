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
            sectionTitleLabel.text = sectionTitle
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .secondarySystemGroupedBackground
        
        contentView.addSubview(sectionTitleLabel)
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        sectionTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        actionButton.setTitleColor(actionButton.tintColor, for: .normal)
        
        sectionTitleLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        sectionTitleLabel.textColor = .secondaryLabel
        
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
