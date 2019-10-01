//
//  MemberTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 9/29/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class MemberTableViewCell: UserTableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        avatarViewSizeConstraint.constant = 35
        
        avatarViewCenterYConstraint.isActive = false
        
        let padding: CGFloat = 8
        avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding).isActive = true
        avatarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
