//
//  AdNavigationView.swift
//  StuDo
//
//  Created by Andrew on 4/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class AdNavigationView: UIView {
    
    var collectionView: UICollectionView!
    
    init() {
        super.init(frame: .zero)
        setupCollectionView()

        backgroundColor = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var initialLayout = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if initialLayout {
            initialLayout = false
            
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
            addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            setupCollectionViewLayout()
            
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
    }
    
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: 80, height: 44)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = nil
        collectionView.alwaysBounceHorizontal = true
    }
    
    private func setupCollectionViewLayout() {
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    public func reloadCollectionView() {
        collectionView.removeFromSuperview()
        collectionView = nil
        setupCollectionView()
        setupCollectionViewLayout()
    }

}


class AdNavigationCell: UICollectionViewCell {
    
    let label = UILabel()
    let highlightView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        label.font = .preferredFont(for: .subheadline, weight: .medium)
        label.textColor = .secondaryLabel
        
        contentView.addSubview(highlightView)
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        highlightView.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        highlightView.centerYAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        highlightView.widthAnchor.constraint(equalTo: label.widthAnchor, multiplier: 0.95, constant: 0).isActive = true
        highlightView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        
        highlightView.backgroundColor = .globalTintColor
        highlightView.layer.cornerRadius = 2
        highlightView.isHidden = true

    }
    
    override func prepareForReuse() {
        highlightView.backgroundColor = .globalTintColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isWidthCalculated: Bool = false

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        if !isWidthCalculated {
            setNeedsLayout()
            layoutIfNeeded()
            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
            var newFrame = layoutAttributes.frame
            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
            layoutAttributes.frame = newFrame
            isWidthCalculated = true
        }
        return layoutAttributes
    }
    
    
    override var isSelected: Bool {
        didSet {
            highlightView.animateVisibility(shouldHide: !isSelected)
            UIView.animate(withDuration: 0.4) {
                if self.isSelected {
                    self.label.textColor = .globalTintColor
                } else {
                    self.label.textColor = .secondaryLabel
                }
            }
            
        }
    }
    
    
}
