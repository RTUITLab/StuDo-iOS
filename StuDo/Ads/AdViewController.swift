//
//  AdViewController.swift
//  StuDo
//
//  Created by Andrew on 5/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit


class AdViewController: CardViewController {
    
    // MARK: Data & Logic
    
    var advertisement: Ad?
    
    let client = APIClient()
    
    enum AdViewerMode {
        case viewing
        case viewingAsOwner
        case editing
    }
    var currentMode: AdViewerMode = .viewingAsOwner {
        didSet {
            if currentMode == .editing {
                isFullscreen = true
                title = "Editing"
            } else {
                isFullscreen = false
                title = nil
            }
        }
    }
    
    
    // MARK: Visible properties
    
    let nameLabel = UITextField()
    let descriptionLabel = UITextView()
    
    let moreButton = UIButton()
    let publishButton = UIButton()
    let cancelEditingButton = UIButton()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        
        
        // Layout
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -2).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6).isActive = true
        
        
        
        if currentMode == .viewingAsOwner || currentMode == .editing {
            let leftRightPadding: CGFloat = 16
            
            let moreButtonSize: CGFloat = 20
            headerView.addSubview(moreButton)
            moreButton.translatesAutoresizingMaskIntoConstraints = false
            moreButton.widthAnchor.constraint(equalToConstant: moreButtonSize).isActive = true
            moreButton.heightAnchor.constraint(equalToConstant: moreButtonSize).isActive = true
            moreButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
            moreButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -leftRightPadding).isActive = true
            
            let moreButtonImage = #imageLiteral(resourceName: "three-dots-menu").withRenderingMode(.alwaysTemplate)
            moreButton.setImage(moreButtonImage, for: .normal)
            moreButton.tintColor = UIColor(red:0.690, green:0.690, blue:0.699, alpha:1.000)
            moreButton.adjustsImageWhenHighlighted = false
            
            
            let publishButtonSize: CGFloat = 28
            headerView.addSubview(publishButton)
            publishButton.translatesAutoresizingMaskIntoConstraints = false
            publishButton.widthAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
            publishButton.heightAnchor.constraint(equalToConstant: publishButtonSize).isActive = true
            publishButton.centerYAnchor.constraint(equalTo: moreButton.centerYAnchor).isActive = true
            publishButton.centerXAnchor.constraint(equalTo: moreButton.centerXAnchor).isActive = true
            
            let publishButtonImage = #imageLiteral(resourceName: "publish-button").withRenderingMode(.alwaysTemplate)
            publishButton.setImage(publishButtonImage, for: .normal)
            publishButton.setImage(publishButtonImage, for: .disabled)
            publishButton.tintColor = UIColor(red:0.000, green:0.512, blue:0.870, alpha:1.000)
            publishButton.adjustsImageWhenHighlighted = false
            publishButton.alpha = 0
            publishButton.isHidden = true
            
            
            
            let cancelEditingButtonSize: CGFloat = 24
            headerView.addSubview(cancelEditingButton)
            cancelEditingButton.translatesAutoresizingMaskIntoConstraints = false
            cancelEditingButton.widthAnchor.constraint(equalToConstant: cancelEditingButtonSize).isActive = true
            cancelEditingButton.heightAnchor.constraint(equalToConstant: cancelEditingButtonSize).isActive = true
            cancelEditingButton.centerYAnchor.constraint(equalTo: moreButton.centerYAnchor).isActive = true
            cancelEditingButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: leftRightPadding).isActive = true
            
            let cancelEditingButtonImage = #imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysOriginal)
            cancelEditingButton.setImage(cancelEditingButtonImage, for: .normal)
            cancelEditingButton.alpha = 0
            cancelEditingButton.isHidden = true

        }
        
        
        
        
        
        // Look customization
        
        nameLabel.font = .systemFont(ofSize: 22, weight: .medium)
        descriptionLabel.isScrollEnabled = false
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        let attributedText = NSAttributedString(string: advertisement?.shortDescription ?? "",
                                                attributes: [
                                                    .paragraphStyle:style,
                                                    .font: UIFont.systemFont(ofSize: 16, weight: .light)
            ])
        descriptionLabel.attributedText = attributedText
        
        nameLabel.isUserInteractionEnabled = false
        descriptionLabel.isUserInteractionEnabled = false
        
        nameLabel.placeholder = "Name for your advertisement"
        
        
        
        
        moreButton.addTarget(self, action: #selector(moreButtonPressed(_:)), for: .touchUpInside)
        cancelEditingButton.addTarget(self, action: #selector(cancelEditingButtonPressed(_:)), for: .touchUpInside)

    }
    
    func printHello(_ action: UIAlertAction) {
        print(action.title ?? "hello")
    }
    
    func enableEditingMode() {
        currentMode = .editing
        
        nameLabel.isUserInteractionEnabled = true
        descriptionLabel.isUserInteractionEnabled = true
        
        self.publishButton.isHidden = false
        self.cancelEditingButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.moreButton.alpha = 0
            self.publishButton.alpha = 1
            self.cancelEditingButton.alpha = 1
        }) { _ in
            self.moreButton.isHidden = true
        }
        publishButton.isEnabled = false
        
    }
    
    func cancelEditingAd() {
        currentMode = .viewing
        
        nameLabel.isUserInteractionEnabled = false
        descriptionLabel.isUserInteractionEnabled = false
        
        self.moreButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.moreButton.alpha = 1
            self.publishButton.alpha = 0
            self.cancelEditingButton.alpha = 0
        }) { _ in
            self.publishButton.isHidden = true
            self.cancelEditingButton.isHidden = true
            self.nameLabel.resignFirstResponder()
        }
        

    }
    
    override func didEnterFullscreen() {
        nameLabel.becomeFirstResponder()
    }

}






extension AdViewController {
    @objc func moreButtonPressed(_ button: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let inviteAction = UIAlertAction(title: "Invite People", style: .default, handler: printHello(_:))
        let editAction = UIAlertAction(title: "Edit Ad", style: .default, handler: { _ in self.enableEditingMode() } )
        let deleteAction = UIAlertAction(title: "Delete Ad", style: .destructive, handler: printHello(_:))
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: printHello(_:))

        actionSheet.addAction(inviteAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)

    }
    
    @objc func cancelEditingButtonPressed(_ button: UIButton) {
        cancelEditingAd()
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
