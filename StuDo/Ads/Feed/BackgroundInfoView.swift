//
//  BackgroundInfoView.swift
//  StuDo
//
//  Created by Andrew on 4/15/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class BackgroundInfoView: UIView {
    
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .preferredFont(for: .subheadline, weight: .medium)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 3
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var firstLayout = true
    override func layoutSubviews() {
        if firstLayout {
            firstLayout = false
            
            addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50).isActive = true
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
            
            addSubview(descriptionLabel)
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor).isActive = true
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
            descriptionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9).isActive = true
        }
    }
    
}
