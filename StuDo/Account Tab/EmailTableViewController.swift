//
//  EmailTableViewController.swift
//  StuDo
//
//  Created by Andrew on 8/9/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let textFieldCellId = "textFieldCellId"

class EmailTableViewController: UITableViewController, UITextFieldDelegate {
    
    let client = APIClient()
    
    var emailTextField: UITextField!
    var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: textFieldCellId)

        doneButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: #selector(doneButtonTapped(_:)))

        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
        
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return Localizer.string(for: .emailChangeSectionDescription)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Localizer.string(for: .emailChangeSectionHeader)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellId, for: indexPath) as! TableViewCellWithInputField
        
        emailTextField = cell.inputField
        emailTextField.placeholder = "example@mail.com"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.returnKeyType = .done
        emailTextField.clearButtonMode = .whileEditing
        emailTextField.autocorrectionType = .no
        
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.becomeFirstResponder()
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func changeEmail() {
        client.changeEmail(to: emailTextField.text!)
        RootViewController.startLoadingIndicator()
    }
    
    
    @objc func doneButtonTapped(_ button: UIBarButtonItem) {
        changeEmail()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField === emailTextField {
            doneButton.isEnabled = DataChecker.shared.isEmailValid(emailTextField.text!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField && doneButton.isEnabled {
            changeEmail()
        }
        
        return false
    }

}




extension EmailTableViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error.localizedDescription)
        RootViewController.stopLoadingIndicator(with: .fail)
    }
    
    func apiClient(_ client: APIClient, didChangeEmailWithRequest: APIRequest) {
        
        RootViewController.stopLoadingIndicator(with: .success) {
            let alertController = UIAlertController(title: nil, message: Localizer.string(for: .emailChangeAlertMessage), preferredStyle: .alert)
            
            let OkButton = UIAlertAction(title: Localizer.string(for: .okay), style: .cancel) { _ in
            }
            alertController.addAction(OkButton)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
}
