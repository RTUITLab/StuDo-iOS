//
//  NavigationMenuCell.swift
//  StuDo
//
//  Created by Andrew on 8/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class NavigationMenuCell: UITableViewCell {
    
    let tickGlyph = UIImageView()
    let dimView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(tickGlyph)
        tickGlyph.translatesAutoresizingMaskIntoConstraints = false
        tickGlyph.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        tickGlyph.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        tickGlyph.widthAnchor.constraint(equalToConstant: 24).isActive = true
        tickGlyph.heightAnchor.constraint(equalTo: tickGlyph.widthAnchor).isActive = true
        
        let tickImage = #imageLiteral(resourceName: "tick").withRenderingMode(.alwaysTemplate)
        tickGlyph.image = tickImage
        tickGlyph.tintColor = UIColor(red:0.002, green:0.477, blue:0.999, alpha:1.000)
        
        tickGlyph.alpha = 0
        
        
        contentView.addSubview(dimView)
        contentView.sendSubviewToBack(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        dimView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        dimView.backgroundColor = .init(white: 0, alpha: 0.1)
        dimView.alpha = 0
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.dimView.alpha = 1
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveLinear, animations: {
            self.dimView.alpha = 0
        }, completion: nil)
    }
    

}
