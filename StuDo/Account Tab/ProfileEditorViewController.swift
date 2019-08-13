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

class ProfileEditorViewController: UITableViewController {
    
    var profile: Profile?
    let client = APIClient()
    
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
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped(_:)))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    init(profile: Profile?) {
        super.init(style: .grouped)
        
        client.delegate = self
        if let profile = profile {
            shouldAllowDeletion = true
            shouldBecomeFirstResponder = false
            
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
            return "Brief name for your profile."
        } else if section == 1 {
            return "Describe shortly how you can help others."
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile name"
        } else if section == 1 {
            return "Profile description"
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
            nameTextField.placeholder = "Name"
            nameTextField.autocapitalizationType = .sentences
            nameTextField.returnKeyType = .next
            nameTextField.clearButtonMode = .whileEditing
            
            
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
    
    
    fileprivate func displayAlert(title: String) {
        
        nameTextField.endEditing(true)
        descriptionTextView.endEditing(true)
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        let OkButton = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OkButton)
        
        self.present(alertController, animated: true, completion: nil)
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
        displayAlert(title: "Profile Created!")
    }
    
    func apiClient(_ client: APIClient, didDeleteProfileWithId profileID: String) {
        displayAlert(title: "Profile Deleted!")
    }
    
    func apiClient(_ client: APIClient, didUpdateProfile updatedProfile: Profile) {
        displayAlert(title: "Profile Updated!")
    }
    
    func apiClient(_ client: APIClient, didRecieveProfile profile: Profile) {
        self.profile = profile
        #warning("Potential crash may happen if the inputs haven't been yet initialized by the table view.")
        nameTextField.text = profile.name
        descriptionTextView.text = profile.description
        updateTableViewLayout(toFit: descriptionTextView)
    }
    
    
}
