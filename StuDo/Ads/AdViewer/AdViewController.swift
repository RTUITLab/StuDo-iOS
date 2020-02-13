//
//  AdViewController2.swift
//  StuDo
//
//  Created by Andrew on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import MarkdownKit

private let bodyCellId = "bodyCellId"
private let editableBodyCellId = "editableBodyCellId"
private let commentCellId = "commentCellId"
private let commentInputCellId = "commentInputCellId"
private let adDateButtonsCellId = "adDateButtonsCellId"

class AdViewController: UIViewController {
    
    // MARK: Visible elements
    
    private let tableView: UITableView
    
    private var headerView: AdControllerHeaderView!
    private var commentInputTextView: UITextView!
    private var commentPlaceholderLabel: UILabel!
    private var commentPublishButton: UIButton!
    
    private var titleEditableTextField: UITextField!
    private var bodyEditableTextView: UITextView!
    
    private var beginDateButton: DateButton!
    private var endDateButton: DateButton!
    
    // MARK: - State
    // This properties allow the controller to switch between two states
    // One allows to view the ad, the other allows to edit or publish
    
    private var currentAd: Ad!
    private var currentAdComments: [Comment] = []
    private var currentAdPeople: [User] = []
    
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
    
    private let client = APIClient()
    
    enum AdViewControllerSection {
        case body
        case editableBody
        case people
        case comments
        case commentInput
        case preferences
    }
    
    private let viewStateSections: [AdViewControllerSection] = [
        .body, .people, .comments, .commentInput
    ]
    
    private let editStateSections: [AdViewControllerSection] = [
        .editableBody, .preferences
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
        presentationController?.delegate = self
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
    }
        
    private func setTableView() {
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // TODO: Remove
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        
        tableView.register(UINib(nibName: String(describing: AdBodyCell.self), bundle: nil), forCellReuseIdentifier: bodyCellId)
        tableView.register(UINib(nibName: String(describing: EditableAdBodyCell.self), bundle: nil), forCellReuseIdentifier: editableBodyCellId)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: commentCellId)
        tableView.register(CommentInputTableViewCell.self, forCellReuseIdentifier: commentInputCellId)
        tableView.register(AdPreferencesCell.self, forCellReuseIdentifier: adDateButtonsCellId)
        
        tableView.backgroundColor = .secondarySystemBackground
        tableView.tableFooterView = UIView()
        
        tableView.separatorStyle = .none
        
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
        headerView.backgroundColor = .red
        
    }
        
    // MARK: - Model-related methods
            
    private func set(ad: Ad) {
        currentAd = ad
        if ad.comments != currentAdComments {
            currentAdComments = ad.comments ?? []
            if let commentsSectionIndex = getSectionIndex(for: .comments) {
                tableView.reloadSections(commentsSectionIndex, with: .fade)
            }
        }
        
        if currentState == .previewing {
            currentState = .viewing
            if let bodySectionIndex = getSectionIndex(for: .body) {
                tableView.reloadSections(bodySectionIndex, with: .fade)
            }
        }
    }
    
    private func deleteCurrentAd() {
        func deleteAd() {
            client.deleteAd(withId: currentAd.id)
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
    
    // MARK: Editing & Publishing
    
    private func checkIfCanPublishAd() -> Bool {
        adNameUnderEditing.count > 0 && adBodyUnderEditing.count > 0
    }
    
    private func updatePublishButton() {
        headerView.togglePublishButton(isEnabled: checkIfCanPublishAd())
    }
    
    func publishCurrentAd() {
        
        let adTitle = adNameUnderEditing
        let description = adNameUnderEditing
        var shortDescription: String!
        
        if let firstParagraph = adBodyUnderEditing.components(separatedBy: CharacterSet.newlines).first {
            shortDescription = firstParagraph
        } else {
            shortDescription = description
        }
        
//        let beginTime = beginDateButton.date!
//        let endTime = endDateButton.date!
        let beginTime = Date()
        let endTime = Date()
        

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
        }
        
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
        
        if canEditAd {
            let inviteAction = UIAlertAction(title: Localizer.string(for: .adEditorFindPeople), style: .default, handler: nil)
            let editAction = UIAlertAction(title: Localizer.string(for: .adEditorEditAd), style: .default, handler: { _ in self.enableEditingState() } )
            let deleteAction = UIAlertAction(title: Localizer.string(for: .adEditorDeleteAd), style: .destructive, handler: { _ in self.deleteCurrentAd() } )

            actionSheet.addAction(inviteAction)
            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
        } else {
            let title = Localizer.string(for: .adEditorAddToBookmarks)
            let bookmarkAction = UIAlertAction(title: title, style: .default) { _ in
                self.toggleBookmark()
            }
            actionSheet.addAction(bookmarkAction)
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
    
    @objc func beginDateButtonTapped(_ button: UIButton) {
        let datePickerVC = DatePickerController(title: Localizer.string(for: .adEditorBeginDateLabel))
        datePickerVC.datePicker.minimumDate = Date()
        datePickerVC.doneCompletionHandler = { [weak self] in
            guard let self = self, self.beginDateButton != nil else { return }
            let beginDate = datePickerVC.datePicker.date
            self.beginDateButton.date = beginDate
            if let endDate = self.endDateButton.date, endDate.compare(beginDate) == .orderedAscending {
                self.endDateButton.date = nil
            }
        }
        datePickerVC.modalPresentationStyle = .fullScreen
        present(datePickerVC, animated: true, completion: nil)
    }
    
    @objc func endDateButtonTapped(_ button: UIButton) {
        let datePickerVC = DatePickerController(title: Localizer.string(for: .adEditorEndDateLabel))
        
        if beginDateButton.date == nil {
            datePickerVC.datePicker.minimumDate = Date()
        } else {
            datePickerVC.datePicker.minimumDate = beginDateButton.date
        }
        
        datePickerVC.doneCompletionHandler = { [weak self] in
            guard let self = self, self.endDateButton != nil else { return }
            let endDate = datePickerVC.datePicker.date
            self.endDateButton.date = endDate
            if let beginDate = self.beginDateButton.date, beginDate.compare(endDate) == .orderedDescending {
                self.beginDateButton.date = nil
            }
        }
        datePickerVC.modalPresentationStyle = .fullScreen
        present(datePickerVC, animated: true, completion: nil)
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
            
            // FIX: Possible error can be possible if the ad is not loaded
            adBodyUnderEditing = currentAd.description! // TODO: Use FULL description instead (must be calculated!)
        }
        
        headerView.showEditingControls = true
        headerView.togglePublishButton(isEnabled: false)

        reloadTableView()
    }
    
    private func exitEditingState(shouldShowPrompt: Bool = true) {
        func exitEditing() {
            currentState = .viewing
            self.headerView.showEditingControls = false
            self.reloadTableView()
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

}

// MARK: - Table view data source

extension AdViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return currentSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSections[section] {
        case .body, .editableBody, .preferences, .commentInput:
            return 1
        case .comments:
            return currentAdComments.count
        case .people:
            return currentAdPeople.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell: UITableViewCell!
        switch currentSections[indexPath.section] {
        case .comments:
            let comment = currentAdComments[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentTableViewCell
            cell.bodyTextView.text = comment.text
            cell.nameLabel.text = comment.author

            // TODO: This code should be put in a separate file and refactored
            // NOTE: The cell class is subclass of UserTableViewCell
            let formatter = DateFormatter()
            formatter.locale = Localizer.currentLocale
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            cell.dateLabel.text = formatter.string(from: comment.commentTime)
            
            let nameParts = comment.author.components(separatedBy: " ")
            if nameParts.count == 1 {
                cell.initialsLabel.text = String(nameParts.first!.suffix(1))
            } else if nameParts.count == 2 {
                let name = nameParts.last!
                let surname = nameParts.first!
                cell.initialsLabel.text = String(name.prefix(1)) + surname.prefix(1)
                
                cell.nameLabel.text = "\(name) \(surname)"
            }
            
            cell.isAvatarHighlighted = (comment.authorId == PersistentStore.shared.user.id)
            
            cell.selectionStyle = .none
            
            returnCell = cell
        case .commentInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: commentInputCellId, for: indexPath) as! CommentInputTableViewCell
            
            commentPlaceholderLabel = cell.placeholderLabel
            cell.placeholderLabel.text = Localizer.string(for: .adEditorCommentPlaceholder)
            cell.placeholderLabel.isHidden = false
            
            commentInputTextView = cell.textViewInput
            commentInputTextView.delegate = self
                        
            cell.selectionStyle = .none
            
            commentPublishButton = cell.publishButton
//            commentPublishButton.addTarget(self, action: #selector(publishCommentButtonTapped(_ :)), for: .touchUpInside)

            returnCell = cell
        case .body:
            let cell = tableView.dequeueReusableCell(withIdentifier: bodyCellId, for: indexPath) as! AdBodyCell
            cell.titleLabel.text = currentAd.name
            cell.dateLabel.text = currentAd.dateRange
            cell.selectionStyle = .none
            
            // TODO: Stash this formatting code in a separate class
            var description: String!
            if currentState == .previewing {
                description = currentAd.shortDescription
            } else {
                description = currentAd.description
            }
            
            var markdownParser: MarkdownParser!
            markdownParser = MarkdownParser(font: UIFont.preferredFont(forTextStyle: .body), color: .label)
            
            markdownParser.enabledElements = .all
            markdownParser.bold.font = UIFont.preferredFont(for: .body, weight: .medium)
            markdownParser.italic.font = UIFont.preferredFont(forTextStyle: .body).italic()
            markdownParser.header.font = UIFont.preferredFont(for: .title3, weight: .medium)
            markdownParser.quote.font = UIFont.preferredFont(forTextStyle: .body).italic()
            markdownParser.quote.color = .lightGray
            markdownParser.link.color = .globalTintColor
            
            let attrDescription = NSMutableAttributedString(string: description)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 6
            attrDescription.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attrDescription.length))
            
            cell.bodyTextView.attributedText = markdownParser.parse(attrDescription)
            
            
            returnCell = cell
        case .editableBody:
            let cell = tableView.dequeueReusableCell(withIdentifier: editableBodyCellId, for: indexPath) as! EditableAdBodyCell
            cell.titleTextField.text = adNameUnderEditing
            cell.bodyTextView.text = adBodyUnderEditing
            cell.titleTextField.delegate = self
            cell.titleTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            cell.bodyTextView.delegate = self
            titleEditableTextField = cell.titleTextField
            bodyEditableTextView = cell.bodyTextView
            returnCell = cell
        case .people: fallthrough
        case .preferences:
            let cell = tableView.dequeueReusableCell(withIdentifier: adDateButtonsCellId, for: indexPath) as! AdPreferencesCell
            cell.selectionStyle = .none
            beginDateButton = cell.beginDateButton
            endDateButton = cell.endDateButton
            beginDateButton.addTarget(self, action: #selector(beginDateButtonTapped(_:)), for: .touchUpInside)
            endDateButton.addTarget(self, action: #selector(endDateButtonTapped(_:)), for: .touchUpInside)
            returnCell = cell
        }
        
        returnCell.contentView.backgroundColor = .secondarySystemBackground
        
        return returnCell
    }
    
}

// MARK: UITableViewDelegate

extension AdViewController: UITableViewDelegate {
    
}

// MARK: TextViewDelegate

extension AdViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === commentInputTextView {
            commentInputUpdated(with: textView.text)
        } else if textView === bodyEditableTextView {
            adBodyUnderEditing = bodyEditableTextView.text
            updatePublishButton()
        }
        updateTableViewHeight()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView === commentInputTextView {
            currentState = .commenting
            tableView.keyboardDismissMode = .interactive
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView === commentInputTextView {
            currentState = .viewing
            tableView.keyboardDismissMode = .none
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
        updatePublishButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === titleEditableTextField {
            bodyEditableTextView.becomeFirstResponder()
        }
        return false
    }
    
}

// MARK: UIPresentationCo

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
    }
    
    func apiClient(_ client: APIClient, didUpdateAd updatedAd: Ad) {
        set(ad: updatedAd)
        RootViewController.stopLoadingIndicator(with: .success) {
            self.exitEditingState(shouldShowPrompt: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.headerView.titleText = self.currentAd.name
            }
        }
    }
    
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String) {
        RootViewController.stopLoadingIndicator(with: .success) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        RootViewController.stopLoadingIndicator(with: .fail)
    }

    
}


