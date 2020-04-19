//
//  AdTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 9/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AdTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet var moreButtonTrailingAnchor: NSLayoutConstraint!
    
    var moreButtonCallback: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let moreButtonImage = moreButton.currentImage {
            moreButton.setImage(moreButtonImage.withTintColor(.globalTintColor).withRenderingMode(.alwaysOriginal), for: .normal)
            moreButton.setImage(moreButtonImage.withTintColor(UIColor.globalTintColor.withAlphaComponent(0.5)).withRenderingMode(.alwaysOriginal), for: .highlighted)
            moreButton.setImage(moreButtonImage.withTintColor(UIColor.globalTintColor.withAlphaComponent(0.5)).withRenderingMode(.alwaysOriginal), for: .focused)
            let inset: CGFloat = 28
            moreButtonTrailingAnchor.constant = -28 + moreButtonTrailingAnchor.constant
            moreButton.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        }
        
        selectionStyle = .none
        
        descriptionTextView.isUserInteractionEnabled = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.backgroundColor = .clear
        
        dateLabel.textColor = .globalTintColor
        
        moreButton.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.textColor = .globalTintColor
        if let moreButtonImage = moreButton.currentImage {
            moreButton.setImage(moreButtonImage.withTintColor(.globalTintColor).withRenderingMode(.alwaysOriginal), for: .normal)
            moreButton.setImage(moreButtonImage.withTintColor(UIColor.globalTintColor.withAlphaComponent(0.5)).withRenderingMode(.alwaysOriginal), for: .highlighted)
            moreButton.setImage(moreButtonImage.withTintColor(UIColor.globalTintColor.withAlphaComponent(0.5)).withRenderingMode(.alwaysOriginal), for: .focused)
        }
    }
    
    deinit {
        print("AdTableViewCell deinitialized")
    }

}



extension AdTableViewCell {
    @objc func moreButtonTapped(_ button: UIButton) {
        moreButtonCallback?()
    }
}
