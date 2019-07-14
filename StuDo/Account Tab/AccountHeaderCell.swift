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
        
        contentView.backgroundColor = UIColor.white
        
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
        
        actionButton.setTitleColor(UIColor(red:0.231, green:0.535, blue:0.992, alpha:1.000), for: .normal)
        actionButton.setTitleColor(UIColor(red:0.231, green:0.535, blue:0.992, alpha:0.500), for: .highlighted)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
