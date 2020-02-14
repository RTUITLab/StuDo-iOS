//
//  EditableAdBodyCell.swift
//  StuDo
//
//  Created by Andrew on 2/11/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class EditableAdBodyCell: UITableViewCell {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: TextViewNoPadding!
    @IBOutlet weak var titlePlaceholderLabel: UILabel!
    @IBOutlet weak var bodyPlaceholderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextField.font = .preferredFont(for: .title2, weight: .bold)
        bodyTextView.font = .preferredFont(forTextStyle: .body)
        titlePlaceholderLabel.font = .preferredFont(for: .title2, weight: .bold)
        bodyPlaceholderLabel.font = .preferredFont(forTextStyle: .body)
        bodyPlaceholderLabel.numberOfLines = 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
