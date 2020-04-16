//
//  CollectionViewCellWithTableView.swift
//  StuDo
//
//  Created by Andrew on 4/15/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class CollectionViewCellWithTableView: UICollectionViewCell {
    
    var tableSetupClosure: (()->())? = nil
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var initialLayout = true
    override func layoutSubviews() {
        if initialLayout {
            initialLayout = false
            
            contentView.addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            
            tableSetupClosure?()
        }
    }

}
