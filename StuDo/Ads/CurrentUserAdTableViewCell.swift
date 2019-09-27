//
//  CurrentUserAdTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 9/27/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit


// TODO: Rewrite this class
// This class mostly repeats the class CurrentUserTableViewCell

class CurrentUserAdTableViewCell: UserTableViewCell {
    
    fileprivate let orangeGradient = (UIColor(red:0.988, green:0.871, blue:0.541, alpha:1.000), UIColor(red:0.953, green:0.510, blue:0.506, alpha:1.000))
    fileprivate let pinkGradient = (UIColor(red:0.965, green:0.314, blue:0.627, alpha:1.000), UIColor(red:1.000, green:0.455, blue:0.475, alpha:1.000))
    fileprivate let ocyanGradient = (UIColor(red:0.102, green:0.906, blue:0.855, alpha:1.000), UIColor(red:0.357, green:0.502, blue:0.914, alpha:1.000))
    fileprivate let greenGradient = (UIColor(red:0.259, green:0.890, blue:0.592, alpha:1.000), UIColor(red:0.235, green:0.714, blue:0.710, alpha:1.000))
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let gradients = [orangeGradient, pinkGradient, ocyanGradient, greenGradient]
        
        var gradientIndex: Int!
        if let index = PersistentStore.shared.profilePictureGradientIndex {
            gradientIndex = index
        } else {
            gradientIndex = Int.random(in: 0..<gradients.count)
            PersistentStore.shared.profilePictureGradientIndex = gradientIndex
        }
        let gradient = gradients[gradientIndex]
        
        avatarGradientLayer.colors = [gradient.0.cgColor, gradient.1.cgColor]
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
