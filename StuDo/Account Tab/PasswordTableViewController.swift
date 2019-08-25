//
//  PasswordTableViewController.swift
//  StuDo
//
//  Created by Andrew on 8/9/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let textFieldCellId = "textFieldCellId"

class PasswordTableViewController: UITableViewController, UITextFieldDelegate {
    
    let client = APIClient()
    
    private enum FieldType {
        case oldPassword
        case newPassword
        case checkPassword
    }
    private let fieldPosition: [[FieldType]] = [[.oldPassword],[.newPassword, .checkPassword]]
    
    var oldPasswordTextField: UITextField!
    var newPasswordTextField: UITextField!
    var checkPasswordTextField: UITextField!
    
    var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: textFieldCellId)
        
        doneButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: #selector(doneButtonTapped(_:)))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle: String?
        if section == 0 {
            headerTitle = Localizer.string(for: .passwordCurrentSectionHeader)
        } else if section == 1 {
            headerTitle = Localizer.string(for: .passwordNewSectionHeader)
        }
        
        return headerTitle
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerTitle: String?
        if section == 1 {
            footerTitle = Localizer.string(for: .passwordNewSectionDescription)
        }
        
        return footerTitle
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fieldPosition.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldPosition[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellId, for: indexPath) as! TableViewCellWithInputField
        
        let fieldInfo = fieldPosition[indexPath.section][indexPath.row]
        
        switch fieldInfo {
        case .oldPassword:
            
            oldPasswordTextField = cell.inputField
            oldPasswordTextField.placeholder = Localizer.string(for: .passwordEnterCurrent)
            oldPasswordTextField.returnKeyType = .next
            
            oldPasswordTextField.becomeFirstResponder()
            
        case .newPassword:
            
            newPasswordTextField = cell.inputField
            newPasswordTextField.placeholder = Localizer.string(for: .passwordEnterNew)
            newPasswordTextField.returnKeyType = .next
            
        case .checkPassword:
            
            checkPasswordTextField = cell.inputField
            checkPasswordTextField.placeholder = Localizer.string(for: .passwordRepeatNew)
            checkPasswordTextField.returnKeyType = .done
        }
        
        cell.inputField.clearButtonMode = .whileEditing
        cell.inputField.isSecureTextEntry = true
        cell.inputField.textContentType = .password
        cell.inputField.autocorrectionType = .no
        cell.inputField.keyboardType = .asciiCapable
        
        cell.inputField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        cell.inputField.delegate = self
        
        cell.selectionStyle = .none

        return cell
    }
    
    
    func checkIfCanProceed() -> Bool {
        let oldPassword = oldPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        let checkPassword = checkPasswordTextField.text!
        
        var shouldProceed = true
        
        if oldPassword.isEmpty || newPassword.isEmpty || checkPassword.isEmpty {
            shouldProceed = false
        } else if !DataChecker.shared.isPasswordValid(newPassword) {
            shouldProceed = false
        } else if newPassword != checkPassword {
            shouldProceed = false
        }
        
        
        doneButton.isEnabled = shouldProceed
        return shouldProceed
    }
    
    func changePassword() {
        let oldPassword = oldPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        
        client.changePassword(from: oldPassword, to: newPassword)
    }
    
    
    @objc func doneButtonTapped(_ button: UIBarButtonItem) {
        changePassword()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        _ = checkIfCanProceed()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === oldPasswordTextField {
            newPasswordTextField.becomeFirstResponder()
        } else if textField === newPasswordTextField {
            checkPasswordTextField.becomeFirstResponder()
        } else if textField === checkPasswordTextField {
            if doneButton.isEnabled {
                changePassword()
            }
        }
        return false
    }
    
}



extension PasswordTableViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func apiClient(_ client: APIClient, didChangePasswordWithRequest: APIRequest) {
        let alertController = UIAlertController(title: Localizer.string(for: .passwordChangeAlertTitle), message: Localizer.string(for: .passwordChangeAlertMessage), preferredStyle: .alert)
        
        let OkButton = UIAlertAction(title: Localizer.string(for: .okay), style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OkButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
