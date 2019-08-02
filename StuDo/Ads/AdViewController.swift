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
    
    var advertisement: Ad? {
        didSet {
            if let ad = advertisement {
                nameTextField.text = ad.name
                descriptionTextView.text = ad.description
            }
        }
    }
    
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
    
    let nameTextField = UITextField()
//    let shortDescriptionTextField = UITextField()
    let descriptionTextView = UITextView()
    
    let moreButton = UIButton()
    let publishButton = UIButton()
    let cancelEditingButton = UIButton()
    
    
    override var contentHeight: CGFloat {
        let calculatedHeight = headerView.frame.height + 40 + descriptionTextView.frame.height
        return calculatedHeight
    }
    
    
    
    init(withID id: String?) {
        super.init()
        
        client.delegate = self
        
        if GCIsUsingFakeData != true {
            if let id = id {
                client.getAd(withId: id)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let horizontalSpace: CGFloat = 8
        
        contentView.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16).isActive = true
        nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: horizontalSpace).isActive = true
        
        
//        contentView.addSubview(shortDescriptionTextField)
//        shortDescriptionTextField.translatesAutoresizingMaskIntoConstraints = false
//        shortDescriptionTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: 3).isActive = true
//        shortDescriptionTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
//        shortDescriptionTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: horizontalSpace).isActive = true
        
        
        contentView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: -4).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: horizontalSpace).isActive = true
        
        
        
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
        
        
        
        
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
        
        moreButton.addTarget(self, action: #selector(moreButtonPressed(_:)), for: .touchUpInside)
        cancelEditingButton.addTarget(self, action: #selector(cancelEditingButtonPressed(_:)), for: .touchUpInside)
        
        descriptionTextView.layoutManager.delegate = self
        descriptionTextView.delegate = self
        
        
        nameTextField.font = .systemFont(ofSize: 20, weight: .medium)
        nameTextField.placeholder = "Name for your advertisement"

        descriptionTextView.isScrollEnabled = false
        descriptionTextView.font = .systemFont(ofSize: 18, weight: .light)

    }
    
    
    
    func enableEditingMode() {
        currentMode = .editing
        
        nameTextField.isUserInteractionEnabled = true
        descriptionTextView.isUserInteractionEnabled = true
        
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
        
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
        
        self.moreButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.moreButton.alpha = 1
            self.publishButton.alpha = 0
            self.cancelEditingButton.alpha = 0
        }) { _ in
            self.publishButton.isHidden = true
            self.cancelEditingButton.isHidden = true
            self.nameTextField.resignFirstResponder()
        }
        

    }
    
    override func didEnterFullscreen() {
        nameTextField.becomeFirstResponder()
    }
    
    
    
    func deleteCurrentAd() {
        func deleteAd() {
            client.deleteAd(withId: advertisement!.id)
        }
        
        let shouldProceedAlert = UIAlertController(title: "Are you sure you want to delete this ad? This cannot be undone.", message: nil, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in deleteAd() } )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        shouldProceedAlert.addAction(deleteAction)
        shouldProceedAlert.addAction(cancelAction)
        
        present(shouldProceedAlert, animated: true, completion: nil)
    }
    
    

    
    
}






extension AdViewController {
    @objc func moreButtonPressed(_ button: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let inviteAction = UIAlertAction(title: "Invite People", style: .default, handler: nil)
        let editAction = UIAlertAction(title: "Edit Ad", style: .default, handler: { _ in self.enableEditingMode() } )
        let deleteAction = UIAlertAction(title: "Delete Ad", style: .destructive, handler: { _ in self.deleteCurrentAd() } )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

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
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {
        advertisement = ad
    }
    
    func apiClient(_ client: APIClient, didUpdateAdWithID: String) {
        
    }
    
    func apiClient(_ client: APIClient, didDeleteAdWithID: String) {
        dismiss(animated: true, completion: nil)
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error.localizedDescription)
    }
    
    
}





extension AdViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 10
    }
}




extension AdViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === descriptionTextView {
            adjustContentLayout()
        }
    }
}
