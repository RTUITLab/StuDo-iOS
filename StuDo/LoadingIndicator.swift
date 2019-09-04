//
//  LoadingIndicator.swift
//  StuDo
//
//  Created by Andrew on 8/29/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class LoadingIndicator: UIView {
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var isInitialLayout = true
    
    let indicatorContainer = UIView()
    let indicatorLayer = CAShapeLayer()
    
    let doneImageView = UIImageView()
    
    var blurView: UIVisualEffectView!
    var vibrancyView: UIVisualEffectView!
    
    fileprivate func addRotationAnimation() {
        let rotationAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform))
        rotationAnimation.repeatCount = Float.infinity
        
        let rotationValue1 = indicatorLayer.transform
        let rotationValue2 = CATransform3DRotate(indicatorLayer.transform, CGFloat.pi / 2, 0, 0, 1)
        let rotationValue3 = CATransform3DRotate(indicatorLayer.transform, CGFloat.pi, 0, 0, 1)
        let rotationValue4 = CATransform3DRotate(indicatorLayer.transform, 3 * CGFloat.pi / 2, 0, 0, 1)
        let rotationValue5 = CATransform3DRotate(indicatorLayer.transform, 2 * CGFloat.pi, 0, 0, 1)
        
        rotationAnimation.values = [rotationValue1, rotationValue2, rotationValue3, rotationValue4, rotationValue5]
        rotationAnimation.duration = 0.8
        
        indicatorLayer.add(rotationAnimation, forKey: #keyPath(CALayer.transform))
        
    }
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        
        indicatorLayer.strokeColor = UIColor.darkGray.cgColor
        indicatorLayer.fillColor = UIColor.init(white: 0, alpha: 0).cgColor
        indicatorLayer.lineWidth = 4
        indicatorLayer.lineCap = .round
        
        doneImageView.tintColor = .darkGray
        doneImageView.contentMode = .scaleAspectFit
        
        doneImageView.isHidden = true
        doneImageView.alpha = 0
        
        alpha = 0
        isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isInitialLayout {
            isInitialLayout = false
            
            addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            blurView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            
            
            blurView.contentView.addSubview(vibrancyView)
            vibrancyView.translatesAutoresizingMaskIntoConstraints = false
            vibrancyView.topAnchor.constraint(equalTo: blurView.topAnchor).isActive = true
            vibrancyView.rightAnchor.constraint(equalTo: blurView.rightAnchor).isActive = true
            vibrancyView.bottomAnchor.constraint(equalTo: blurView.bottomAnchor).isActive = true
            vibrancyView.leftAnchor.constraint(equalTo: blurView.leftAnchor).isActive = true
            
            
            
            addSubview(indicatorContainer)
            indicatorContainer.translatesAutoresizingMaskIntoConstraints = false
            indicatorContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
            indicatorContainer.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            indicatorContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            indicatorContainer.leftAnchor.constraint(equalTo: leftAnchor).isActive = true

            
            
            indicatorContainer.layer.addSublayer(indicatorLayer)
            
            
            
            let doneImageViewSize: CGFloat = 32
            addSubview(doneImageView)
            doneImageView.translatesAutoresizingMaskIntoConstraints = false
            doneImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            doneImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            doneImageView.widthAnchor.constraint(equalToConstant: doneImageViewSize).isActive = true
            doneImageView.heightAnchor.constraint(equalToConstant: doneImageViewSize).isActive = true
            
            
        }
        
        indicatorLayer.bounds = bounds
        indicatorLayer.position = indicatorContainer.center
        
        indicatorLayer.path = UIBezierPath(arcCenter: indicatorContainer.center, radius: frame.width / 2 - 12, startAngle: 0, endAngle: CGFloat.pi / 3, clockwise: true).cgPath

    }
    
    
    
    var isActive: Bool {
        return isHidden
    }
    
    
    func startIndicator() {
        hapticFeedback.prepare()
        
        isHidden = false
        
        indicatorContainer.isHidden = false
        indicatorContainer.alpha = 1
        
        alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 1
        }) { _ in
            self.addRotationAnimation()
        }
        
    }
    
    
    
    enum StopIndicatorType {
        case success
        case fail
    }
    
    func stopIndicator(with stopReason: StopIndicatorType, completion: (() -> ())? = nil) {
        
        var feedback: UINotificationFeedbackGenerator.FeedbackType
        switch stopReason {
        case .success:
            doneImageView.image = #imageLiteral(resourceName: "loading-indicator-done").withRenderingMode(.alwaysTemplate)
            feedback = .success
        case .fail:
            doneImageView.image = #imageLiteral(resourceName: "loading-indicator-error").withRenderingMode(.alwaysTemplate)
            feedback = .error
        }
        
        doneImageView.isHidden = false
        doneImageView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.indicatorContainer.alpha = 0
        }) { _ in
            self.indicatorContainer.isHidden = true
            self.indicatorContainer.layer.removeAllAnimations()
            self.hapticFeedback.notificationOccurred(feedback)
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveLinear, animations: {
            self.doneImageView.alpha = 1
        })
        
        UIView.animate(withDuration: 0.3, delay: 1, options: .curveLinear, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            self.doneImageView.isHidden = true
            self.doneImageView.alpha = 0
            completion?()
        }
    }
    
    
}

