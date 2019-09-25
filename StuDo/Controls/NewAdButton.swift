//
//  NewAdButton.swift
//  StuDo
//
//  Created by Andrew on 8/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class NewAdButton: UIButton {
    
    let plusImageView = UIImageView()
    
    override var isHighlighted: Bool {
        didSet {
            let scaleFactor: CGFloat = 0.91
            let transform = isHighlighted ? CGAffineTransform(scaleX: scaleFactor, y: scaleFactor) : .identity
            UIView.animate(withDuration: 0.36, delay: 0, options: .curveEaseOut, animations: {
                self.transform = transform
            }, completion: nil)
        }
    }

    init() {
        super.init(frame: .zero)
        
        backgroundColor = .globalTintColor
        
        let plusImageSize: CGFloat = 38
        addSubview(plusImageView)
        plusImageView.translatesAutoresizingMaskIntoConstraints = false
        plusImageView.widthAnchor.constraint(equalToConstant: plusImageSize).isActive = true
        plusImageView.heightAnchor.constraint(equalToConstant: plusImageSize).isActive = true
        plusImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        plusImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let image = #imageLiteral(resourceName: "plus-sign").withRenderingMode(.alwaysTemplate)
        plusImageView.image = image
        plusImageView.tintColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(notification:)), name: PersistentStoreNotification.themeDidChange.name, object: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}



extension NewAdButton {
    @objc func themeDidChange(notification: NSNotification) {
        backgroundColor = .globalTintColor
    }
}
