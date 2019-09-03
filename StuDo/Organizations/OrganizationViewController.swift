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
    }
    
    let infoPositions: [[InfoUnit]] = [[.name, .description], [.members]]
    
    let client = APIClient()
    
    
    init(organization: Organization? = nil) {
        super.init(style: .grouped)
        
        client.delegate = self
        
        currentOrganization = organization
        if let organization = organization {
            client.getOrganization(withId: organization.id)
            client.getMembers(forOrganizationWithId: organization.id)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.keyboardDismissMode = .interactive

        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: textFieldCellId)
        tableView.register(TableViewCellWithTextViewInput.self, forCellReuseIdentifier: textViewCellId)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: userCellId)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return infoPositions.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let info = infoPositions[section].first, info == .members {
            return organizationMembers.count
        }
        
        return infoPositions[section].count
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
        let info = infoPositions[indexPath.section][indexPath.row]
        
        if info == .members {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath)

            let currentMember = organizationMembers[indexPath.row]
            if currentMember.user.id! == currentOrganization!.creatorId {
                cell.detailTextLabel?.text = Localizer.string(for: .organizationAdmin)
                cell.detailTextLabel?.textColor = .globalTintColor
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
        } else {
            // if it's description
            let cell = tableView.dequeueReusableCell(withIdentifier: textViewCellId, for: indexPath) as! TableViewCellWithTextViewInput
            cell.selectionStyle = .none
            
            descriptionTextView = cell.textViewInput
            descriptionTextView.delegate = self
            
            descriptionPlaceholderLabel = cell.placeholderLabel
            descriptionPlaceholderLabel.text = Localizer.string(for: .organizationDescriptionPlaceholder)
            
            if let description = currentOrganization?.description, !description.isEmpty {
                descriptionPlaceholderLabel.isHidden = false
                descriptionTextView.text = description
            } else {
                descriptionPlaceholderLabel.isHidden = true
            }
            
            if currentOrganization != nil {
                descriptionTextView.isUserInteractionEnabled = false
            }
            
            return cell
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
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization) {
        nameTextField.text = organization.name
        if organization.description.isEmpty {
            descriptionPlaceholderLabel.isHidden = false
        } else {
            descriptionPlaceholderLabel.isHidden = true
        }
        descriptionTextView.text = organization.description
    }
    
    func apiClient(_ client: APIClient, didRecieveOrganizationMembers members: [OrganizationMember]) {
        organizationMembers = members
        tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
}
