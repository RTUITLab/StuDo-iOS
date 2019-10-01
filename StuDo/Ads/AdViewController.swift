//
//  AdViewController.swift
//  StuDo
//
//  Created by Andrew on 5/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import MarkdownKit


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

fileprivate let memberCellId = "memberCellId"
fileprivate let memberCurrentUserCellId = "memberCurrentUserCellId"
fileprivate let commentCellId = "commentCellId"
fileprivate let commentInputCellId = "commentInputCellId"

class AdViewController: CardViewController {
    
    weak var delegate: AdViewControllerDelegate?
    
    // MARK: Data & Logic
    
    var publishableOrganizations: [Organization]?
    var publisherOrganizationId: String?
    
    private var advertisement: Ad?
    func set(advertisement: Ad?) {
        self.advertisement = advertisement
        if let ad = advertisement {
            nameTextField.text = ad.name
            
            var descriptionText: String!
            if let description = ad.description {
                descriptionText = description
            } else {
                descriptionText = ad.shortDescription
            }
            
            let markdownParser = MarkdownParser(font: UIFont.preferredFont(for: .body, weight: .light))
            markdownParser.enabledElements = .all
            markdownParser.bold.font = UIFont.preferredFont(for: .body, weight: .medium)
            markdownParser.italic.font = UIFont.preferredFont(for: .body, weight: .light).italic()
            markdownParser.header.font = UIFont.preferredFont(for: .title3, weight: .medium)
            markdownParser.quote.font = UIFont.preferredFont(for: .body, weight: .light).italic()
            markdownParser.quote.color = .lightGray
            markdownParser.link.color = .globalTintColor
            
            descriptionTextView.attributedText = markdownParser.parse(descriptionText)
            
            additionalInfoLabel.text = ad.dateRange
            
            beginDateButton.date = ad.beginTime
            endDateButton.date = ad.endTime
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.adjustContentLayout()
            }
        }
    }
    
    let client = APIClient()
    
    enum AdViewerMode {
        case viewing
        case editing
        case commenting
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
    
    override var shouldResetOffsetOnKeyboardChange: Bool {
        return currentMode == .editing
    }
    
    // MARK: Visible properties
    
    let nameTextField = UITextField()
    let descriptionTextView = AdDescriptionTextView()
    let descriptionPlaceholderLabel = UILabel()
    let additionalInfoLabel = UILabel()
    let beginDateButton: DateButton!
    let endDateButton: DateButton!
    
    let moreButton = UIButton()
    let publishButton = UIButton()
    let cancelEditingButton = UIButton()
    
    var commentTextView: UITextView!
    var commentPlaceholderLabel: UILabel!
    
    
    let membersTableView = UITableView(frame: .zero, style: .plain)
    var members = [AdParticipant]()
    
    
    var newCommentsCount: Int = 0
    let commentsTableView = UITableView(frame: .zero, style: .plain)
    var comments = [Comment]()
    var publishCommentButton: UIButton!
    
    
    let nonEditingInfoContainer = UIView()
    
    enum AdParticipantType {
        case user
        case organization
        case other
    }
    struct AdParticipant {
        let type: AdParticipantType
        let content: Any?
    }
    
    
    
    let beginDateButtonTopPadding: CGFloat = 12
    let nameTextFieldHeight: CGFloat = 20
    
    var dateButtonBottomConstraint: NSLayoutConstraint!
    var dateButtonTopConstraint: NSLayoutConstraint!
    
    let membersTableViewRowHeight: CGFloat = 55
    var membersTableViewHeightConstraint: NSLayoutConstraint!
    
    let commentsTableViewRowHeight: CGFloat = 55
    var commentsTableViewHeightConstraint: NSLayoutConstraint!
    var scrollToBottomNeeded = false
    
    
    override var contentHeight: CGFloat {
        switch currentMode {
        case .viewing, .commenting:
            let height = contentView.convert(nonEditingInfoContainer.frame.origin, to: containerView).y + nonEditingInfoContainer.frame.height
            if currentMode == .viewing {
                return height + view.safeAreaInsets.bottom
            }
            return height
        case .editing:
            
            // TODO: - Now the old way of handling things is used since the new one brings about lags.
            
//            let height = contentView.convert(descriptionTextView.frame, to: containerView).maxY
//            return height + beginDateButton.frame.height + beginDateButtonTopPadding

            let additionalHeight = beginDateButton.frame.height + beginDateButtonTopPadding + 35
            let calculatedHeight = headerView.frame.height + nameTextFieldHeight + descriptionTextView.frame.height + view.safeAreaInsets.bottom + additionalHeight
            return calculatedHeight

        }
    }
    
    
    
    init(with ad: Ad?, isOwner: Bool = false) {
        self.isViewerOwner = isOwner
        
        self.beginDateButton = DateButton(name: Localizer.string(for: .adEditorBeginDateLabel))
        self.endDateButton = DateButton(name: Localizer.string(for: .adEditorEndDateLabel))

        super.init()

        client.delegate = self
        
        client.getOrganizations([.canPublish])
        
        if let ad = ad {
            set(advertisement: ad)
            client.getAd(withId: ad.id)
            descriptionPlaceholderLabel.isHidden = true
        } else {
            descriptionPlaceholderLabel.isHidden = false
            nonEditingInfoContainer.isHidden = true
        }
        
        additionalInfoLabel.textColor = UIColor(red:0.467, green:0.467, blue:0.471, alpha:1.000)
        
        
        membersTableView.delegate = self
        membersTableView.dataSource = self
        membersTableView.register(UserTableViewCell.self, forCellReuseIdentifier: memberCellId)
        membersTableView.register(CurrentUserAdTableViewCell.self, forCellReuseIdentifier: memberCurrentUserCellId)
        
        membersTableView.rowHeight = membersTableViewRowHeight

        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: commentCellId)
        commentsTableView.register(CommentInputTableViewCell.self, forCellReuseIdentifier: commentInputCellId)
        
        commentsTableView.rowHeight = UITableView.automaticDimension
        commentsTableView.estimatedRowHeight = 45
        
        commentsTableView.tableFooterView = UIView()

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let horizontalSpace: CGFloat = 16
        
        contentView.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16).isActive = true
        nameTextField.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16).isActive = true
        nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: horizontalSpace / 2).isActive = true
        
        
        contentView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor, constant: -4).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        descriptionTextView.topAnchor.constraint(equalTo: nameTextField.lastBaselineAnchor, constant: horizontalSpace).isActive = true
        
        
        
        contentView.addSubview(descriptionPlaceholderLabel)
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor).isActive = true
        descriptionPlaceholderLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor, constant: 7).isActive = true
        
        
        contentView.addSubview(nonEditingInfoContainer)
        nonEditingInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        nonEditingInfoContainer.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor).isActive = true
        nonEditingInfoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        nonEditingInfoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        nonEditingInfoContainer.addSubview(additionalInfoLabel)
        additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalInfoLabel.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor).isActive = true
        additionalInfoLabel.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor).isActive = true
        additionalInfoLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 7).isActive = true
        
        
        nonEditingInfoContainer.addSubview(membersTableView)
        membersTableView.translatesAutoresizingMaskIntoConstraints = false
        membersTableView.topAnchor.constraint(equalTo: additionalInfoLabel.lastBaselineAnchor, constant: horizontalSpace * 2).isActive = true
        membersTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        membersTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        membersTableViewHeightConstraint = membersTableView.heightAnchor.constraint(equalToConstant: membersTableViewRowHeight)
        membersTableViewHeightConstraint.isActive = true
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red:0.793, green:0.788, blue:0.805, alpha:1.000)
        nonEditingInfoContainer.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: membersTableView.topAnchor).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        
        let commentsSectionHeader = UILabel()
        nonEditingInfoContainer.addSubview(commentsSectionHeader)
        commentsSectionHeader.translatesAutoresizingMaskIntoConstraints = false
        commentsSectionHeader.topAnchor.constraint(equalTo: membersTableView.bottomAnchor, constant: horizontalSpace).isActive = true
        commentsSectionHeader.leadingAnchor.constraint(equalTo: additionalInfoLabel.leadingAnchor, constant: 0).isActive = true

        
        commentsSectionHeader.font = .preferredFont(for: .title3, weight: .medium)
        commentsSectionHeader.text = Localizer.string(for: .adEditorComments)
        
        nonEditingInfoContainer.addSubview(commentsTableView)
        commentsTableView.translatesAutoresizingMaskIntoConstraints = false
        commentsTableView.topAnchor.constraint(equalTo: commentsSectionHeader.bottomAnchor, constant: horizontalSpace / 2).isActive = true
        commentsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        commentsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        commentsTableView.bottomAnchor.constraint(equalTo: nonEditingInfoContainer.bottomAnchor).isActive = true
        
        commentsTableViewHeightConstraint = commentsTableView.heightAnchor.constraint(equalToConstant: 0)
        commentsTableViewHeightConstraint.isActive = true
        
        
        
        
        contentView.addSubview(beginDateButton)
        beginDateButton.translatesAutoresizingMaskIntoConstraints = false
        beginDateButton.leadingAnchor.constraint(equalTo: additionalInfoLabel.leadingAnchor).isActive = true
        
        dateButtonTopConstraint = beginDateButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: beginDateButtonTopPadding)
        
        dateButtonBottomConstraint = beginDateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18)
        dateButtonBottomConstraint.isActive = true
        
        

        beginDateButton.isHidden = true
        beginDateButton.alpha = 0
        
        contentView.addSubview(endDateButton)
        endDateButton.translatesAutoresizingMaskIntoConstraints = false
        
        let endDateButtonLeadingConstraint = endDateButton.leadingAnchor.constraint(equalTo: beginDateButton.trailingAnchor, constant: 16)
        endDateButtonLeadingConstraint.priority = .defaultLow
        endDateButtonLeadingConstraint.isActive = true
        
        endDateButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16).isActive = true
        endDateButton.centerYAnchor.constraint(equalTo: beginDateButton.centerYAnchor).isActive = true
        
        endDateButton.isHidden = true
        endDateButton.alpha = 0
        
        
        beginDateButton.addTarget(self, action: #selector(beginDateButtonPressed(_:)), for: .touchUpInside)
        endDateButton.addTarget(self, action: #selector(endDateButtonPressed(_:)), for: .touchUpInside)

        
        
        
        
        
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
        descriptionTextView.isEditable = false
        
        moreButton.addTarget(self, action: #selector(moreButtonPressed(_:)), for: .touchUpInside)
        cancelEditingButton.addTarget(self, action: #selector(cancelEditingButtonPressed(_:)), for: .touchUpInside)
        publishButton.addTarget(self, action: #selector(publishButtonPressed(_:)), for: .touchUpInside)
        
        descriptionTextView.layoutManager.delegate = self
        descriptionTextView.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameTextField.delegate = self
        
        nameTextField.font = .preferredFont(for: .title2, weight: .bold)
        nameTextField.placeholder = Localizer.string(for: .adEditorNamePlaceholder)
        nameTextField.returnKeyType = .next
        nameTextField.autocapitalizationType = .sentences

        descriptionTextView.isScrollEnabled = false
        descriptionTextView.font = .preferredFont(forTextStyle: .body)
        descriptionTextView.returnKeyType = .default
        descriptionTextView.autocapitalizationType = .sentences
        
        additionalInfoLabel.font = .preferredFont(for: .body, weight: .light)
        additionalInfoLabel.textColor = .lightGray
        
        
        
        descriptionPlaceholderLabel.text = Localizer.string(for: .adEditorDescriptionPlaceholder)
        descriptionPlaceholderLabel.textColor = .lightGray
        descriptionPlaceholderLabel.font = .preferredFont(forTextStyle: .body)
        descriptionPlaceholderLabel.numberOfLines = 3
        
        
        
        membersTableView.isScrollEnabled = false
        membersTableView.separatorInset = .zero
        
        commentsTableView.isScrollEnabled = false
        commentsTableView.separatorInset = .zero
        commentsTableView.rowHeight = UITableView.automaticDimension
        commentsTableView.isHidden = true
        

    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if currentMode == .viewing {
            layoutCommentsTableView()
        }
        

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if currentMode == .editing {
            enableEditingMode()
        }
    }
    
    override func viewDidLayoutSubviews() {
        adjustContentLayout()
    }
    
    
    override func adjustContentLayout() {
        super.adjustContentLayout()
        guard dateButtonTopConstraint != nil else { return }
        
        if descriptionTextView.frame.maxY <= beginDateButton.frame.minY {
            dateButtonBottomConstraint.isActive = true
            dateButtonTopConstraint.isActive = false
        } else {
            dateButtonBottomConstraint.isActive = false
            dateButtonTopConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func layoutCommentsTableView() {
        let commentsHeight = commentsTableView.contentSize.height
        if commentsHeight != commentsTableViewHeightConstraint.constant {
            commentsTableViewHeightConstraint.constant = CGFloat(commentsTableView.contentSize.height)
            additionalInfoLabel.layoutIfNeeded()

            if commentsTableView.isHidden {
                commentsTableView.isHidden = false
                commentsTableView.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.commentsTableView.alpha = 1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.adjustContentLayout()
            })
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
        
        if let ad = advertisement, let description = ad.description, description != descriptionTextView.attributedText.string {
            descriptionTextView.attributedText = NSAttributedString(string: description, attributes: [.font: UIFont.preferredFont(for: .body, weight: .light)])
        }
        
        nameTextField.isUserInteractionEnabled = true
        descriptionTextView.isEditable = true
        
        beginDateButton.isHidden = false
        endDateButton.isHidden = false
        publishButton.isHidden = false
        cancelEditingButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.moreButton.alpha = 0
            self.publishButton.alpha = 1
            self.cancelEditingButton.alpha = 1
            self.beginDateButton.alpha = 1
            self.endDateButton.alpha = 1
            self.nonEditingInfoContainer.alpha = 0
        }) { _ in
            self.moreButton.isHidden = true
            self.nonEditingInfoContainer.isHidden = true
        }
        
        if publishButton.isHidden {
            checkIfCanPublish(isInitialRun: true) // if the user enters the editing mode initially, not allow publishing till the data's been changed
        } else {
            checkIfCanPublish() // if the user returns from the subcontroller, check the data fully
        }
    }
    
    func disableEditingMode(completion: (() -> ())? ) {
        currentMode = .viewing
        isFullscreen = false
        title = nil
        
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isEditable = false
        
        if advertisement != nil {
            nonEditingInfoContainer.isHidden = false
        }
        
        self.moreButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.moreButton.alpha = 1
            self.publishButton.alpha = 0
            self.cancelEditingButton.alpha = 0
            self.beginDateButton.alpha = 0
            self.endDateButton.alpha = 0
            self.nonEditingInfoContainer.alpha = 1
        }) { _ in
            self.publishButton.isHidden = true
            self.cancelEditingButton.isHidden = true
            self.beginDateButton.isHidden = true
            self.endDateButton.isHidden = true

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
        let cancelAction = UIAlertAction(title: Localizer.string(for: .adEditorReturnToEditor), style: .default, handler: nil)
        
        shouldProceedAlert.addAction(cancelAction)
        shouldProceedAlert.addAction(deleteAction)
        shouldProceedAlert.preferredAction = cancelAction
        
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
            
            if beginDateButton.date == nil || endDateButton.date == nil {
                shouldAllowPublishing = false
            }
        }
        
        if shouldAllowPublishing {
            publishButton.isEnabled = true
            publishButton.tintColor = .globalTintColor
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
        
        let beginTime = beginDateButton.date!
        let endTime = endDateButton.date!
        

        if let oldAd = advertisement {
            
            // short description shouldn't support markdown
            let parser = MarkdownParser()
            let parsedArrtibutedString = parser.parse(shortDescription)
            let shortDescriptionNoFormatting = parsedArrtibutedString.string
            
            
            let adToUpdate = Ad(id: oldAd.id, name: title, description: description, shortDescription: shortDescriptionNoFormatting, beginTime: beginTime, endTime: endTime)
            
            client.replaceAd(with: adToUpdate)
            RootViewController.startLoadingIndicator()
            
        } else {
            func createAd() {
                var newAd: Ad!
                if let organizationId = publisherOrganizationId {
                    newAd = Ad(organizationId: organizationId, name: title, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime)
                } else {
                    newAd = Ad(id: nil, name: title, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime)
                }
                client.create(ad: newAd)
                RootViewController.startLoadingIndicator()
            }
            
            if let organizations = publishableOrganizations, !organizations.isEmpty {


                let alert = UIAlertController(title: Localizer.string(for: .adEditorPublishAdAlertMessage), message: nil, preferredStyle: .actionSheet)
                
                let currentUser = PersistentStore.shared.user!
                let meAction = UIAlertAction(title: "\(currentUser.firstName) \(currentUser.lastName)" , style: .default) { _ in
                    createAd()
                }
                alert.addAction(meAction)
                alert.preferredAction = meAction
                
                
                    for organization in organizations {
                        let action = UIAlertAction(title: "\(organization.name)" , style: .default) { _ in
                            self.publisherOrganizationId = organization.id
                            createAd()
                        }
                        alert.addAction(action)
                    }
                
                
                let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                
                present(alert, animated: true, completion: nil)
                
            } else {
                createAd()
            }
            
            
        }
        
        
    }
    
    
    fileprivate func checkIfCanPublishComment() {
        if let text = commentTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if publishCommentButton.isHidden {
                publishCommentButton.isHidden = false
                publishCommentButton.alpha = 0
                UIView.animate(withDuration: 0.3) {
                    self.publishCommentButton.alpha = 1
                }
            }
        } else {
            if !publishCommentButton.isHidden {
                publishCommentButton.alpha = 1
                UIView.animate(withDuration: 0.3, animations: {
                    self.publishCommentButton.alpha = 0
                }) { _ in
                    self.publishCommentButton.isHidden = true
                }
            }
        }
    }
    
    
    
    
}






extension AdViewController {
    
    @objc func publishCommentButtonTapped(_ button: UIButton) {
        let commentText = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = Comment(text: commentText)
        
        RootViewController.startLoadingIndicator()
        commentTextView.isEditable = false
        client.add(comment: comment, forAdWithId: advertisement!.id)
    }
    
    @objc func beginDateButtonPressed(_ button: UIButton) {
        let datePickerVC = DatePickerController(title: Localizer.string(for: .adEditorBeginDateLabel))
        datePickerVC.datePicker.minimumDate = Date()
        datePickerVC.doneCompletionHandler = { [weak self] in
            let beginDate = datePickerVC.datePicker.date
            self?.beginDateButton.date = beginDate
            if let endDate = self?.endDateButton.date, endDate.compare(beginDate) == .orderedAscending {
                self?.endDateButton.date = nil
            }
        }
        present(datePickerVC, animated: true, completion: nil)
    }
    
    @objc func endDateButtonPressed(_ button: UIButton) {
        let datePickerVC = DatePickerController(title: Localizer.string(for: .adEditorEndDateLabel))
        
        if beginDateButton.date == nil {
            datePickerVC.datePicker.minimumDate = Date()
        } else {
            datePickerVC.datePicker.minimumDate = beginDateButton.date
        }
        
        datePickerVC.doneCompletionHandler = { [weak self] in
            let endDate = datePickerVC.datePicker.date
            self?.endDateButton.date = endDate
            if let beginDate = self?.beginDateButton.date, beginDate.compare(endDate) == .orderedDescending {
                self?.beginDateButton.date = nil
            }
        }
        present(datePickerVC, animated: true, completion: nil)
    }
    
    
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
    
    fileprivate func loadAdParticipantsAndComments(from ad: Ad) {
        
        // Todo: - this code is not elegant at all. Change it later to eliminate repeating parts
        
        if let user = ad.user {
            let creator = AdParticipant(type: .user, content: user)
            if user.id! != PersistentStore.shared.user.id! {
                let joinAdCell = AdParticipant(type: .other, content: nil)
                members = [creator, joinAdCell]
            } else {
                members = [creator]
            }
            membersTableView.reloadSections(IndexSet(integer: 0), with: .fade)
            membersTableViewHeightConstraint.constant = CGFloat(members.count) * membersTableViewRowHeight
        } else if let organization = ad.organization {
            let creator = AdParticipant(type: .organization, content: organization)
            let joinAdCell = AdParticipant(type: .other, content: nil)
            members = [creator, joinAdCell]
            membersTableView.reloadSections(IndexSet(integer: 0), with: .fade)
            membersTableViewHeightConstraint.constant = CGFloat(members.count) * membersTableViewRowHeight
        }
        
        if let newComments = ad.comments, !comments.isEmpty {
            newCommentsCount = newComments.count - comments.count
        }
        
        comments = ad.comments ?? []
        commentsTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.layoutCommentsTableView()
            if self.scrollToBottomNeeded {
                self.scrollToBottomNeeded = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToBottom()
                }
            }
        }
    }
    
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {
        
        loadAdParticipantsAndComments(from: ad)
        
        if let userId = ad.userId, userId == PersistentStore.shared.user!.id {
            isViewerOwner = true
        } else if let organizationId = ad.organizationId {
            func checkIfUserCanPublishInCurrentOrganization() {
                if let organizations = publishableOrganizations {
                    for organization in organizations {
                        if organizationId == organization.id {
                            isViewerOwner = true
                            break
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: checkIfUserCanPublishInCurrentOrganization)
                }
            }
            checkIfUserCanPublishInCurrentOrganization()
        }
        
        set(advertisement: ad)
    }
    
    func apiClient(_ client: APIClient, didCreateAd newAd: Ad) {
        
        loadAdParticipantsAndComments(from: newAd)
        set(advertisement: newAd)
        
        delegate?.adViewController(self, didCreateAd: newAd)
        
        RootViewController.stopLoadingIndicator(with: .success) {
            self.disableEditingMode(completion: nil)
        }
    }
    
    func apiClient(_ client: APIClient, didUpdateAd updatedAd: Ad) {
        delegate?.adViewController(self, didUpdateAd: updatedAd)
        RootViewController.stopLoadingIndicator(with: .success)
        
        self.set(advertisement: updatedAd)
        self.disableEditingMode(completion: nil)
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
    
    func apiClient(_ client: APIClient, didRecieveOrganizations organizations: [Organization], withOptions options: [APIClient.OrganizationRequestOption]?) {
        publishableOrganizations = organizations
    }
    
    func apiClient(_ client: APIClient, didCreateCommentForAdWithId adId: String) {
        commentTextView.isEditable = true
        commentTextView.text = ""
        RootViewController.stopLoadingIndicator(with: .success)
        scrollToBottomNeeded = true
        client.getAd(withId: adId)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.adjustContentLayout()
            })
            
            checkIfCanPublish()

        } else if textView === commentTextView {
            
            checkIfCanPublishComment()
            
            if !commentTextView.text.isEmpty {
                commentPlaceholderLabel.isHidden = true
            } else {
                commentPlaceholderLabel.isHidden = false
            }
            
            let actualHeight = commentTextView.frame.size.height
            let calculatedHeight = commentTextView.sizeThatFits(commentTextView.frame.size).height
            
            if actualHeight != calculatedHeight {
                
                
                UIView.setAnimationsEnabled(false)
                
                commentsTableView.beginUpdates()
                commentsTableView.endUpdates()
                
                commentsTableViewHeightConstraint.constant = commentsTableView.contentSize.height
                
                UIView.setAnimationsEnabled(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.adjustContentLayout()

                    if self.containerView.contentSize.height > self.containerView.bounds.height - self.visibleKeyboardHeight {
                        let difference = calculatedHeight - actualHeight
                        let currentOffset = self.containerView.contentOffset
                        self.containerView.contentOffset = CGPoint(x: currentOffset.x, y: currentOffset.y + difference)
                    }
                }

            }
            
        }
        
    }
    
    fileprivate func scrollToBottom(_ additionalOffset: CGFloat = 0) {
        let visibleSize = containerView.bounds.height - visibleKeyboardHeight
        let contentHeight = self.contentHeight
        if contentHeight > visibleSize {
            let bottomOffset = CGPoint(x: 0, y: contentHeight - visibleSize + additionalOffset)
            containerView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    override func didShowKeyboard() {
        if currentMode == .commenting {
            scrollToBottom()
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView === commentTextView {
            currentMode = .commenting
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === commentTextView {
            shouldResetOffsetOnFullscreenEnter = false
            isFullscreen = true
            shouldResetOffsetOnFullscreenEnter = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === commentTextView {
            isFullscreen = false
            currentMode = .viewing
            adjustContentLayout()
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView === descriptionTextView && currentMode == .editing {
            
//            if let selectedRange = descriptionTextView.selectedTextRange, !selectedRange.isEmpty {
//                let boldItem = UIMenuItem(title: "Bold", action: #selector(toggleBoldTextInDescriptionTextView))
//                UIMenuController.shared.menuItems = [boldItem]
//
//                return
//            }
            
        }
        
        UIMenuController.shared.menuItems = []

    }
    
    @objc func toggleBoldTextInDescriptionTextView() {
        if var description = descriptionTextView.text, let selectedRange = descriptionTextView.selectedRangeAsNSRange {
            
            
            let selectedString = description.substring(with: Range(selectedRange, in: description)!)
            
            let resultingDescription = description.replacingCharacters(in: Range(selectedRange, in: description)!, with: "**\(selectedString)**")

            descriptionTextView.attributedText = NSAttributedString(string: resultingDescription, attributes: [.font: UIFont.preferredFont(for: .body, weight: .light)])
        }
    }
}





extension AdViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === membersTableView {
            return members.count
        } else if tableView === commentsTableView {
            return comments.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === membersTableView {
            
            
            let participant = members[indexPath.row]
            
            if participant.type == .user || participant.type == .organization {
                let cell = membersTableView.dequeueReusableCell(withIdentifier: memberCellId, for: indexPath) as! UserTableViewCell
                
                var name: String?
                var surname: String?
                var detailInfo: String?
                
                if let user = participant.content as? User {
                    
                    if user.id! == advertisement?.userId {
                        detailInfo = Localizer.string(for: .adEditorCreator)
                    }
                    name = user.firstName
                    surname = user.lastName
                    
                } else if let organization = participant.content as? Organization {
                    
                    detailInfo = Localizer.string(for: .adEditorCreator)
                    name = organization.name
                    
                }
                
                
                cell.initialsLabel.text = String(name!.prefix(1)) + (surname?.prefix(1) ?? "")
                cell.nameLabel.text = (name ?? "") + " " + (surname ?? "")
                cell.nameLabel.font = .preferredFont(for: .body, weight: .medium)
                cell.detailTextLabel?.text = detailInfo
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            let cell = membersTableView.dequeueReusableCell(withIdentifier: memberCurrentUserCellId, for: indexPath) as! CurrentUserAdTableViewCell
            
            let currentUser = PersistentStore.shared.user!
            cell.initialsLabel.text = String(currentUser.firstName.prefix(1)) + currentUser.lastName.prefix(1)
            
            cell.nameLabel.textColor = .globalTintColor
            cell.nameLabel.text = Localizer.string(for: .adEditorJoinAd) + "..."
            
            return cell
            
            
            
        } else if tableView === commentsTableView {
//            self.commentsTableViewHeightConstraint.constant = self.commentsTableView.contentSize.height

            if indexPath.row == comments.count {
                let inputCell = commentsTableView.dequeueReusableCell(withIdentifier: commentInputCellId, for: indexPath) as! CommentInputTableViewCell
                
                inputCell.minimumHeightConstant.isActive = false
                
                inputCell.placeholderLabel.text = Localizer.string(for: .adEditorCommentPlaceholder)
                inputCell.placeholderLabel.isHidden = false
                
                commentTextView = inputCell.textViewInput
                commentTextView.delegate = self
                
                commentPlaceholderLabel = inputCell.placeholderLabel
                
                inputCell.selectionStyle = .none
                
                let inputPadding: CGFloat = 8
                inputCell.topConstraint.constant = inputPadding
                inputCell.bottomConstraint.constant = -inputPadding
                
                publishCommentButton = inputCell.publishButton
                publishCommentButton.addTarget(self, action: #selector(publishCommentButtonTapped(_ :)), for: .touchUpInside)

                return inputCell
            }
            
            let cell = commentsTableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentTableViewCell
            
            let comment = comments[indexPath.row]
            
            cell.bodyTextView.text = comment.text
            
            let formatter = DateFormatter()
            formatter.locale = Localizer.currentLocale
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            cell.dateLabel.text = formatter.string(from: comment.commentTime)
            
            cell.nameLabel.text = comment.author
            
            let nameParts = comment.author.components(separatedBy: " ")
            if nameParts.count == 1 {
                cell.initialsLabel.text = String(nameParts.first!.suffix(1))
            } else if nameParts.count == 2 {
                // TODO: - Change the order later
                let name = nameParts.last!
                let surname = nameParts.first!
                cell.initialsLabel.text = String(name.prefix(1)) + surname.prefix(1)
                
                cell.nameLabel.text = "\(name) \(surname)"
            }
            
            cell.isAvatarHighlighted = (comment.authorId == PersistentStore.shared.user.id)
            
            cell.selectionStyle = .none
            
            if indexPath.row >= comments.count - newCommentsCount {
                newCommentsCount -= 1
                let initialCellBackgroundColor = cell.backgroundColor
                cell.backgroundColor = UIColor.globalTintColor.withAlphaComponent(0.2)
                UIView.animate(withDuration: 1.5) {
                    cell.backgroundColor = initialCellBackgroundColor
                }
            }
            
            cell.layoutIfNeeded()

            return cell
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: nil)
        
    }
}
