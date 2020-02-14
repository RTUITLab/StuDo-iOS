//
//  AdDateButtonsCell.swift
//  StuDo
//
//  Created by Andrew on 2/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class AdPreferencesView: UIView {
    
    let beginDateButton: DateButton
    let endDateButton: DateButton
    
    // Needed to support date picker as input view
    let beginTextField = UITextField(frame: .zero)
    let endTextField = UITextField(frame: .zero)

    override init(frame: CGRect) {
        beginDateButton = DateButton(name: Localizer.string(for: .adEditorBeginDateLabel))
        endDateButton = DateButton(name: Localizer.string(for: .adEditorEndDateLabel))
        super.init(frame: frame)
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
        addSubview(beginDateButton)
        beginDateButton.translatesAutoresizingMaskIntoConstraints = false
        beginDateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        beginDateButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        beginDateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        addSubview(endDateButton)
        endDateButton.translatesAutoresizingMaskIntoConstraints = false
        endDateButton.centerYAnchor.constraint(equalTo: beginDateButton.centerYAnchor, constant: 0).isActive = true
        endDateButton.heightAnchor.constraint(equalTo: beginDateButton.heightAnchor, multiplier: 1).isActive = true
        endDateButton.leadingAnchor.constraint(equalTo: beginDateButton.trailingAnchor, constant: 16).isActive = true
        
        addSubview(beginTextField)
        addSubview(endTextField)
    }

}
