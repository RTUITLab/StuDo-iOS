//
//  DateButton.swift
//  StuDo
//
//  Created by Andrew on 9/1/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class DateButton: UIButton {
    
    let formatter = DateFormatter()
    
    func dateChanged(isSet: Bool) {
        if isSet {
            label.text = TextFormatter.mediumString(from: date)
            label.textColor = .white
            
            UIView.animate(withDuration: 0.4) {
                self.backgroundColor = .globalTintColor
            }
        } else {
            label.text = labelPlaceholder
            
            if #available(iOS 13, *) {
                label.textColor = .placeholderText
                backgroundColor = .systemGray5
            } else {
                backgroundColor = UIColor(red:0.936, green:0.941, blue:0.950, alpha:1.000)
                label.textColor = UIColor(red:0.149, green:0.149, blue:0.149, alpha:1.000)
            }
        }
    }
    
    var date: Date! {
        didSet {
            dateChanged(isSet: date != nil)
            
        }
    }
    private let labelPlaceholder: String
    private let label = UILabel()
    
    
    var isInitialLayout = true
    override func layoutSubviews() {
        if isInitialLayout {
            isInitialLayout = false
            
            widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
            
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let leftRightPadding: CGFloat = 16
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: leftRightPadding).isActive = true
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -leftRightPadding).isActive = true
            label.topAnchor.constraint(equalTo: topAnchor, constant: -2).isActive = true
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2).isActive = true
            
        }
        
        layer.cornerRadius = frame.height / 2
    }
    
    

    init(name: String) {
        labelPlaceholder = name

        super.init(frame: .zero)
        
        layer.masksToBounds = true
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        
        dateChanged(isSet: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.8
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveLinear, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
}
