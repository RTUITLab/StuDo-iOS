//
//  CommentTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 9/29/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class CommentTableViewCell: UserTableViewCell {
    
    let bodyTextView = TextViewNoPadding()
    let dateLabel = UILabel()
    
    var isAvatarHighlighted: Bool = true {
        didSet {
            if isAvatarHighlighted {
                avatarGradientLayer.colors = UserGradient.currentColors
            } else {
                avatarGradientLayer.colors = UserGradient.grayColors
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabelCenterYConstraint.isActive = false
        
        avatarViewBottomConstraint.isActive = false
        avatarView.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 0).isActive = true
        
        
        
        contentView.addSubview(bodyTextView)
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.topAnchor.constraint(equalTo: nameLabel.lastBaselineAnchor, constant: 10).isActive = true
        bodyTextView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0).isActive = true
        bodyTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: bodyTextView.lastBaselineAnchor, constant: 10).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
        
        
        
        
        nameLabel.font = .preferredFont(for: .body, weight: .medium)
        
        
        bodyTextView.isScrollEnabled = false
        bodyTextView.isEditable = false
        bodyTextView.font = .preferredFont(for: .body, weight: .light)
        bodyTextView.backgroundColor = nil
        
        dateLabel.font = .preferredFont(for: .footnote, weight: .light)
        dateLabel.textColor = .lightGray
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
