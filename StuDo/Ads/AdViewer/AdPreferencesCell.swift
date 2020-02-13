//
//  AdDateButtonsCell.swift
//  StuDo
//
//  Created by Andrew on 2/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class AdPreferencesCell: UITableViewCell {
    
    let beginDateButton: DateButton
    let endDateButton: DateButton

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        beginDateButton = DateButton(name: Localizer.string(for: .adEditorBeginDateLabel))
        endDateButton = DateButton(name: Localizer.string(for: .adEditorEndDateLabel))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    var initialLayout = true
    override func layoutSubviews() {
        super.layoutSubviews()
        if initialLayout {
            initialLayout = false
            setInitialLayout()
        }
    }
    
    // Layout
    
    func setInitialLayout() {
        contentView.addSubview(beginDateButton)
        beginDateButton.translatesAutoresizingMaskIntoConstraints = false
        beginDateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        beginDateButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        beginDateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        contentView.addSubview(endDateButton)
        endDateButton.translatesAutoresizingMaskIntoConstraints = false
        endDateButton.centerYAnchor.constraint(equalTo: beginDateButton.centerYAnchor, constant: 0).isActive = true
        endDateButton.heightAnchor.constraint(equalTo: beginDateButton.heightAnchor, multiplier: 1).isActive = true
        endDateButton.leadingAnchor.constraint(equalTo: beginDateButton.trailingAnchor, constant: 16).isActive = true
        
    }

}
