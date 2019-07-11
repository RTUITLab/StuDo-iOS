//
//  AdViewController.swift
//  StuDo
//
//  Created by Andrew on 5/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AdViewController: UIViewController {
    
    // MARK: Data & Logic
    
    var showedAd: Ad?
    
    var isBeingTransitioned = false
    
    
    // MARK: Visible properties
    
    var shadowView = UIView()
    var containerView = UIScrollView()
    var cardView = UIView()
    var contentView = UIScrollView()
    
    var nameLabel = UITextField()
    var descriptionLabel = UITextView()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
                
        shadowView.frame = view.frame
        shadowView.backgroundColor = .black
        shadowView.alpha = 0.1
        view.addSubview(shadowView)
        
        containerView.frame = view.frame
        view.addSubview(containerView)
        
        cardView.frame = view.frame
        cardView.frame.origin.y = view.frame.height
        cardView.frame.size.height = view.frame.height - UIApplication.shared.statusBarFrame.height - 40
        containerView.addSubview(cardView)
        
        containerView.contentSize = CGSize(width: containerView.frame.width, height: containerView.frame.height + cardView.frame.height)
        
        contentView.frame = cardView.bounds
        contentView.contentSize = CGSize(width: cardView.frame.width, height: randomLongMeasure)
        cardView.addSubview(contentView)
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        containerView.contentInsetAdjustmentBehavior = .never
        containerView.scrollsToTop = false
        containerView.showsVerticalScrollIndicator = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        containerView.addGestureRecognizer(tap)
        
        containerView.delegate = self
        contentView.delegate = self
        
        
        
        // Layout
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 0).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6).isActive = true
        
        // Look customization
        
        nameLabel.font = .systemFont(ofSize: 22, weight: .medium)
        descriptionLabel.isScrollEnabled = false
        
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        let attributedText = NSAttributedString(string: showedAd?.shortDescription ?? "",
                                                attributes: [
                                                    .paragraphStyle:style,
                                                    .font: UIFont.systemFont(ofSize: 16, weight: .light)
                                                ])
        descriptionLabel.attributedText = attributedText
        
        
        if showedAd?.userId != "" && showedAd?.userId == PersistentStore.shared.user?.id{
            nameLabel.isUserInteractionEnabled = true
            descriptionLabel.isUserInteractionEnabled = true
        } else {
            nameLabel.isUserInteractionEnabled = false
            descriptionLabel.isUserInteractionEnabled = false
        }
        
        
        nameLabel.text = showedAd?.name
    }

}



extension AdViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.contentView {
            let delta = contentView.contentOffset.y
            
            if contentView.contentOffset.y <= 0 && delta < 0 {
                if containerView.contentOffset.y > 0 {
                    // moving card down and hiding it
                    
                    containerView.contentOffset.y += delta
                    contentView.contentOffset.y = 0
                }
            } else if containerView.contentOffset.y < containerView.contentSize.height - containerView.bounds.height {
                if delta > 0 {
                    // moving card up and expanding it

                    containerView.contentOffset.y += delta
                    contentView.contentOffset.y = 0
                }
            }
        }
        
        if containerView.contentOffset.y < 100 {
            self.dismiss(animated: true, completion: nil)
        }
        
        // Otherwise the transitioning delegate handles the alpha property
        if !isBeingTransitioned {
            shadowView.alpha = calculateShadowViewAlpha(forOffsetY: containerView.contentOffset.y)
        }
    }
}


// MARK: Supporting stuff
extension AdViewController {
    @objc func handle(tap: UITapGestureRecognizer) {
        if tap.location(in: containerView).y < containerView.bounds.height {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func calculateShadowViewAlpha(forOffsetY offset: CGFloat) -> CGFloat {
        let scrolledDistance = min(1, max(0, offset / (containerView.contentSize.height - containerView.frame.height)))
        return scrolledDistance * 0.5 + 0.4
    }
}
