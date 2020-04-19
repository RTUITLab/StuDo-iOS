//
//  UserTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 9/27/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class UserTableViewCell: TableViewCellValue1Style {
    
    let avatarGradientLayer = CAGradientLayer()
    let avatarView = UIView()
    let initialsLabel = UILabel()
    let nameLabel = UILabel()
    
    let separator = UIView()
    
    var avatarViewSizeConstraint: NSLayoutConstraint!
    var avatarViewBottomConstraint: NSLayoutConstraint!
    var nameLabelCenterYConstraint: NSLayoutConstraint!

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
        avatarGradientLayer.colors = UserGradient.grayColors
        
        avatarGradientLayer.startPoint = CGPoint(x: 0, y: 0)
        avatarGradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        avatarView.layer.addSublayer(avatarGradientLayer)
        avatarView.layer.masksToBounds = true
        
        
        
        let avatarPadding: CGFloat = 8
        
        contentView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
        avatarView.widthAnchor.constraint(equalTo: avatarView.heightAnchor, multiplier: 1).isActive = true
        avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        
        avatarViewBottomConstraint = avatarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        avatarViewBottomConstraint.isActive = true
        avatarViewSizeConstraint = avatarView.heightAnchor.constraint(equalToConstant: 35)
        avatarViewSizeConstraint.isActive = true
        
        avatarView.addSubview(initialsLabel)
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor).isActive = true
        initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true
        initialsLabel.widthAnchor.constraint(equalTo: avatarView.widthAnchor, multiplier: 0.98).isActive = true
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: avatarPadding).isActive = true
        if let detailLabel = detailTextLabel {
            nameLabel.trailingAnchor.constraint(equalTo: detailLabel.leadingAnchor, constant: -6).isActive = true
        }
        
        nameLabelCenterYConstraint = nameLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        nameLabelCenterYConstraint.isActive = true
        
        
        nameLabel.font = .preferredFont(for: .body, weight: .regular)
        nameLabel.adjustsFontSizeToFitWidth = true
        
        detailTextLabel?.font = .preferredFont(for: .footnote, weight: .light)
        detailTextLabel?.textColor = .globalTintColor
        
        
        
        initialsLabel.textAlignment = .center
        initialsLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        initialsLabel.textColor = .white
        initialsLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        separator.backgroundColor = .separator
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    var initialLayout = true
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if initialLayout {
            initialLayout = false
            layoutIfNeeded()
        }
        
        avatarGradientLayer.frame = CGRect(x: 0, y: 0, width: avatarView.frame.width, height: avatarView.frame.height)
        avatarView.layer.cornerRadius = avatarView.frame.width / 2
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        avatarView.backgroundColor = avatarViewColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
//        avatarView.backgroundColor = avatarViewColor
    }

}
