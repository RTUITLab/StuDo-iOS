//
//  OrganizationViewController.swift
//  StuDo
//
//  Created by Andrew on 9/2/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let textFieldCellId = "textFieldCellId"
fileprivate let textViewCellId = "textViewCellId"
fileprivate let userCellId = "userCellId"
fileprivate let actionCellId = "actionCellId"
fileprivate let adCellId = "adCellId"


class OrganizationViewController: UITableViewController {
    
    static let organizationIdKey = "organizationIdKey"
    enum OrganizationNotifications: String, NotificationName {
        case userDidDeleteOrganization
    }
    
    var organizationMembers = [OrganizationMember]()
    var organizationAds = [Ad]()
    var organizationWishers = [OrganizationMember]()
    
    var applicationSent = false // becomes true if user's awaiting response to join application
    var currentOrganization: Organization? = nil
    var nameTextField: UITextField!
    
    var descriptionPlaceholderLabel: UILabel!
    var descriptionTextView: UITextView!
    
    enum InfoUnit: String {
        case name
        case description
        case members
        case wishers
        case delete
        case join
        case ads
    }
    
    let infoPositionsNotMember: [[InfoUnit]] = [[.name, .description, .join], [.wishers, .members], [.ads]]
    let infoPositionsMember: [[InfoUnit]] = [[.name, .description], [.wishers, .members], [.ads]]
    let infoPositionsEditing: [[InfoUnit]] = [[.name, .description, .delete], [.wishers, .members]]
    
    let client = APIClient()
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem?
    var createButton: UIBarButtonItem?
    
    var userCanEditOrganizationInfo = false
    
    var isEditingModeEnabled: Bool = false
    
    var creatorCellRow: Int!
    
    enum UserState {
        case member
        case notMember
        case unknown
    }
    var currentUserState: UserState = .unknown
    
    
    var canUserEditMembers = false
    var currentUserAsMember: OrganizationMember? = nil {
        didSet {
            guard let member = currentUserAsMember else {
                navigationItem.rightBarButtonItem = nil
                canUserEditMembers = false
                return
            }
            
            if member.rights.contains(.canEditOrganizationInformation) {
                navigationItem.rightBarButtonItem = editButton
            } else {
                navigationItem.rightBarButtonItem = nil
            }
            
            canUserEditMembers = member.rights.contains(.canEditMembers)
            
        }
    }
    
    
    init(organization: Organization? = nil) {
        super.init(style: .grouped)
        
        doneButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: #selector(doneButtonTapped(_:)))
        editButton = UIBarButtonItem(title: Localizer.string(for: .edit), style: .plain, target: self, action: #selector(editButtonTapped(_:)))
        
        client.delegate = self
        
        currentOrganization = organization
        if let organization = organization {
            client.getOrganization(withId: organization.id)
            client.getMembers(forOrganizationWithId: organization.id)
            client.getAds(forOrganizationWithId: organization.id)
            client.getWishers(forOrganizationWithId: organization.id)
        } else {
            createButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: #selector(createButtonTapped(_:)))
            createButton!.isEnabled = false
            navigationItem.rightBarButtonItem = createButton
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .interactive
        tableView.allowsSelectionDuringEditing = true
        
        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: textFieldCellId)
        tableView.register(TableViewCellWithTextViewInput.self, forCellReuseIdentifier: textViewCellId)
        tableView.register(MemberTableViewCell.self, forCellReuseIdentifier: userCellId)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: actionCellId)
        tableView.register(UINib(nibName: "AdTableViewCell", bundle: nil), forCellReuseIdentifier: adCellId)
        
        tabBarController?.hideTabBar()
        
    }
    
    var firstAppear = true
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.hideTabBar()
        if !firstAppear {
            client.getMembers(forOrganizationWithId: currentOrganization!.id)
            client.getAds(forOrganizationWithId: currentOrganization!.id)
        }
        firstAppear = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentOrganization == nil {
            nameTextField.becomeFirstResponder()
        }
        tabBarController?.hideTabBar()
        
    }
    
    
    
    func switchMode(toEditing: Bool) {
        
        isEditingModeEnabled = toEditing
        nameTextField.isUserInteractionEnabled = toEditing
        descriptionTextView.isUserInteractionEnabled = toEditing
        
        tableView.beginUpdates()
        
        if toEditing {
            navigationItem.rightBarButtonItem = doneButton
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
            tableView.deleteSections(IndexSet(integer: 2), with: .fade)
        } else {
            navigationItem.rightBarButtonItem = editButton
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
            tableView.insertSections(IndexSet(integer: 2), with: .fade)
            
            if let editedName = nameTextField.text, let editedDescription = descriptionTextView.text {
                if editedName != currentOrganization!.name || editedDescription != currentOrganization!.description {
                    client.replaceOrganization(with: Organization(id: currentOrganization!.id, name: nameTextField.text ?? "", description: descriptionTextView.text ?? ""))
                    RootViewController.startLoadingIndicator()
                }
            }
            
        }
        tableView.endUpdates()
        
        tableView.setEditing(toEditing, animated: true)
        
    }
    
    
    fileprivate func set(organization: Organization) {
        currentOrganization = organization
        
        nameTextField.text = organization.name
        if organization.description.isEmpty {
            descriptionPlaceholderLabel.isHidden = false
        } else {
            descriptionPlaceholderLabel.isHidden = true
        }
        descriptionTextView.text = organization.description
    }
    
    func checkIfCanPublish() {
        let name = nameTextField.text!
        let description = descriptionTextView.text!
        
        if name.isEmpty || description.isEmpty {
            createButton?.isEnabled = false
        } else {
            createButton?.isEnabled = true
        }
    }
    
    
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if currentOrganization == nil {
            return 1
        }
        if currentUserState == .notMember {
            return infoPositionsNotMember.count
        }
        
        if isEditingModeEnabled {
            return infoPositionsEditing.count
        }
        return infoPositionsMember.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionPositions: [InfoUnit]!
        
        if currentUserState == .notMember {
            sectionPositions = infoPositionsNotMember[section]
        } else if isEditingModeEnabled {
            sectionPositions = infoPositionsEditing[section]
        } else {
            sectionPositions = infoPositionsMember[section]
        }
        
        if sectionPositions.first! == .ads {
            return organizationAds.count
        } else if sectionPositions.last! == .members {
            return organizationMembers.count + 1
        }
        
        return sectionPositions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Localizer.string(for: .organizationInfoHeaderTitle)
        } else if section == 1 {
            return Localizer.string(for: .organizationMembersHeaderTitle)
        } else if section == 2 && !organizationAds.isEmpty {
            return Localizer.string(for: .userPublicAdsSectionHeader)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = getInfo(for: indexPath)
        
        print(indexPath, info, currentUserState)

        if info == .members {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserTableViewCell
            
            let currentMember = organizationMembers[indexPath.row - 1]
            if currentMember.user.id! == currentOrganization!.creatorId {
                cell.detailTextLabel?.text = Localizer.string(for: .organizationAdmin)
                cell.detailTextLabel?.textColor = .globalTintColor
                creatorCellRow = indexPath.row
            } else {
                cell.detailTextLabel?.text = ""
            }
            
            cell.initialsLabel.text = String(currentMember.user.firstName.prefix(1)) + currentMember.user.lastName.prefix(1)
            cell.nameLabel.text = "\(currentMember.user.firstName) \(currentMember.user.lastName)"
            
            if currentMember.user.id! == PersistentStore.shared.user.id {
                cell.avatarGradientLayer.colors = UserGradient.currentColors
            } else {
                cell.avatarGradientLayer.colors = UserGradient.grayColors
            }
            
            return cell
        } else if info == .name {
            let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellId, for: indexPath) as! TableViewCellWithInputField
            cell.selectionStyle = .none
            
            nameTextField = cell.inputField
            nameTextField.placeholder = Localizer.string(for: .organizationNamePlaceholder)
            nameTextField.text = currentOrganization?.name
            
            nameTextField.font = .preferredFont(for: .body, weight: .semibold)
            nameTextField.returnKeyType = .continue
            
            nameTextField.delegate = self
            nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            if currentOrganization != nil {
                nameTextField.isUserInteractionEnabled = false
            }
            
            return cell
        } else if info == .description {
            let cell = tableView.dequeueReusableCell(withIdentifier: textViewCellId, for: indexPath) as! TableViewCellWithTextViewInput
            cell.selectionStyle = .none
            
            descriptionTextView = cell.textViewInput
            descriptionTextView.delegate = self
            
            descriptionPlaceholderLabel = cell.placeholderLabel
            descriptionPlaceholderLabel.text = Localizer.string(for: .organizationDescriptionPlaceholder)
            
            if let description = currentOrganization?.description, !description.isEmpty {
                descriptionPlaceholderLabel.isHidden = true
                descriptionTextView.text = description
            } else {
                descriptionPlaceholderLabel.isHidden = false
            }
            
            if currentOrganization != nil {
                descriptionTextView.isUserInteractionEnabled = false
            }
            
            return cell
        } else if info == .ads {
            let cell = tableView.dequeueReusableCell(withIdentifier: adCellId, for: indexPath) as! AdTableViewCell
            let currentAd = organizationAds[indexPath.row]
            cell.titleLabel.text = currentAd.name
            cell.creatorLabel.text = Localizer.string(for: .feedPublishedBy) + " " + currentAd.creatorName
            cell.descriptionTextView.text = currentAd.shortDescription
            cell.dateLabel.text = currentAd.dateRange
            cell.moreButton.isHidden = true
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: actionCellId, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        if info == .delete {
            cell.isHidden = shouldHideDeleteRow
            cell.textLabel?.textColor = .systemRed
            cell.textLabel?.text = Localizer.string(for: .delete)
        } else if info == .join {
            if applicationSent {
                cell.textLabel?.text = Localizer.string(for: .organizationJoinSuccessMessage)
                cell.textLabel?.textColor = .placeholderText
                cell.accessoryType = .none
            } else {
                cell.textLabel?.textColor = .globalTintColor
                cell.textLabel?.text = Localizer.string(for: .organizationJoin)
            }
        } else if info == .wishers {
            cell.textLabel?.textColor = .globalTintColor
            cell.textLabel?.text = Localizer.string(for: .organizationWishersList)
            cell.isHidden = shouldHideWishersRow
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let info = getInfo(for: indexPath)
        if canUserEditMembers && info == .members, indexPath.row != creatorCellRow {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let info = getInfo(for: indexPath)
        if info == .join && applicationSent {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = getInfo(for: indexPath)
        if info == .delete {
            let alert = UIAlertController(title: nil, message: Localizer.string(for: .organizationDeletionAlertMessage), preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: Localizer.string(for: .delete), style: .destructive, handler: { _ in
                self.client.deleteOrganization(withId: self.currentOrganization!.id)
                RootViewController.startLoadingIndicator()
            } )
            let cancelAction = UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else if info == .ads {
            let currentAd = organizationAds[indexPath.row]
            let adVC = AdViewController(ad: currentAd)
            present(adVC, animated: true, completion: nil)
        } else if info == .join {
            client.apply(to: currentOrganization!)
        } else if info == .wishers {
            let wishersVC = ApplicantsViewController(organization: currentOrganization!)
            wishersVC.applicants = organizationWishers
            navigationController?.pushViewController(wishersVC, animated: true)
        } else if info == .members {
            let currentMember = organizationMembers[indexPath.row - 1]
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if let user = currentUserAsMember, user.rights.contains(.canEditRights) {
                if currentMember.user.id! != currentOrganization!.creatorId {
                    alert.addAction(UIAlertAction(title: Localizer.string(for: .organizationEditRights), style: .default, handler: { (_) in
                        let rightsVC = RightsViewController(member: currentMember, organization: self.currentOrganization!)
                        self.navigationController?.pushViewController(rightsVC, animated: true)
                    }))
                }
            }
            
            if currentMember.user.id! != PersistentStore.shared.user.id! {
                alert.addAction(UIAlertAction(title: "\(currentMember.user.firstName) \(currentMember.user.lastName)", style: .default, handler: { _ in
                    self.client.getUser(id: currentMember.user.id!)
                }))
            }
            if !alert.actions.isEmpty {
                alert.addAction(UIAlertAction(title: Localizer.string(for: .cancel), style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let info = getInfo(for: indexPath)
        if info == .wishers && shouldHideWishersRow{
            return 0
        } else if info == .delete && shouldHideDeleteRow {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    var shouldHideWishersRow: Bool {
        if let user = currentUserAsMember {
            if user.rights.contains(.canEditRights) && !organizationWishers.isEmpty { return false }
        }
        return true
    }
    
    var shouldHideDeleteRow: Bool {
        if let user = currentUserAsMember {
            return !user.rights.contains(.canDeleteOrganization)
        }
        return true
    }
    
}


extension OrganizationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === descriptionTextView {
            if descriptionTextView.text.isEmpty {
                descriptionPlaceholderLabel.isHidden = false
            } else {
                descriptionPlaceholderLabel.isHidden = true
            }
            checkIfCanPublish()
            updateTableViewLayout(toFit: descriptionTextView)
        }
    }
}

extension OrganizationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            descriptionTextView.becomeFirstResponder()
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField === nameTextField {
            checkIfCanPublish()
        }
    }
}




extension OrganizationViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        RootViewController.stopLoadingIndicator(with: .fail)
        print(error.localizedDescription)
    }
    
    func apiClient(_ client: APIClient, didReceiveOrganization organization: Organization) {
        set(organization: organization)
    }
    
    func apiClient(_ client: APIClient, didReceiveOrganizationMembers members: [OrganizationMember]) {
        organizationMembers = members
        for member in members {
            if member.user.id == PersistentStore.shared.user.id! {
                currentUserAsMember = member
            }
        }
        
        if currentUserAsMember == nil {
            if currentUserState == .unknown {
                currentUserState = .notMember
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                tableView.endUpdates()
            }
        } else {
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        
        
        
        
    }
    
    func apiClient(_ client: APIClient, didReceiveAds ads: [Ad], forOrganizationWithId: String) {
        organizationAds = ads
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
    
    func apiClient(_ client: APIClient, didDeleteOrganizationWithId organizationId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: OrganizationViewController.OrganizationNotifications.userDidDeleteOrganization.name, object: nil, userInfo: [OrganizationViewController.organizationIdKey: organizationId])
    }
    
    func apiClient(_ client: APIClient, didUpdateOrganization updatedOrganization: Organization) {
        set(organization: updatedOrganization)
        RootViewController.stopLoadingIndicator(with: .success)
    }
    
    func apiClient(_ client: APIClient, didCreateOrganization newOrganization: Organization) {
        createButton = nil
        navigationItem.rightBarButtonItem = editButton
        set(organization: newOrganization)
        RootViewController.stopLoadingIndicator(with: .success)
        
        tableView.insertSections(IndexSet(integersIn: 1...2), with: .fade)
        client.getMembers(forOrganizationWithId: newOrganization.id)
        
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
    }
    
    func apiClientDidSendApplyOrganizationRequest(_ client: APIClient) {
        applicationSent = true
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    func apiClient(_ client: APIClient, didReceiveOrganizationWishers wishers: [OrganizationMember]) {
        organizationWishers = wishers
        for wisher in wishers {
            if wisher.user.id == PersistentStore.shared.user.id! {
                applicationSent = true
            }
        }
    }
    
    func apiClient(_ client: APIClient, didReceiveUser user: User) {
        let userVC = UserPublicController(user: user)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
}



extension OrganizationViewController {
    fileprivate func getInfo(for indexPath: IndexPath) -> InfoUnit {
        var sectionInfo: [InfoUnit]!
        if currentUserState == .notMember {
            sectionInfo = infoPositionsNotMember[indexPath.section]
        } else {
            if isEditingModeEnabled {
                sectionInfo = infoPositionsEditing[indexPath.section]
            } else {
                sectionInfo = infoPositionsMember[indexPath.section]
            }
        }
        
        if indexPath.row >= sectionInfo.count {
            return sectionInfo.last!
        }
        return sectionInfo[indexPath.row]
    }
}



extension OrganizationViewController {
    
    @objc func editButtonTapped(_ button: UIBarButtonItem) {
        switchMode(toEditing: true)
    }
    
    @objc func doneButtonTapped(_ button: UIBarButtonItem) {
        switchMode(toEditing: false)
    }
    
    @objc func createButtonTapped(_ button: UIBarButtonItem) {
        client.create(organization: Organization(id: nil, name: nameTextField!.text!, description: descriptionTextView!.text!))
        RootViewController.startLoadingIndicator()
    }
    
}



extension OrganizationViewController {
    fileprivate func updateTableViewLayout(toFit textView: UITextView) {
        let actualHeight = textView.frame.size.height
        let calculatedHeight = textView.sizeThatFits(textView.frame.size).height
        
        if actualHeight != calculatedHeight {
            
            UIView.setAnimationsEnabled(false)
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            UIView.setAnimationsEnabled(true)
        }
    }
}
