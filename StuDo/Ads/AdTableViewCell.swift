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
    
    var moreButtonCallback: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let moreButtonImage = moreButton.currentImage?.withRenderingMode(.alwaysTemplate) {
            moreButton.setImage(moreButtonImage, for: .normal)
            moreButton.tintColor = UIColor(red:0.815, green:0.819, blue:0.837, alpha:1.000)
            let inset: CGFloat = 10
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
