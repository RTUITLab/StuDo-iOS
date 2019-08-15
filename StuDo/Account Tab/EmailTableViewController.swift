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
    
    var emailTextField: UITextField!
    var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: textFieldCellId)

        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped(_:)))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "We'll send you a confirmation link."
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "New email address"
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
        // Save the new email address
        let alertController = UIAlertController(title: "Alert", message: "Email change is not yet implemented in the app.", preferredStyle: .alert)
        
        let OkButton = UIAlertAction(title: "OK", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(OkButton)
        
        self.present(alertController, animated: true, completion: nil)
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
