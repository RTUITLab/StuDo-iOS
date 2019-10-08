//
//  CurrentUserAdTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 9/27/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class CurrentUserAdTableViewCell: UserTableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = nil
        
        accessoryType = .disclosureIndicator
        
        let colors = UserGradient.current
        avatarGradientLayer.colors = [colors.0, colors.1]
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
