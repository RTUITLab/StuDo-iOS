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
    var isEditingAllowed = false
    var isEditingEnabled = false
    
    
    // MARK: Visible properties
    
    var shadowView = UIView()
    var containerView = UIScrollView()
    var cardView = UIView()
    var contentView = UIScrollView()
    
    var nameLabel = UITextField()
    var descriptionLabel = UITextView()
    var editButton = UIButton()
    var deleteButton = UIButton()
    
    let client = APIClient()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        if showedAd?.userId == PersistentStore.shared.user.id {
            isEditingAllowed = true
        }
        
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
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        if isEditingAllowed {
            contentView.addSubview(editButton)
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
            editButton.centerYAnchor.constraint(equalTo:
                nameLabel.centerYAnchor).isActive = true
            
            contentView.addSubview(deleteButton)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -12).isActive = true
            deleteButton.centerYAnchor.constraint(equalTo:
                editButton.centerYAnchor).isActive = true
            
            editButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            
            
            nameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -12).isActive = true
        } else {
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -2).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6).isActive = true
        
        // Look customization
        
        nameLabel.font = .systemFont(ofSize: 22, weight: .medium)
        descriptionLabel.isScrollEnabled = false
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        let attributedText = NSAttributedString(string: showedAd?.shortDescription ?? "",
                                                attributes: [
                                                    .paragraphStyle:style,
                                                    .font: UIFont.systemFont(ofSize: 16, weight: .light)
                                                ])
        descriptionLabel.attributedText = attributedText
        
        nameLabel.isUserInteractionEnabled = false
        descriptionLabel.isUserInteractionEnabled = false
        
        
        nameLabel.text = showedAd?.name
        
        editButton.setTitleColor(editButton.tintColor, for: .normal)
        editButton.setTitleColor(.white, for: .highlighted)
        editButton.setTitleColor(.white, for: .selected)
        
        editButton.clipsToBounds = true
        
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitle("Done", for: .selected)
        editButton.layer.cornerRadius = 6
        editButton.layer.borderWidth = 1.5
        editButton.layer.borderColor = editButton.tintColor.cgColor
        
        
        
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.setTitleColor(UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), for: .highlighted)
        
        deleteButton.clipsToBounds = true
        
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.layer.cornerRadius = 6
        deleteButton.layer.borderWidth = 1.5
        deleteButton.layer.borderColor = UIColor.red.cgColor
        
        if isEditingAllowed {
            editButton.isHidden = false
            editButton.addTarget(self, action: #selector(enableEditButtonPressed(_:)), for: .touchUpInside)
            
            deleteButton.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
            
            nameLabel.placeholder = "Name for your advertisement"
        } else {
            editButton.isHidden = true
        }
    }
    
    @objc func enableEditButtonPressed(_ button: UIButton) {
        
        if isEditingEnabled {
            if let ad = showedAd {
                
                // TODO: Change the date to actual data
                let adToEdit = Ad(id: ad.id, name: nameLabel.text!, fullDescription: "full Description", shortDescription: descriptionLabel.text!, beginTime: Date(), endTime: Date(timeInterval: 50000, since: Date()), userId: PersistentStore.shared.user.id!, user: nil, organizationId: nil, organization: nil)
                client.replaceAd(with: adToEdit)

            }
        }
        
        isEditingEnabled = !isEditingEnabled
        
        nameLabel.isUserInteractionEnabled = isEditingEnabled
        descriptionLabel.isUserInteractionEnabled = isEditingEnabled
        editButton.isSelected = isEditingEnabled

        if isEditingEnabled {
            editButton.backgroundColor = editButton.tintColor
            nameLabel.becomeFirstResponder()
        } else {
            editButton.backgroundColor = nil
        }
    }
    
    @objc func deleteButtonPressed(_ button: UIButton) {
        
        client.delete(ad: showedAd!)
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


extension AdViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didUpdateAd: Ad) {
        print("updated successfully!")
    }
    
    func apiClient(_ client: APIClient, didDeleteAd: Ad) {
        print("deleted successfully!")
        dismiss(animated: true, completion: nil)
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error)
    }
    
    
}
