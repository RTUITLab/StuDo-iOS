//
//  ApplicantsTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 4/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class ApplicantTableViewCell: MemberTableViewCell {
    
    let addButton = UIButton()
    
    var addButtonClosure: (()->())? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addButton.setTitle(Localizer.string(for: .organizationAddWisher), for: .normal)
        addButton.setTitleColor(.globalTintColor, for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }
    
    var firstLayout = true
    override func layoutSubviews() {
        super.layoutSubviews()
        if firstLayout {
            firstLayout = false
            
            contentView.addSubview(addButton)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addButtonTapped(_ button: UIButton) {
        addButtonClosure?()
    }

}
