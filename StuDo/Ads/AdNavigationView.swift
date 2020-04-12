//
//  AdNavigationView.swift
//  StuDo
//
//  Created by Andrew on 4/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class AdNavigationView: UIScrollView {
    
    private var labels = [UILabel]()
    
    let titles = [
        Localizer.string(for: .navigationMenuAllAds),
        Localizer.string(for: .navigationMenuMyAds),
        Localizer.string(for: .navigationMenuBookmarks)
    ]
    
    var selectedIndex: Int = 0

    var initialLayout = true
    override func layoutSubviews() {
        super.layoutSubviews()
        if initialLayout {
            initialLayout = false
            self.isScrollEnabled = true
            self.alwaysBounceHorizontal = true
            self.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            
            labels = titles.enumerated().map({ (index, title) -> UILabel in
                let label = UILabel()
                label.text = title
                label.font = .preferredFont(for: .subheadline, weight: .medium)
                label.textColor = .secondaryLabel
                label.tag = index
                return label
            })
            
            labels[selectedIndex].textColor = .globalTintColor
            
            let stackView = UIStackView(arrangedSubviews: labels)
            
            self.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .equalSpacing
            stackView.spacing = 22
            
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
            blurView.frame = CGRect(origin: CGPoint(x: -200, y: 0), size: CGSize(width: self.frame.width + 400, height: self.frame.height))
            self.insertSubview(blurView, belowSubview: stackView)
            
            let handleHeight: CGFloat = 5
            let handleView = UIView()
            self.addSubview(handleView)
            handleView.translatesAutoresizingMaskIntoConstraints = false
            handleView.centerXAnchor.constraint(equalTo: labels[selectedIndex].centerXAnchor).isActive = true
            handleView.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -1).isActive = true
            handleView.widthAnchor.constraint(equalTo: labels[selectedIndex].widthAnchor, multiplier: 1, constant: 0).isActive = true
            handleView.heightAnchor.constraint(equalToConstant: handleHeight).isActive = true
            
            handleView.backgroundColor = .globalTintColor
            handleView.layer.cornerRadius = handleHeight / 2
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:)))
            self.addGestureRecognizer(tap)
            
        }
    }
    
    public var actionClosure: ((Int)->())? = nil
    
    @objc func didTapLabel(_ tap: UITapGestureRecognizer) {
        guard let selectedIndex = labels
            .enumerated()
            .filter({ $1.frame.contains(tap.location(in: self))})
            .map({ $0.offset }).first
            else { return }
        actionClosure?(selectedIndex)
    }

}
