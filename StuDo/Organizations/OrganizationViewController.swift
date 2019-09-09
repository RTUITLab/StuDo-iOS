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


class OrganizationViewController: UITableViewController {
    
    static let organizationIdKey = "organizationIdKey"
    enum OrganizationNotifications: String, NotificationName {
        case userDidDeleteOrganization
    }
    
    var organizationMembers = [OrganizationMember]()
    
    var currentOrganization: Organization? = nil
    var nameTextField: UITextField!
    
    var descriptionPlaceholderLabel: UILabel!
    var descriptionTextView: UITextView!
    
    enum InfoUnit: String {
        case name
        case description
        case members
        case delete
        case join
    }
    
    let infoPositionsNotMember: [[InfoUnit]] = [[.name, .description, .join], [.members]]
    let infoPositionsMember: [[InfoUnit]] = [[.name, .description], [.members]]
    let infoPositionsEditing: [[InfoUnit]] = [[.name, .description, .delete], [.members]]

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
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: userCellId)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: actionCellId)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentOrganization == nil {
            nameTextField.becomeFirstResponder()
        }
    }
    
    
    
    func switchMode(toEditing: Bool) {
        
        isEditingModeEnabled = toEditing
        nameTextField.isUserInteractionEnabled = toEditing
        descriptionTextView.isUserInteractionEnabled = toEditing
        
        if toEditing {
            navigationItem.rightBarButtonItem = doneButton
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
        } else {
            navigationItem.rightBarButtonItem = editButton
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)

            if let editedName = nameTextField.text, let editedDescription = descriptionTextView.text {
                if editedName != currentOrganization!.name || editedDescription != currentOrganization!.description {
                    client.replaceOrganization(with: Organization(id: currentOrganization!.id, name: nameTextField.text ?? "", description: descriptionTextView.text ?? ""))
                    RootViewController.startLoadingIndicator()
                }
            }
            
        }
        
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
        
        if sectionPositions.first! == .members {
            return organizationMembers.count
        }
        return sectionPositions.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Localizer.string(for: .organizationInfoHeaderTitle)
        } else if section == 1 {
            return Localizer.string(for: .organizationMembersHeaderTitle)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = getInfo(for: indexPath)
        
        if info == .members {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath)

            let currentMember = organizationMembers[indexPath.row]
            if currentMember.user.id! == currentOrganization!.creatorId {
                cell.detailTextLabel?.text = Localizer.string(for: .organizationAdmin)
                cell.detailTextLabel?.textColor = .globalTintColor
                creatorCellRow = indexPath.row
            }
            cell.textLabel?.text = "\(currentMember.user.firstName) \(currentMember.user.lastName)"
            
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
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: actionCellId, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        if info == .delete {
            cell.textLabel?.textColor = .red
            cell.textLabel?.text = Localizer.string(for: .delete)
        } else if info == .join {
            cell.textLabel?.textColor = .globalTintColor
            cell.textLabel?.text = Localizer.string(for: .organizationJoin)
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
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization) {
        set(organization: organization)
    }
    
    func apiClient(_ client: APIClient, didRecieveOrganizationMembers members: [OrganizationMember]) {
        organizationMembers = members
        for member in members {
            if member.user.id == PersistentStore.shared.user.id! {
                currentUserAsMember = member
            }
        }
        
        if currentUserAsMember == nil {
            currentUserState = .notMember
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            tableView.endUpdates()
        } else {
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
        
        
        
        
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
        
        tableView.insertSections(IndexSet(integer: 1), with: .fade)
        client.getMembers(forOrganizationWithId: newOrganization.id)
        
        nameTextField.isUserInteractionEnabled = false
        descriptionTextView.isUserInteractionEnabled = false
    }
}



extension OrganizationViewController {
    fileprivate func getInfo(for indexPath: IndexPath) -> InfoUnit {
        if currentUserState == .notMember {
            return infoPositionsNotMember[indexPath.section][indexPath.row]
        }
        if isEditingModeEnabled {
            return infoPositionsEditing[indexPath.section][indexPath.row]
        } else {
            return infoPositionsMember[indexPath.section][indexPath.row]
        }
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
