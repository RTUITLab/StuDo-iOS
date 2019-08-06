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


class TableViewCellWithInputField: UITableViewCell {
    
    let inputField = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(inputField)
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        inputField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        inputField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        inputField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
