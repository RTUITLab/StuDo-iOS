//
//  AdControllerHeaderView.swift
//  StuDo
//
//  Created by Andrew on 2/10/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class AdControllerHeaderView: UIView {
    
    var titleText: String = "" {
        didSet {
            headerLabel.text = titleText
        }
    }
    
    private let horizontalHandle = UIView()
    private let headerSeparator = UIView()
    private let headerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var firstLayout = true
    override func layoutSubviews() {
        if firstLayout {
            firstLayout = false
            setInitialLayout()
            setInitialVisuals()
        }
    }
    
    private func setInitialLayout() {
        
        let handleHeight: CGFloat = 5
        self.addSubview(horizontalHandle)
        horizontalHandle.translatesAutoresizingMaskIntoConstraints = false
        horizontalHandle.widthAnchor.constraint(equalToConstant: 50).isActive = true
        horizontalHandle.heightAnchor.constraint(equalToConstant: handleHeight).isActive = true
        horizontalHandle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        horizontalHandle.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        horizontalHandle.layer.cornerRadius = handleHeight / 2
                
        self.addSubview(headerSeparator)
        headerSeparator.translatesAutoresizingMaskIntoConstraints = false
        headerSeparator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        headerSeparator.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        headerSeparator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.centerXAnchor.constraint(equalTo: horizontalHandle.centerXAnchor).isActive = true
        headerLabel.centerYAnchor.constraint(equalTo: horizontalHandle.centerYAnchor).isActive = true
        
        headerLabel.font = .systemFont(ofSize: 16, weight: .light)
                
    }
    
    private func setInitialVisuals() {
        headerSeparator.isHidden = true
        headerLabel.isHidden = true
        
        self.backgroundColor = .secondarySystemBackground
        headerSeparator.backgroundColor = .separator
        horizontalHandle.backgroundColor = .separator
        headerLabel.textColor = .label
        
        headerLabel.font = .systemFont(ofSize: 16, weight: .light)
    }
    
    private func toggleTitle(visible: Bool) {
        horizontalHandle.animateVisibility(shouldHide: visible)
        headerLabel.animateVisibility(shouldHide: !visible)
    }
    
    func toggleState(showTitle: Bool) {
        toggleTitle(visible: showTitle)
        headerSeparator.animateVisibility(shouldHide: !showTitle)
    }
    

}
