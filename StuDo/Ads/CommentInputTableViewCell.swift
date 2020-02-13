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
    
    enum CommentInputTableViewCellMode {
        case showPublishButton
        case hidePublishButton
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = nil
        
        let publishButtonSize: CGFloat = 28
        contentView.addSubview(publishButton)
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        publishButton.widthAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
        publishButton.heightAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
        publishButton.trailingAnchor.constraint(equalTo: textViewInput.trailingAnchor, constant: -6).isActive = true
        publishButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        publishButton.isHidden = true
        
        trailingConstraint.isActive = true
        placeholderLeadingConstraint.constant = 14

        let publishButtonImage = #imageLiteral(resourceName: "publish-button").withRenderingMode(.alwaysTemplate)
        publishButton.setImage(publishButtonImage, for: .normal)
        publishButton.setImage(publishButtonImage, for: .disabled)
        publishButton.adjustsImageWhenHighlighted = false
        publishButton.tintColor = .globalTintColor
        
        minimumHeightConstant.isActive = false
        topConstraint.constant = 8
        bottomConstraint.constant = -8
        
        textViewInput.layer.cornerRadius = 20
        textViewInput.layer.borderColor = UIColor.placeholderText.cgColor
        textViewInput.layer.borderWidth = 0.2
        textViewInput.layer.masksToBounds = true

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textViewInput.textContainerInset.left = 5
        textViewInput.textContainerInset.right = 20
        textViewInput.textContainer.lineFragmentPadding = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
