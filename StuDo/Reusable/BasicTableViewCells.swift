//
//  BasicTableViewCells.swift
//  StuDo
//
//  Created by Andrew on 7/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class TableViewCellValue1Style: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TableViewCellWithSubtitle: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class TableViewCellWithInputField: UITableViewCell {
    
    let inputField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(inputField)
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        inputField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        inputField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        inputField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        inputField.font = .preferredFont(forTextStyle: .body)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




class TableViewCellWithTextViewInput: UITableViewCell {
    
    /**
     - Important: Placeholder handling (i.e. appearing and disappearing on appropriate time) must be implemented in the **parent controller**!
     - Note: Initially is hidden.
     */
    let placeholderLabel = UILabel()
    
    let textViewInput = UITextView()
    
    var minimumHeightConstant: NSLayoutConstraint!
    
    var topConstraint: NSLayoutConstraint!
    var bottomConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var placeholderLeadingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textViewInput)
        textViewInput.translatesAutoresizingMaskIntoConstraints = false
        textViewInput.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        
        trailingConstraint = textViewInput.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        trailingConstraint.isActive = true
        
        topConstraint = textViewInput.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
        topConstraint.isActive = true
        
        bottomConstraint = textViewInput.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        bottomConstraint.isActive = true
        
        minimumHeightConstant = textViewInput.heightAnchor.constraint(greaterThanOrEqualToConstant: 44 * 2)
        minimumHeightConstant.isActive = true
        
        contentView.addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLeadingConstraint = placeholderLabel.leadingAnchor.constraint(equalTo: textViewInput.leadingAnchor, constant: 4)
        placeholderLeadingConstraint.isActive = true
        placeholderLabel.topAnchor.constraint(equalTo: textViewInput.topAnchor, constant: 7).isActive = true
        
        placeholderLabel.font = .preferredFont(forTextStyle: .body)
        
        if #available(iOS 13, *) {
            placeholderLabel.textColor = .placeholderText
        } else {
            placeholderLabel.textColor = UIColor(red:0.781, green:0.780, blue:0.802, alpha:1.000)
        }
        
        placeholderLabel.isHidden = true
        
        textViewInput.isScrollEnabled = false
        
        textViewInput.font = .preferredFont(forTextStyle: .body)
        
        textViewInput.backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
