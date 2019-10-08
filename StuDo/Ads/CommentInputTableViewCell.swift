//
//  CommentInputTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 9/30/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class CommentInputTableViewCell: TableViewCellWithTextViewInput {
    
    let publishButton = UIButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = nil
        
        let publishButtonSize: CGFloat = 28
        contentView.addSubview(publishButton)
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        publishButton.widthAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
        publishButton.heightAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
        publishButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        publishButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        
        publishButton.isHidden = true
        
        trailingConstraint.isActive = false
        textViewInput.trailingAnchor.constraint(equalTo: publishButton.leadingAnchor, constant: -10).isActive = true
        
        

        let publishButtonImage = #imageLiteral(resourceName: "publish-button").withRenderingMode(.alwaysTemplate)
        publishButton.setImage(publishButtonImage, for: .normal)
        publishButton.setImage(publishButtonImage, for: .disabled)
        publishButton.adjustsImageWhenHighlighted = false
        publishButton.tintColor = .globalTintColor
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
