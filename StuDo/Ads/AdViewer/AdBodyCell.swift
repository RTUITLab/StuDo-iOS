//
//  AdBodyCell.swift
//  StuDo
//
//  Created by Andrew on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class AdBodyCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyTextView: TextViewNoPadding!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = .preferredFont(for: .title2, weight: .bold)
        dateLabel.font = .preferredFont(for: .body, weight: .light)
        
        bodyTextView.font = .preferredFont(forTextStyle: .body)
        bodyTextView.backgroundColor = nil
        bodyTextView.isEditable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
