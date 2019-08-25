//
//  ProfileEditorViewController.swift
//  StuDo
//
//  Created by Andrew on 8/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let textFieldCellId = "textFieldCellId"
fileprivate let textViewCellId = "textViewCellId"
fileprivate let value1styleCellID = "value1styleCellID"



protocol ProfileEditorVCDelegate: class {
    func profileEditorViewController(_ profileVC: ProfileEditorViewController, didCreateProfile createdProfile: Profile)
    func profileEditorViewController(_ profileVC: ProfileEditorViewController, didDeleteProfile deletedProfile: Profile)
    func profileEditorViewController(_ profileVC: ProfileEditorViewController, didUpdateProfile updatedProfile: Profile)
}




class ProfileEditorViewController: UITableViewController {
    
    weak var delegate: ProfileEditorVCDelegate?
    
    var profile: Profile?
    let client = APIClient()
    
    private var nameInitialSetup = true
    private var descriptionInitialSetup = true
    
    private var shouldBecomeFirstResponder = true
    private var shouldAllowDeletion = false

    var nameTextField: UITextField!
    var descriptionTextView: UITextView!
    var saveButton: UIBarButtonItem!
    
    private enum FieldType {
        case name
        case description
        case deleteAction
    }
    private let fieldPosition: [[FieldType]] = [[.name], [.description], [.deleteAction]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.hideTabBar()
        
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.estimatedRowHeight = 44
        tableView.keyboardDismissMode = .interactive
        
        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: textFieldCellId)
        tableView.register(TableViewCellWithTextViewInput.self, forCellReuseIdentifier: textViewCellId)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: value1styleCellID)
        
        saveButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: #selector(saveButtonTapped(_:)))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    init(profile: Profile?) {
        super.init(style: .grouped)
        
        client.delegate = self
        if let profile = profile {
            shouldAllowDeletion = true
            shouldBecomeFirstResponder = false
            
            self.profile = profile
            client.getProfile(withId: profile.id!)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}






extension ProfileEditorViewController {
    
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return Localizer.string(for: .profileNameSectionFooter)
        } else if section == 1 {
            return Localizer.string(for: .profileDescriptionSectionFooter)
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Localizer.string(for: .profileNameSectionHeader)
        } else if section == 1 {
            return Localizer.string(for: .profileDescriptionSectionHeader)
        }
        return nil
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return shouldAllowDeletion ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = fieldPosition[indexPath.section][indexPath.row]
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellId, for: indexPath) as! TableViewCellWithInputField
            
            nameTextField = cell.inputField
            nameTextField.placeholder = Localizer.string(for: .profileNamePlaceholder)
            nameTextField.autocapitalizationType = .sentences
            nameTextField.returnKeyType = .next
            nameTextField.clearButtonMode = .whileEditing
            
            if nameInitialSetup {
                nameInitialSetup = false
                nameTextField.text = profile?.name ?? ""
            }
            
            
            nameTextField.delegate = self
            nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            if shouldBecomeFirstResponder {
                shouldBecomeFirstResponder = false
                
                nameTextField.becomeFirstResponder()
            }
            
            cell.selectionStyle = .none
            
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: textViewCellId, for: indexPath) as! TableViewCellWithTextViewInput
            
            descriptionTextView = cell.textViewInput
            descriptionTextView.autocapitalizationType = .sentences
            
            descriptionTextView.delegate = self
            
            if descriptionInitialSetup {
                descriptionInitialSetup = false
                descriptionTextView.text = profile?.description ?? ""
            }
            
            cell.selectionStyle = .none
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: value1styleCellID, for: indexPath)
        
        if indexPath.section == 2 {
            cell.textLabel?.text = "Delete profile"
            cell.textLabel?.textColor = .red
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = fieldPosition[indexPath.section][indexPath.row]
        
        if sectionInfo == .deleteAction {
            client.deleteProfile(withId: profile!.id!)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}






extension ProfileEditorViewController {
    
    func checkIfCanProceed() -> Bool {
        let name = nameTextField.text!
        let description = descriptionTextView.text!
        
        var shouldProceed = true
        if name.isEmpty || description.isEmpty {
            shouldProceed = false
        }
        
        saveButton.isEnabled = shouldProceed
        return shouldProceed
    }
    
    @objc func saveButtonTapped(_ button: UIBarButtonItem) {
        let name = nameTextField.text!
        let description = descriptionTextView.text!
        
        if let profile = profile {
            let updatedProfile = Profile(id: profile.id!, name: name, description: description)
            client.replaceProfile(with: updatedProfile)
        } else {
            let newProfile = Profile(name: name, description: description)
            client.create(profile: newProfile)
        }
    }
    
    
    fileprivate func updateTableViewLayout(toFit textView: UITextView) {
        let actualHeight = textView.frame.size.height
        let calculatedHeight = textView.sizeThatFits(textView.frame.size).height  //iOS 8+ only
        
        if actualHeight != calculatedHeight {
            
            UIView.setAnimationsEnabled(false)
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            UIView.setAnimationsEnabled(true)
        }
    }
    
    
}






extension ProfileEditorViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            descriptionTextView.becomeFirstResponder()
        }
        
        return false
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField === nameTextField {
            _ = checkIfCanProceed()
        }
    }
    
    
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView === descriptionTextView {
            
            _ = checkIfCanProceed()
            
            updateTableViewLayout(toFit: textView)
        }
        
    }

}




extension ProfileEditorViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func apiClient(_ client: APIClient, didCreateProfile newProfile: Profile) {
        delegate?.profileEditorViewController(self, didCreateProfile: newProfile)
        self.navigationController?.popViewController(animated: true)
    }
    
    func apiClient(_ client: APIClient, didDeleteProfileWithId profileID: String) {
        delegate?.profileEditorViewController(self, didDeleteProfile: profile!)
        self.navigationController?.popViewController(animated: true)
    }
    
    func apiClient(_ client: APIClient, didUpdateProfile updatedProfile: Profile) {
        delegate?.profileEditorViewController(self, didUpdateProfile: updatedProfile)
        self.navigationController?.popViewController(animated: true)
    }
    
    func apiClient(_ client: APIClient, didRecieveProfile profile: Profile) {
        self.profile = profile
        #warning("Potential crash may happen if the inputs haven't been yet initialized by the table view.")
        nameTextField.text = profile.name
        descriptionTextView.text = profile.description
        updateTableViewLayout(toFit: descriptionTextView)
    }
    
    
}
