//
//  AdViewController.swift
//  StuDo
//
//  Created by Andrew on 5/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit


protocol AdViewControllerDelegate: class {
    func adViewController(_ adVC: AdViewController, didCreateAd createdAd: Ad)
    func adViewController(_ adVC: AdViewController, didDeleteAd deletedAd: Ad)
    func adViewController(_ adVC: AdViewController, didUpdateAd updatedAd: Ad)
}

extension AdViewControllerDelegate {
    func adViewController(_ adVC: AdViewController, didCreateAd createdAd: Ad) {}
    func adViewController(_ adVC: AdViewController, didDeleteAd deletedAd: Ad) {}
    func adViewController(_ adVC: AdViewController, didUpdateAd updatedAd: Ad) {}
}



class AdViewController: CardViewController {
    
    weak var delegate: AdViewControllerDelegate?
    
    // MARK: Data & Logic
    
    private var advertisement: Ad?
    func set(advertisement: Ad?) {
        self.advertisement = advertisement
        if let ad = advertisement {
            nameTextField.text = ad.name
            
            if let description = ad.description {
                if description.contains(ad.shortDescription) {
                    descriptionTextView.text = description
                } else {
                    descriptionTextView.text = ad.shortDescription + "\n\n" + description
                }
            } else {
                descriptionTextView.text = ad.shortDescription
            }
            
            additionalInfoLabel.attributedText = TextFormatter.additionalInfoAttributedString(for: ad, style: .body)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.adjustContentLayout()
            }
        }
    }
    
    let client = APIClient()
    
    enum AdViewerMode {
        case viewing
        case editing
    }
    var currentMode: AdViewerMode = .viewing
    
    var isViewerOwner: Bool {
        didSet {
            if isViewerOwner {
                moreButton.isHidden = false
            }
        }
    }
    
    private var shouldDisappearOnEditingCancellation = false
    
    // MARK: Visible properties
    
    let nameTextField = UITextField()
    let descriptionTextView = UITextView()
    let descriptionPlaceholderLabel = UILabel()
    let additionalInfoLabel = UILabel()
    
    let moreButton = UIButton()
    let publishButton = UIButton()
    let cancelEditingButton = UIButton()
    
    
    
    let nameTextFieldHeight: CGFloat = 20
    
    override var contentHeight: CGFloat {
        var additionalHeight: CGFloat = 8
        if currentMode == .viewing {
            additionalHeight = additionalInfoLabel.frame.height * 3
        }
        let calculatedHeight = headerView.frame.height + nameTextFieldHeight + descriptionTextView.frame.height + view.safeAreaInsets.bottom + additionalHeight
        return calculatedHeight
    }
    
    
    
    init(with ad: Ad?, isOwner: Bool = false) {
        self.isViewerOwner = isOwner

        super.init()

        client.delegate = self
        
        if let ad = ad {
            set(advertisement: ad)
            client.getAd(withId: ad.id)
            descriptionPlaceholderLabel.isHidden = true
        } else {
            descriptionPlaceholderLabel.isHidden = false
        }
        
        additionalInfoLabel.textColor = UIColor(red:0.467, green:0.467, blue:0.471, alpha:1.000)
        
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
        nameTextField.heightAnchor.constraint(equalToConstant: nameTextFieldHeight).isActive = true
        
        
        contentView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: -4).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: horizontalSpace).isActive = true
        
        
        
        contentView.addSubview(descriptionPlaceholderLabel)
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor).isActive = true
        descriptionPlaceholderLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 7).isActive = true
        
        
        contentView.addSubview(additionalInfoLabel)
        additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalInfoLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor).isActive = true
        additionalInfoLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        additionalInfoLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 7).isActive = true
        
        
        
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
        moreButton.tintColor = UIColor(red:0.815, green:0.819, blue:0.837, alpha:1.000)
        moreButton.adjustsImageWhenHighlighted = false
        moreButton.isHidden = true
        
        
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
        
        
        
        
        
        
        
        
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
        
        moreButton.addTarget(self, action: #selector(moreButtonPressed(_:)), for: .touchUpInside)
        cancelEditingButton.addTarget(self, action: #selector(cancelEditingButtonPressed(_:)), for: .touchUpInside)
        publishButton.addTarget(self, action: #selector(publishButtonPressed(_:)), for: .touchUpInside)
        
        descriptionTextView.layoutManager.delegate = self
        descriptionTextView.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameTextField.delegate = self
        
        nameTextField.font = .preferredFont(forTextStyle: .headline)
        nameTextField.placeholder = Localizer.string(for: .adEditorNamePlaceholder)
        nameTextField.returnKeyType = .next
        nameTextField.autocapitalizationType = .sentences

        descriptionTextView.isScrollEnabled = false
        descriptionTextView.font = .preferredFont(forTextStyle: .body)
        descriptionTextView.returnKeyType = .default
        descriptionTextView.autocapitalizationType = .sentences
        
        
        
        descriptionPlaceholderLabel.text = Localizer.string(for: .adEditorDescriptionPlaceholder)
        descriptionPlaceholderLabel.textColor = .lightGray
        descriptionPlaceholderLabel.font = .preferredFont(forTextStyle: .body)
        descriptionPlaceholderLabel.numberOfLines = 3
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if currentMode == .editing {
            enableEditingMode()
        }
    }
    
    
    
    
    
    
    override func didEnterFullscreen() {
        nameTextField.becomeFirstResponder()
    }
    
    override func shouldAllowDismissOnSwipe() -> Bool {
        if currentMode == .editing {
            return false
        }
        return true
    }
    
    func enableEditingMode() {
        currentMode = .editing
        isFullscreen = true
        
        if advertisement == nil {
            title = Localizer.string(for: .adEditorCreationModeTitle)
        } else {
            title = Localizer.string(for: .adEditorEditingModeTitle)
        }
        
        nameTextField.isUserInteractionEnabled = true
        descriptionTextView.isUserInteractionEnabled = true
        additionalInfoLabel.isHidden = true
        
        self.publishButton.isHidden = false
        self.cancelEditingButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.moreButton.alpha = 0
            self.publishButton.alpha = 1
            self.cancelEditingButton.alpha = 1
        }) { _ in
            self.moreButton.isHidden = true
        }
        checkIfCanPublish(isInitialRun: true)
    }
    
    func disableEditingMode(completion: (() -> ())? ) {
        currentMode = .viewing
        isFullscreen = false
        title = nil
        
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
        additionalInfoLabel.isHidden = false
        
        self.moreButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.moreButton.alpha = 1
            self.publishButton.alpha = 0
            self.cancelEditingButton.alpha = 0
        }) { _ in
            self.publishButton.isHidden = true
            self.cancelEditingButton.isHidden = true
            
            completion?()
            
            // wait for some time so that to let all text fields draw themselves and then adjust the layout of content
            let waitTime = DispatchTime(uptimeNanoseconds: 100)
            DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
                self.adjustContentLayout()
                if self.shouldDisappearOnEditingCancellation {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    
    
    
    func cancelEditingAd() {
        func cancelEditing() {
            disableEditingMode {
                self.set(advertisement: self.advertisement) // clears the unsaved state
            }
        }
        
        contentView.endEditing(true)
        
        // If the ad is being created and no progress is made, dismiss the controller
        
        var alertMessage = Localizer.string(for: .adEditorCancelEditingAlertMessage)
        var deleteActionMessage = Localizer.string(for: .adEditorDiscardChanges)
        if advertisement == nil {
            alertMessage = Localizer.string(for: .adEditorCancelCreatingAlertMessage)
            deleteActionMessage = Localizer.string(for: .adEditorCancelAdCreation)
            if nameTextField.text!.isEmpty && descriptionTextView.text!.isEmpty {
                dismiss(animated: true, completion: nil)
            }
        }
        
        
        let shouldProceedAlert = UIAlertController(title: alertMessage, message: nil, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: deleteActionMessage, style: .destructive, handler: { _ in
            if self.advertisement == nil {
                self.shouldDisappearOnEditingCancellation = true
            }
            cancelEditing()
        } )
        let cancelAction = UIAlertAction(title: Localizer.string(for: .adEditorReturnToEditor), style: .cancel, handler: nil)
        
        shouldProceedAlert.addAction(deleteAction)
        shouldProceedAlert.addAction(cancelAction)
        
        present(shouldProceedAlert, animated: true, completion: nil)

    }
    
    
    func deleteCurrentAd() {
        func deleteAd() {
            client.deleteAd(withId: advertisement!.id)
            RootViewController.startLoadingIndicator()
        }
        
        let shouldProceedAlert = UIAlertController(title: Localizer.string(for: .adEditorDeleteAlertMessage), message: nil, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: Localizer.string(for: .delete), style: .destructive, handler: { _ in deleteAd() } )
        let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)
        
        shouldProceedAlert.addAction(deleteAction)
        shouldProceedAlert.addAction(cancelAction)
        
        present(shouldProceedAlert, animated: true, completion: nil)
    }
    
    func checkIfCanPublish(isInitialRun: Bool = false) {
        var shouldAllowPublishing = true
        
        if isInitialRun {
            shouldAllowPublishing = false
        } else {
            let title = nameTextField.text!
            let description = descriptionTextView.text!
            
            if title.isEmpty {
                shouldAllowPublishing = false
            }
            
            if description.isEmpty {
                shouldAllowPublishing = false
            }
        }
        
        if shouldAllowPublishing {
            publishButton.isEnabled = true
            publishButton.tintColor = UIColor(red:0.000, green:0.512, blue:0.870, alpha:1.000)
        } else {
            publishButton.isEnabled = false
            publishButton.tintColor = UIColor(red:0.936, green:0.941, blue:0.950, alpha:1.000)
        }
    }
    
    func publishCurrentAd() {
        let title = nameTextField.text!
        let description = descriptionTextView.text!
        var shortDescription: String!
        
        if let firstParagraph = description.components(separatedBy: CharacterSet.newlines).first {
            shortDescription = firstParagraph
        } else {
            shortDescription = description
        }
        
        let beginTime = Date()
        let endTime = Date().addingTimeInterval(TimeInterval(exactly: 60 * 60 * 60)!)
        
        RootViewController.startLoadingIndicator()

        if let oldAd = advertisement {
            
            let adToUpdate = Ad(id: oldAd.id, name: title, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime)
            
            client.replaceAd(with: adToUpdate)
            
        } else {
            let newAd = Ad(id: nil, name: title, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime)
            
            client.create(ad: newAd)
        }
        
        
    }
    
    
}






extension AdViewController {
    @objc func moreButtonPressed(_ button: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let inviteAction = UIAlertAction(title: Localizer.string(for: .adEditorFindPeople), style: .default, handler: nil)
        let editAction = UIAlertAction(title: Localizer.string(for: .adEditorEditAd), style: .default, handler: { _ in self.enableEditingMode() } )
        let deleteAction = UIAlertAction(title: Localizer.string(for: .adEditorDeleteAd), style: .destructive, handler: { _ in self.deleteCurrentAd() } )
        let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)

        actionSheet.addAction(inviteAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)

    }
    
    @objc func cancelEditingButtonPressed(_ button: UIButton) {
        cancelEditingAd()
    }
    
    @objc func publishButtonPressed(_ button: UIButton) {
        publishCurrentAd()
    }
}




extension AdViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {
        
        if let userId = ad.userId, userId == PersistentStore.shared.user!.id {
            isViewerOwner = true
        }
        
        set(advertisement: ad)
    }
    
    func apiClient(_ client: APIClient, didCreateAd newAd: Ad) {
        set(advertisement: newAd)
        delegate?.adViewController(self, didCreateAd: newAd)
        
        RootViewController.stopLoadingIndicator(with: .success) {
            self.disableEditingMode(completion: nil)
        }
    }
    
    func apiClient(_ client: APIClient, didUpdateAd updatedAd: Ad) {
        set(advertisement: updatedAd)
        delegate?.adViewController(self, didUpdateAd: updatedAd)
        RootViewController.stopLoadingIndicator(with: .success) {
            self.disableEditingMode(completion: nil)
        }
    }
    
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String) {
        delegate?.adViewController(self, didDeleteAd: advertisement!)
        
        RootViewController.stopLoadingIndicator(with: .success) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error.localizedDescription)
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    
}





extension AdViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 6
    }
}




extension AdViewController: UITextFieldDelegate, UITextViewDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkIfCanPublish()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            descriptionTextView.becomeFirstResponder()
        }
        return false
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView === descriptionTextView {
            if textView.text != "" {
                descriptionPlaceholderLabel.isHidden = true
            } else {
                descriptionPlaceholderLabel.isHidden = false
            }
            let waitTime = DispatchTime(uptimeNanoseconds: 100)
            DispatchQueue.main.asyncAfter(deadline: waitTime, execute: {
                self.adjustContentLayout()
            })
        }
        
        checkIfCanPublish()
    }
}
