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
    
    let moreButton = UIButton()
    let publishButton = UIButton()
    let cancelEditingButton = UIButton()

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
        headerLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        headerLabel.textAlignment = .center
        
        let leftRightPadding: CGFloat = 16

        let moreButtonSize: CGFloat = 20
        self.addSubview(moreButton)
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.widthAnchor.constraint(equalToConstant: moreButtonSize).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: moreButtonSize).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        moreButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -leftRightPadding).isActive = true
        
        let publishButtonSize: CGFloat = 28
        self.addSubview(publishButton)
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        publishButton.widthAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
        publishButton.heightAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
        publishButton.centerYAnchor.constraint(equalTo: moreButton.centerYAnchor).isActive = true
        publishButton.centerXAnchor.constraint(equalTo: moreButton.centerXAnchor).isActive = true
        
        let cancelEditingButtonSize: CGFloat = 24
        self.addSubview(cancelEditingButton)
        cancelEditingButton.translatesAutoresizingMaskIntoConstraints = false
        cancelEditingButton.widthAnchor.constraint(equalToConstant: cancelEditingButtonSize).isActive = true
        cancelEditingButton.heightAnchor.constraint(equalToConstant: cancelEditingButtonSize).isActive = true
        cancelEditingButton.centerYAnchor.constraint(equalTo: moreButton.centerYAnchor).isActive = true
        cancelEditingButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leftRightPadding).isActive = true
        
    }
    
    private func setInitialVisuals() {
        headerSeparator.isHidden = true
        headerLabel.isHidden = true
        
        self.backgroundColor = .systemBackground
        headerSeparator.backgroundColor = .separator
        horizontalHandle.backgroundColor = .separator
        headerLabel.textColor = .label
        
        headerLabel.font = .systemFont(ofSize: 16, weight: .light)
        
        let moreButtonImage = UIImage(systemName: "ellipsis.circle.fill")!.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(moreButtonImage, for: .normal)
        moreButton.adjustsImageWhenHighlighted = false
        moreButton.tintColor = .globalTintColor
        
        let publishButtonImage = #imageLiteral(resourceName: "publish-button").withRenderingMode(.alwaysTemplate)
        publishButton.setImage(publishButtonImage, for: .normal)
        publishButton.setImage(publishButtonImage, for: .disabled)
        publishButton.adjustsImageWhenHighlighted = false
        publishButton.isHidden = true
        
        let cancelEditingButtonImage = UIImage(systemName: "xmark.circle.fill")
        cancelEditingButton.tintColor = .systemGray2
        cancelEditingButton.setImage(cancelEditingButtonImage, for: .normal)
        cancelEditingButton.isHidden = true
        
    }
    
    private func toggleTitle(visible: Bool) {
        horizontalHandle.animateVisibility(shouldHide: visible)
        headerLabel.animateVisibility(shouldHide: !visible)
    }
    
    func togglePublishButton(isEnabled: Bool) {
        publishButton.tintColor = isEnabled ? .globalTintColor : .lightGray
        publishButton.isEnabled = isEnabled
    }
    
    var showEditingControls = false {
        willSet {
            toggleTitle(visible: newValue)
            moreButton.animateVisibility(shouldHide: newValue)
            publishButton.animateVisibility(shouldHide: !newValue)
            cancelEditingButton.animateVisibility(shouldHide: !newValue)
        }
    }
    
    func toggleState(showTitle: Bool) {
        headerSeparator.animateVisibility(shouldHide: !showTitle)
        if !showEditingControls {
            toggleTitle(visible: showTitle)
        }
    }
    

}
