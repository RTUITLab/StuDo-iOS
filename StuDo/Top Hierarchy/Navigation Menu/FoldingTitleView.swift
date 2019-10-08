//
//  FoldingTitleView.swift
//  StuDo
//
//  Created by Andrew on 8/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

protocol FoldingTitleViewDelegate: class {
    func foldingTitleView(_ foldingTitleView: FoldingTitleView, didChangeState newState: FoldingTitleView.FoldingTitleState)
}

class FoldingTitleView: UIView {
    
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)

    
    weak var delegate: FoldingTitleViewDelegate?
    
    let foldingAnimationDuration: TimeInterval = 0.5
    private var shouldAllowChandingState = true
    
    enum FoldingTitleState {
        case folded
        case unfolded
    }
    private(set) var currentState: FoldingTitleState = .folded
    func changeState() {
        
        var destinationTransform: CGAffineTransform = .identity
        if currentState == .folded {
            currentState = .unfolded
            destinationTransform = CGAffineTransform(rotationAngle: CGFloat.pi)
        } else {
            currentState = .folded
        }
        
        UIView.animate(withDuration: foldingAnimationDuration) {
            self.glyph.transform = destinationTransform
        }
        
        delegate?.foldingTitleView(self, didChangeState: currentState)
        impactFeedback.impactOccurred()

    }
    
    let containerView = UIView()
    let titleLabel = UILabel()
    let glyph = UIImageView()

    init() {
        super.init(frame: .zero)
        
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        
        
        containerView.addSubview(glyph)
        glyph.translatesAutoresizingMaskIntoConstraints = false
        glyph.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 1).isActive = true
        glyph.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 3).isActive = true
        glyph.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        
        glyph.widthAnchor.constraint(equalToConstant: 10).isActive = true
        glyph.heightAnchor.constraint(equalTo: glyph.widthAnchor).isActive = true

        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        glyph.image = #imageLiteral(resourceName: "expand arrow").withRenderingMode(.alwaysTemplate)
        glyph.contentMode = .scaleAspectFit
        if #available(iOS 13, *) {
            glyph.tintColor = .label
        } else {
            glyph.tintColor = .black
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        containerView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    
    @objc func handle(tap: UITapGestureRecognizer) {
        guard shouldAllowChandingState == true else { return }
        
        changeState()
        
        shouldAllowChandingState = false
        DispatchQueue.main.asyncAfter(deadline: .now() + foldingAnimationDuration) {
            self.shouldAllowChandingState = true
        }
        
    }
    
}
