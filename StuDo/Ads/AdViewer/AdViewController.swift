//
//  AdViewController2.swift
//  StuDo
//
//  Created by Andrew on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

private let bodyCellId = "bodyCellId"
private let editableBodyCellId = "editableBodyCellId"
private let commentCellId = "commentCellId"
private let commentInputCellId = "commentInputCellId"
private let adParticipantCellId = "adParticipantCellId"
private let currentUserCellId = "currentUserCellId"


class AdViewController: UIViewController {
    
    // MARK: Visible elements
    
    private let tableView: UITableView
    
    private var headerView: AdControllerHeaderView!
    private var commentInputTextView: UITextView!
    private var commentPlaceholderLabel: UILabel!
    private var commentPublishButton: UIButton!
    
    private var titleEditableTextField: UITextField!
    private var bodyEditableTextView: UITextView!
    private var titlePlaceholderLabel: UILabel!
    private var bodyPlaceholderLabel: UILabel!
    
    private var beginDateButton: DateButton!
    private var endDateButton: DateButton!
    private var preferencesView: AdPreferencesView!
    private var beginDatePicker: UIDatePicker!
    private var endDatePicker: UIDatePicker!
    
    // MARK: - State
    // This properties allow the controller to switch between two states
    // One allows to view the ad, the other allows to edit or publish
    
    private var currentAd: Ad!
    private var currentAdComments: [Comment] = []
    private var currentAdPeople: [AdParticipant] = []
    
    private var adNameUnderEditing: String = ""
    private var adBodyUnderEditing: String = ""
    
    private var publishableOrganizations: [Organization]!
    
    private var canEditAd: Bool {
        if let currentGroupId = currentAd.organizationId {
            for org in publishableOrganizations {
                if org.id == currentGroupId {
                    return true
                }
            }
            return false
        }
        return currentAd.userId == PersistentStore.shared.user.id
    }
    
    private var needToUpdateComments = false
    private var newCommentsIndices: [String: Int] = [:]
    
    private let client = APIClient()
    
    enum AdViewControllerSection {
        case body
        case editableBody
        case people
        case comments
        case commentInput
    }
    
    private let viewStateSections: [AdViewControllerSection] = [
        .body, .people, .comments, .commentInput
    ]
    
    private let editStateSections: [AdViewControllerSection] = [
        .editableBody
    ]
    
    var currentSections: [AdViewControllerSection] {
        switch currentState {
        case .editing, .publishing:
            return editStateSections
        case .viewing, .previewing, .commenting:
            return viewStateSections
        }
    }
    
    private func getSectionIndex(for section: AdViewControllerSection) -> IndexSet? {
        for (i, sec) in currentSections.enumerated() {
            if sec == section {
                return IndexSet(integer: i)
            }
        }
        return nil
    }
    
    enum AdViewControllerState {
        case previewing
        case viewing
        case commenting
        case editing
        case publishing
    }
    
    var currentState: AdViewControllerState
    
    var clientUserInfo: [String: Any]? = nil
    
    // MARK: - ViewController Lifecycle
    
    init(ad: Ad?) {
        if ad == nil {
            currentState = .publishing
            client.getOrganizations([.canPublish])
        } else {
            currentAd = ad
            currentState = .previewing
            client.getAd(withId: currentAd.id) // get full data of the ad
            if currentAd.organizationId != nil {
                client.getOrganizations([.canPublish])
            }
        }
        
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        client.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateTableViewHeight() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    // MARK: - Initial Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Order is important
        setHeaderView()
        setTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        headerView.moreButton.addTarget(self, action: #selector(moreButtonTapped(_:)), for: .touchUpInside)
        headerView.cancelEditingButton.addTarget(self, action: #selector(cancelEditingButtonTapped(_:)), for: .touchUpInside)
        headerView.publishButton.addTarget(self, action: #selector(publishButtonTapped(_:)), for: .touchUpInside)
        
        if currentState == .publishing || currentState == .editing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.enableEditingState()
            }
        }
        
        headerView.moreButton.animateVisibility(shouldHide: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let pc = presentationController
        presentationController?.delegate = self
    }
        
    private func setTableView() {
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: AdBodyCell.self), bundle: nil), forCellReuseIdentifier: bodyCellId)
        tableView.register(UINib(nibName: String(describing: EditableAdBodyCell.self), bundle: nil), forCellReuseIdentifier: editableBodyCellId)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: commentCellId)
        tableView.register(CommentInputTableViewCell.self, forCellReuseIdentifier: commentInputCellId)
        tableView.register(CurrentUserAdTableViewCell.self, forCellReuseIdentifier: currentUserCellId)
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: adParticipantCellId)
        
        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.keyboardDismissMode = .interactive
        
    }
    
    private func setHeaderView() {
        headerView = AdControllerHeaderView(frame: .zero)
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        headerView.layer.shadowColor = UIColor(red:0.447, green:0.447, blue:0.443, alpha:0.4).cgColor
        headerView.layer.shadowRadius = 5

    }
    
    // MARK: Layout
    
    fileprivate func scrollToBottom(_ additionalOffset: CGFloat = 0) {
        let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height + tableView.contentInset.bottom)
        tableView.setContentOffset(bottomOffset, animated: true)
    }
        
    // MARK: - Model-related methods
            
    private func set(ad: Ad) {
        currentAd = ad
        
        tableView.beginUpdates()
        if currentState == .previewing {
            currentState = .viewing
            if let bodySectionIndex = getSectionIndex(for: .body) {
                tableView.reloadSections(bodySectionIndex, with: .fade)
            }
        }
        tableView.endUpdates()
    }
    
    private func deleteCurrentAd() {
        func deleteAd() {
            client.deleteAd(withId: currentAd.id, userInfo: clientUserInfo)
            RootViewController.startLoadingIndicator()
        }
        
        let shouldProceedAlert = UIAlertController(title: Localizer.string(for: .adEditorDeleteAlertMessage), message: nil, preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: Localizer.string(for: .delete), style: .destructive, handler: { _ in deleteAd() } )
        let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)
        
        shouldProceedAlert.addAction(deleteAction)
        shouldProceedAlert.addAction(cancelAction)
        
        present(shouldProceedAlert, animated: true, completion: nil)
    }
    
    private func toggleBookmark() {
        client.bookmarkAd(withId: currentAd!.id)
        RootViewController.startLoadingIndicator()
    }
    
    fileprivate func updateAdsVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            if let adsVC = RootViewController.main.mainController.feedViewController.visibleViewController as? AdsViewController {
                adsVC.requestUpdateForAllSections()
            }
        })
    }
    
    // MARK: Editing & Publishing
    
    private func checkIfCanPublishAd() -> Bool {
        beginDateButton.date != nil && endDateButton.date != nil && adNameUnderEditing.count > 0 && adBodyUnderEditing.count > 0
    }
    
    private func updatePublishButton() {
        headerView.togglePublishButton(isEnabled: checkIfCanPublishAd())
    }
    
    private func publishCurrentAd() {
        func enableDisableEditingsInputs(enable: Bool) {
            titleEditableTextField.isEnabled = enable
            bodyEditableTextView.isEditable = enable
            beginDateButton.isEnabled = enable
            endDateButton.isEnabled = enable
        }
        
        func publish() {
            let adTitle = adNameUnderEditing
            let description = adBodyUnderEditing
            var shortDescription: String!
            
            if let firstParagraph = adBodyUnderEditing.components(separatedBy: CharacterSet.newlines).first {
                shortDescription = firstParagraph
            } else {
                shortDescription = description
            }
            
            let beginTime = beginDateButton.date!
            let endTime = endDateButton.date!
            
            if currentAd != nil {
                
                let adToUpdate = Ad(id: currentAd.id, name: adTitle, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime)
                
                client.replaceAd(with: adToUpdate)
                RootViewController.startLoadingIndicator()
                
            } else {
                func createAd(id: String, asUser: Bool) {
                    var newAd: Ad!
                    if !asUser {
                        newAd = Ad(organizationId: id, name: adTitle, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime)
                    } else {
                        newAd = Ad(id: nil, name: adTitle, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime)
                    }
                    client.create(ad: newAd)
                    RootViewController.startLoadingIndicator()
                }
                
                let currentUser = PersistentStore.shared.user!
                
                #if ORGANIZATIONS_ENABLED
                if !publishableOrganizations.isEmpty {

                    let alert = UIAlertController(title: Localizer.string(for: .adEditorPublishAdAlertMessage), message: nil, preferredStyle: .actionSheet)
                    
                    let meAction = UIAlertAction(title: "\(currentUser.firstName) \(currentUser.lastName)" , style: .default) { _ in
                        createAd(id: currentUser.id!, asUser: true)
                    }
                    
                    alert.addAction(meAction)
                    alert.preferredAction = meAction
                    
                    for organization in publishableOrganizations {
                        let action = UIAlertAction(title: "\(organization.name)" , style: .default) { _ in
                            createAd(id: organization.id, asUser: false)
                        }
                        alert.addAction(action)
                    }
                    
                    
                    let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    
                    present(alert, animated: true, completion: nil)
                    
                } else {
                    createAd(id: currentUser.id!, asUser: true)
                }
                #else
                createAd(id: currentUser.id!, asUser: true)
                #endif
            }
        }
        
        enableDisableEditingsInputs(enable: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            publish()
            enableDisableEditingsInputs(enable: true)
        }
        
    }
    
    // MARK: Date
    
    func setupDatePicker(_ datePicker: UIDatePicker, for textField: UITextField, title: String, onDone: Selector) {
        textField.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.tintColor = .globalTintColor
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: Localizer.string(for: .cancel), style: .plain, target: self, action: #selector(cancelDatePickerInput(_:)))
        let doneButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: onDone)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let titleLabel = UILabel()
        titleLabel.text = title
        let titleItem = UIBarButtonItem(customView: titleLabel)
        toolbar.setItems([cancelButton, space, titleItem, space, doneButton], animated: true)
        textField.inputAccessoryView = toolbar
    }
    
    private func setupPreferencesView() {
        preferencesView = AdPreferencesView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        beginDateButton = preferencesView.beginDateButton
        endDateButton = preferencesView.endDateButton
        if let ad = currentAd {
            beginDateButton.date = ad.beginTime
            endDateButton.date = ad.endTime
        }
        beginDateButton.addTarget(self, action: #selector(beginDateButtonTapped(_:)), for: .touchUpInside)
        endDateButton.addTarget(self, action: #selector(endDateButtonTapped(_:)), for: .touchUpInside)
        
        beginDatePicker = UIDatePicker()
        setupDatePicker(beginDatePicker, for: preferencesView.beginTextField, title: Localizer.string(for: .adEditorBeginDateLabel), onDone: #selector(beginDateChanged(_:)))
        endDatePicker = UIDatePicker()
        setupDatePicker(endDatePicker, for: preferencesView.endTextField, title: Localizer.string(for: .adEditorEndDateLabel), onDone: #selector(endDateChanged(_:)))
    }
    

    
    // MARK: Comments
    
    private func checkCanPublishComment(_ comment: String) -> Bool {
        return comment.count > 0
    }
    
    private func commentInputUpdated(with comment: String) {
        
        commentPublishButton.animateVisibility(shouldHide: !checkCanPublishComment(comment))
        
        if !commentInputTextView.text.isEmpty {
            commentPlaceholderLabel.isHidden = true
        } else {
            commentPlaceholderLabel.isHidden = false
        }
    }
    
    private func updateComments(with newComments: [Comment], partialUpdate: Bool = false) {
        guard partialUpdate else {
            currentAdComments = newComments
            if let commentsSectionIndex = getSectionIndex(for: .comments) {
                tableView.reloadSections(commentsSectionIndex, with: .fade)
            }
            return
        }
        var previousCommentIds = Set<String>()
        for comment in currentAdComments {
            previousCommentIds.insert(comment.id)
        }
        for (i, comment) in newComments.enumerated() {
            if !previousCommentIds.contains(comment.id) {
                newCommentsIndices[comment.id] = i
            }
        }
        
        currentAdComments = newComments
        
        if let commentsSectionIndex = getSectionIndex(for: .comments) {
            tableView.beginUpdates()
            for (_, index) in newCommentsIndices {
                let indexPath = IndexPath(item: index, section: Int(commentsSectionIndex.first!))
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            tableView.endUpdates()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
        
    }
    
    private func presentCommentActions(id: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        guard let comment = currentAdComments.filter({ $0.id == id }).first else { return }
        if comment.authorId == PersistentStore.shared.user.id {
            alert.addAction(UIAlertAction(title: Localizer.string(for: .adEditorDeleteComment), style: .destructive, handler: { _ in
                self.client.deleteComment(withId: id, adId: self.currentAd.id)
            }))
        } else {
            let nameParts = comment.nameParts ?? []
            let initials = nameParts.map({ String($0.prefix(1)) }).reduce("", { $0 + $1 })
            let commentCreatorName = nameParts.reduce("", { "\($0)\($1) " })
            alert.addAction(UIAlertAction(title: commentCreatorName, style: .default, handler: { _ in
                self.client.getUser(id: comment.authorId)
            }))
        }
        alert.addAction(UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: Ad Participants
    
    private func updateParticipants(with ad: Ad) {
        var creator: AdParticipant!
        if let user = ad.user {
            creator = AdParticipant(type: .user, content: user)
        } else if let organization = ad.organization {
            creator = AdParticipant(type: .organization, content: organization)
        }
        currentAdPeople = [creator]
        
        if let peopleIndex = getSectionIndex(for: .people) {
            tableView.reloadSections(peopleIndex, with: .fade)
        }
    }
    
    private func presentParticipantsActions(indexPath: IndexPath) {
        let participant = currentAdPeople[indexPath.row]
        switch participant.type {
        case .user, .organization:
            break
        default:
            return
        }
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let user = participant.content as? User {
            if user.id == PersistentStore.shared.user.id { return }
            alert.addAction(UIAlertAction(title: "\(user.firstName) \(user.lastName)", style: .default, handler: { _ in
                self.client.getUser(id: user.id!)
            }))
        } else if let organization = participant.content as? Organization {
            alert.addAction(UIAlertAction(title: organization.name, style: .default, handler: { _ in
                self.client.getOrganization(withId: organization.id)
            }))
        }
        
        let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Actions & Observers
    
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.cgRectValue.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc func moreButtonTapped(_ button: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if currentAd.isFavorite {
            actionSheet.addAction(UIAlertAction(title: Localizer.string(for: .adEditorRemoveFromBookmarks), style: .default, handler: { _ in
                self.client.unbookmarkAd(withId: self.currentAd.id!)
                RootViewController.startLoadingIndicator()
            }))
        } else {
            actionSheet.addAction(UIAlertAction(title: Localizer.string(for: .adEditorAddToBookmarks), style: .default, handler: { _ in
                self.client.bookmarkAd(withId: self.currentAd.id!)
                RootViewController.startLoadingIndicator()
            }))
        }
        
        if canEditAd {
            let editAction = UIAlertAction(title: Localizer.string(for: .adEditorEditAd), style: .default, handler: { _ in self.enableEditingState() } )
            let deleteAction = UIAlertAction(title: Localizer.string(for: .adEditorDeleteAd), style: .destructive, handler: { _ in self.deleteCurrentAd() } )

            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
        }
        
        let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func cancelEditingButtonTapped(_ button: UIButton) {
        exitEditingState()
    }
    
    @objc func publishButtonTapped(_ button: UIButton) {
        publishCurrentAd()
    }
    
    @objc func beginDateChanged(_ button: UIBarButtonItem) {
        tableView.keyboardDismissMode = .interactive
        bodyEditableTextView.becomeFirstResponder()
        let beginDate = beginDatePicker.date
        beginDateButton.date = beginDate
        if let endDate = endDateButton.date, beginDate > endDate {
            endDateButton.date = nil
        }
        updatePublishButton()
    }
    
    @objc func endDateChanged(_ button: UIBarButtonItem) {
        tableView.keyboardDismissMode = .interactive
        bodyEditableTextView.becomeFirstResponder()
        let endDate = endDatePicker.date
        endDateButton.date = endDate
        if let beginDate = beginDateButton.date, endDate < beginDate {
            beginDateButton.date = nil
        }
        updatePublishButton()
    }
    
    @objc func cancelDatePickerInput(_ button: UIBarButtonItem) {
        bodyEditableTextView.becomeFirstResponder()
        tableView.keyboardDismissMode = .interactive
    }
    
    @objc func beginDateButtonTapped(_ button: UIButton) {
        preferencesView.beginTextField.becomeFirstResponder()
        tableView.keyboardDismissMode = .none
        if let beginDate = beginDateButton.date {
            beginDatePicker.date = beginDate
        } else {
            endDatePicker.date = Date()
        }
        endDatePicker.minimumDate = Date()
    }
    
    @objc func endDateButtonTapped(_ button: UIButton) {
        preferencesView.endTextField.becomeFirstResponder()
        tableView.keyboardDismissMode = .none
        if let endDate = endDateButton.date {
            endDatePicker.date = endDate
        } else if let beginDate = beginDateButton.date {
            endDatePicker.date = beginDate
        } else {
            endDatePicker.date = Date()
        }
        endDatePicker.minimumDate = Date()
    }
    
    @objc func publishCommentButtonTapped(_ button: UIButton) {
        commentInputTextView.isEditable = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let commentText = self.commentInputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let comment = Comment(text: commentText)
            
            RootViewController.startLoadingIndicator()
            self.client.add(comment: comment, forAdWithId: self.currentAd.id)
        }
        
    }
    
    // MARK: State switching
    
    private func reloadTableView() {
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
    }
    
    private func enableEditingState() {
        if currentAd == nil {
            currentState = .publishing
            headerView.titleText = Localizer.string(for: .adEditorCreationModeTitle)
        } else {
            currentState = .editing
            headerView.titleText = Localizer.string(for: .adEditorEditingModeTitle)
            adNameUnderEditing = currentAd.name
            adBodyUnderEditing = currentAd.fullDescription
        }
        
        headerView.showEditingControls = true
        headerView.togglePublishButton(isEnabled: false)

        reloadTableView()
    }
    
    private func exitEditingState(shouldShowPrompt: Bool = true) {
        func exitEditing() {
            currentState = .viewing
            self.headerView.showEditingControls = false
            if currentAd != nil {
                self.reloadTableView()
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
        
        guard shouldShowPrompt else {
            exitEditing()
            return
        }
        
        if currentAd == nil && adNameUnderEditing.isEmpty && adBodyUnderEditing.isEmpty {
            dismiss(animated: true, completion: nil)
            return
        }
                
        var alertMessage = Localizer.string(for: .adEditorCancelEditingAlertMessage)
        var exitEditingActionMessage = Localizer.string(for: .adEditorDiscardChanges)
        
        if currentAd == nil {
            alertMessage = Localizer.string(for: .adEditorCancelCreatingAlertMessage)
            exitEditingActionMessage = Localizer.string(for: .adEditorCancelAdCreation)
        }
        
        
        let shouldProceedAlert = UIAlertController(title: alertMessage, message: nil, preferredStyle: .alert)
        
        let exitEditingAction = UIAlertAction(title: exitEditingActionMessage, style: .destructive, handler: { _ in
            exitEditing()
        } )
        
        let cancelAction = UIAlertAction(title: Localizer.string(for: .adEditorReturnToEditor), style: .default, handler: nil)
        
        shouldProceedAlert.addAction(cancelAction)
        shouldProceedAlert.addAction(exitEditingAction)
        shouldProceedAlert.preferredAction = cancelAction
        
        present(shouldProceedAlert, animated: true, completion: nil)

    }
    
    // MARK: - Cell setup
    
    private func setupCommentCell(for indexPath: IndexPath) -> CommentTableViewCell {
        let comment = currentAdComments[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentTableViewCell
        cell.bodyTextView.attributedText = TextFormatter.parseMarkdownString(comment.text, fontWeight: .light)
        cell.dateLabel.text = comment.dateString
        
        let nameParts = comment.nameParts ?? []
        let initials = nameParts.map({ String($0.prefix(1)) }).reduce("", { $0 + $1 })
        cell.initialsLabel.text = initials
        cell.nameLabel.text = nameParts.reduce("", { "\($0!)\($1) " })
        
        cell.isAvatarHighlighted = (comment.authorId == PersistentStore.shared.user.id)
        cell.selectionStyle = .none
        cell.bodyTextView.isUserInteractionEnabled = false
        
        if newCommentsIndices[comment.id] != nil {
            newCommentsIndices.removeValue(forKey: comment.id)
            animateBackgroundChange(for: cell)
        }
        
        if indexPath.row == currentAdComments.count - 1 {
            cell.separator.isHidden = true
        } else {
            cell.separator.isHidden = false
        }
        
        return cell
    }
    
    private func setupCommentInputCell(for indexPath: IndexPath) -> CommentInputTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commentInputCellId, for: indexPath) as! CommentInputTableViewCell
        
        commentPlaceholderLabel = cell.placeholderLabel
        cell.placeholderLabel.text = Localizer.string(for: .adEditorCommentPlaceholder)
        cell.placeholderLabel.isHidden = false
        
        commentInputTextView = cell.textViewInput
        commentInputTextView.delegate = self
                    
        cell.selectionStyle = .none
        
        commentPublishButton = cell.publishButton
        commentPublishButton.addTarget(self, action: #selector(publishCommentButtonTapped(_ :)), for: .touchUpInside)
        return cell
    }
    
    private func setupBodyCell(for indexPath: IndexPath) -> AdBodyCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: bodyCellId, for: indexPath) as! AdBodyCell
        cell.titleLabel.text = currentAd.name
        cell.dateLabel.text = currentAd.dateRange
        cell.selectionStyle = .none
        
        let attrDescription = NSMutableAttributedString(string: currentAd.fullDescription)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        attrDescription.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attrDescription.length))
        
        cell.bodyTextView.attributedText = TextFormatter.parseMarkdownString(attrDescription)
        return cell
    }
    
    private func setupEditableBodyCell(for indexPath: IndexPath) -> EditableAdBodyCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: editableBodyCellId, for: indexPath) as! EditableAdBodyCell
        cell.titleTextField.text = adNameUnderEditing
        cell.bodyTextView.text = adBodyUnderEditing
        cell.titleTextField.delegate = self
        cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.bodyTextView.delegate = self
        cell.bodyTextView.layoutManager.delegate = self
        
        titlePlaceholderLabel = cell.titlePlaceholderLabel
        bodyPlaceholderLabel = cell.bodyPlaceholderLabel
        titlePlaceholderLabel.text = Localizer.string(for: .adEditorNamePlaceholder)
        bodyPlaceholderLabel.text = Localizer.string(for: .adEditorDescriptionPlaceholder)
        titlePlaceholderLabel.animateVisibility(shouldHide: currentAd != nil, duration: 0)
        bodyPlaceholderLabel.animateVisibility(shouldHide: currentAd != nil, duration: 0)
        titleEditableTextField = cell.titleTextField
        bodyEditableTextView = cell.bodyTextView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.titleEditableTextField.becomeFirstResponder()
        }
        
        setupPreferencesView()
        titleEditableTextField.inputAccessoryView = preferencesView
        bodyEditableTextView.inputAccessoryView = preferencesView
        
        return cell
    }
    
    private func setupParticipantCell(for indexPath: IndexPath, participant: AdParticipant) -> UserTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: adParticipantCellId, for: indexPath) as! UserTableViewCell
        
        var name: String?
        var surname: String?
        var detailInfo: String?
        
        if let user = participant.content as? User {
            
            if user.id! == currentAd.userId {
                detailInfo = Localizer.string(for: .adEditorCreator)
            }
            name = user.firstName
            surname = user.lastName
            
            if user.id! == PersistentStore.shared.user.id {
                cell.avatarGradientLayer.colors = UserGradient.currentColors
            }
            
        } else if let organization = participant.content as? Organization {
            
            detailInfo = Localizer.string(for: .adEditorCreator)
            name = organization.name
            
        }
        
        
        cell.initialsLabel.text = String(name!.prefix(1)) + (surname?.prefix(1) ?? "")
        cell.nameLabel.text = (name ?? "") + " " + (surname ?? "")
        cell.nameLabel.font = .preferredFont(for: .body, weight: .medium)
        cell.detailTextLabel?.text = detailInfo
        
        cell.selectionStyle = .none
                
        cell.avatarViewSizeConstraint.constant = 40
        return cell
    }
    
    private func setupCurrentUserCell(for indexPath: IndexPath) -> CurrentUserAdTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: currentUserCellId, for: indexPath) as! CurrentUserAdTableViewCell
        
        let currentUser = PersistentStore.shared.user!
        cell.initialsLabel.text = String(currentUser.firstName.prefix(1)) + currentUser.lastName.prefix(1)
        
        cell.nameLabel.textColor = .globalTintColor
        cell.nameLabel.text = Localizer.string(for: .adEditorJoinAd) + "..."
        
        cell.avatarViewSizeConstraint.constant = 40
        return cell
    }
    
    fileprivate func animateBackgroundChange(for cell: UITableViewCell) {
        let initialCellBackgroundColor = cell.contentView.backgroundColor
        cell.contentView.backgroundColor = UIColor.globalTintColor.withAlphaComponent(0.2)
        UIView.animate(withDuration: 1.5) {
            cell.contentView.backgroundColor = initialCellBackgroundColor
        }
    }

}

// MARK: - Table view data source

extension AdViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return currentSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSections[section] {
        case .body, .editableBody, .commentInput:
            return 1
        case .comments:
            return currentAdComments.count
        case .people:
            return currentAdPeople.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch currentSections[indexPath.section] {
        case .comments:
            cell = setupCommentCell(for: indexPath)
        case .commentInput:
            cell = setupCommentInputCell(for: indexPath)
        case .body:
            cell = setupBodyCell(for: indexPath)
        case .editableBody:
            cell = setupEditableBodyCell(for: indexPath)
        case .people:
            let participant = currentAdPeople[indexPath.row]
            if participant.type == .user || participant.type == .organization {
                cell = setupParticipantCell(for: indexPath, participant: participant)
            } else {
                cell = setupCurrentUserCell(for: indexPath)
            }
        }
        
        cell.contentView.backgroundColor = .systemBackground
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = currentSections[section]
        if section == .comments {
            return Localizer.string(for: .adEditorComments)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section = currentSections[section]
        if section == .people {
            return UIView()
        }
        return nil
    }
    
}

// MARK: UITableViewDelegate

extension AdViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemBackground
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let section = currentSections[section]
        if section == .people {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch currentSections[indexPath.section] {
        case .comments, .people:
            return indexPath
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentSections[indexPath.section] {
        case .comments:
            let comment = currentAdComments[indexPath.row]
            presentCommentActions(id: comment.id)
            animateBackgroundChange(for: tableView.cellForRow(at: indexPath)!)
        case .people:
            presentParticipantsActions(indexPath: indexPath)
            animateBackgroundChange(for: tableView.cellForRow(at: indexPath)!)
        default:
            break
        }
        
    }
}

// MARK: TextViewDelegate

extension AdViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === commentInputTextView {
            commentInputUpdated(with: textView.text)
        } else if textView === bodyEditableTextView {
            adBodyUnderEditing = bodyEditableTextView.text
            bodyPlaceholderLabel.animateVisibility(shouldHide: !adBodyUnderEditing.isEmpty)
            updatePublishButton()
        }
        updateTableViewHeight()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView === commentInputTextView {
            currentState = .commenting
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView === commentInputTextView {
            currentState = .viewing
        }
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === tableView {
            headerView.toggleState(showTitle: scrollView.contentOffset.y > 0)
        }
    }
    
}

// MARK: UITextFieldDelegate

extension AdViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        adNameUnderEditing = titleEditableTextField.text!
        titlePlaceholderLabel.animateVisibility(shouldHide: !adNameUnderEditing.isEmpty)
        updatePublishButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === titleEditableTextField {
            bodyEditableTextView.becomeFirstResponder()
        }
        return false
    }
    
}

// MARK: UIPresentationController

extension AdViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        switch currentState {
        case .editing, .publishing:
            return false
        default:
            return true
        }
    }
}

// MARK: APIClientDelegate

extension AdViewController: APIClientDelegate {
    
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {
        headerView.moreButton.animateVisibility(shouldHide: false)
        updateComments(with: ad.comments ?? [], partialUpdate: needToUpdateComments)
        updateParticipants(with: ad)
        needToUpdateComments = false
        set(ad: ad)
        headerView.titleText = self.currentAd.name
    }
    
    func apiClient(_ client: APIClient, didRecieveOrganizations organizations: [Organization], withOptions options: [APIClient.OrganizationRequestOption]?) {
        publishableOrganizations = organizations
    }
    
    func apiClient(_ client: APIClient, didCreateAd newAd: Ad) {
        set(ad: newAd)
        headerView.titleText = self.currentAd.name
        RootViewController.stopLoadingIndicator(with: .success) {
            self.exitEditingState(shouldShowPrompt: false)
        }
        updateAdsVC()
    }
    
    func apiClient(_ client: APIClient, didUpdateAd updatedAd: Ad) {
        set(ad: updatedAd)
        RootViewController.stopLoadingIndicator(with: .success) {
            self.exitEditingState(shouldShowPrompt: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.headerView.titleText = self.currentAd.name
            }
        }
        updateAdsVC()
    }
    
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String, userInfo: [String: Any]? = nil) {
        RootViewController.stopLoadingIndicator(with: .success) {
            self.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            if let adsVC = RootViewController.main.mainController.feedViewController.visibleViewController as? AdsViewController {
                adsVC.apiClient(client, didDeleteAdWithId: adId, userInfo: userInfo)
            }
        })
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    func apiClient(_ client: APIClient, didCreateCommentForAdWithId adId: String) {
        commentInputTextView.isEditable = true
        commentInputTextView.text = ""
        RootViewController.stopLoadingIndicator(with: .success)
        needToUpdateComments = true
        client.getAd(withId: adId)
    }
    
    func apiClient(_ client: APIClient, didBookmarkAdWithId adId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        currentAd.isFavorite = true
        updateAdsVC()
    }
    
    func apiClient(_ client: APIClient, didUnbookmarkAdWithId adId: String, userInfo: [String : Any]?) {
        RootViewController.stopLoadingIndicator(with: .success)
        currentAd.isFavorite = false
        updateAdsVC()
    }
    
    func apiClient(_ client: APIClient, didDeleteCommentWithId commentId: String) {
        var deletedIndex: Int = -1
        for (index, comment) in currentAdComments.enumerated() {
            if comment.id == commentId {
                deletedIndex = index
                break
            }
        }
        
        let _ = currentAdComments.remove(at: deletedIndex)
        
        if let commentsSectionIndex = getSectionIndex(for: .comments) {
            tableView.deleteRows(at: [IndexPath(row: deletedIndex, section: Int(commentsSectionIndex.first!))], with: .automatic)
        }
    }
    
    func apiClient(_ client: APIClient, didRecieveUser user: User) {
        let userVC = UserPublicController(user: user)
        userVC.navigationItem.title = "\(user.firstName) \(user.lastName)"
        let navVC = UINavigationController(rootViewController: userVC)
        present(navVC, animated: true, completion: nil)
    }
    
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization) {
        let orgVC = OrganizationViewController(organization: organization)
        orgVC.navigationItem.title = organization.name
        let navVC = UINavigationController(rootViewController: orgVC)
        present(navVC, animated: true, completion: nil)
    }

    
}

// MARK: NSLayoutManagerDelegate

extension AdViewController: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 6
    }
}


