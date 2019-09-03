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
    
    var organizationMembers = [OrganizationMember]()
    
    var currentOrganization: Organization? = nil
    var nameTextField: UITextField!
    
    var descriptionPlaceholderLabel: UILabel!
    var descriptionTextView: UITextView!
    
    enum InfoUnit {
        case name
        case description
        case members
        case delete
    }
    
    let infoPositions: [[InfoUnit]] = [[.name, .description], [.members]]
    let infoPositionsEditing: [[InfoUnit]] = [[.name, .description], [.members], [.delete]]

    let client = APIClient()
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    
    var userCanEditOrganizationInfo = false
    
    var isEditingModeEnabled: Bool = false
    
    var creatorCellRow: Int!
    
    
    init(organization: Organization? = nil) {
        super.init(style: .grouped)
        
        doneButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: #selector(doneButtonTapped(_:)))
        editButton = UIBarButtonItem(title: Localizer.string(for: .edit), style: .plain, target: self, action: #selector(editButtonTapped(_:)))
        
        client.delegate = self
        
        currentOrganization = organization
        if let organization = organization {
            client.getOrganization(withId: organization.id)
            client.getMembers(forOrganizationWithId: organization.id)
            
            if organization.creatorId == PersistentStore.shared.user.id! {
                userCanEditOrganizationInfo = true
            }
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
        
        if userCanEditOrganizationInfo {
            navigationItem.rightBarButtonItem = editButton
        }
        
    }
    
    
    
    func switchMode(toEditing: Bool) {
        
        isEditingModeEnabled = toEditing
        nameTextField.isUserInteractionEnabled = toEditing
        descriptionTextView.isUserInteractionEnabled = toEditing
        
        if toEditing {
            navigationItem.rightBarButtonItem = doneButton
            tableView.insertSections(IndexSet(integer: 2), with: .fade)
        } else {
            navigationItem.rightBarButtonItem = editButton
            tableView.deleteSections(IndexSet(integer: 2), with: .fade)
            
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
        nameTextField.text = organization.name
        if organization.description.isEmpty {
            descriptionPlaceholderLabel.isHidden = false
        } else {
            descriptionPlaceholderLabel.isHidden = true
        }
        descriptionTextView.text = organization.description
    }
    
    
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isEditingModeEnabled {
            return infoPositionsEditing.count
        }
        return infoPositions.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionPositions: [InfoUnit]!
        if isEditingModeEnabled {
            sectionPositions = infoPositionsEditing[section]
        } else {
            sectionPositions = infoPositions[section]
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
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let info = getInfo(for: indexPath)
        if info == .members, indexPath.row != creatorCellRow {
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
        }
    }
}




extension OrganizationViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization) {
        set(organization: organization)
    }
    
    func apiClient(_ client: APIClient, didRecieveOrganizationMembers members: [OrganizationMember]) {
        organizationMembers = members
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
    
    func apiClient(_ client: APIClient, didDeleteOrganizationWithId organizationId: String) {
        RootViewController.stopLoadingIndicator(with: .success)
        navigationController?.popViewController(animated: true)
    }
    
    func apiClient(_ client: APIClient, didUpdateOrganization updatedOrganization: Organization) {
        set(organization: updatedOrganization)
        RootViewController.stopLoadingIndicator(with: .success)
    }
}



extension OrganizationViewController {
    fileprivate func getInfo(for indexPath: IndexPath) -> InfoUnit {
        if isEditingModeEnabled {
            return infoPositionsEditing[indexPath.section][indexPath.row]
        } else {
            return infoPositions[indexPath.section][indexPath.row]
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
    
}
