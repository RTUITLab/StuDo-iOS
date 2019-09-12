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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let moreButtonImage = moreButton.currentImage?.withRenderingMode(.alwaysTemplate) {
            moreButton.setImage(moreButtonImage, for: .normal)
            moreButton.tintColor = UIColor(red:0.815, green:0.819, blue:0.837, alpha:1.000)
        }
        
        selectionStyle = .none
        
        descriptionTextView.isUserInteractionEnabled = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.backgroundColor = .clear
        
    }
    
    override func prepareForReuse() {
        dateLabel.textColor = .globalTintColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
