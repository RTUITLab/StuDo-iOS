//
//  AccountDetailViewController.swift
//  StuDo
//
//  Created by Andrew on 6/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let usualStyleCellId = "usualStyleCellId"
fileprivate let currentUserCellId = "currentUserCellId"
fileprivate let value1styleCellID = "value1styleCellID"
fileprivate let inputFieldCellID = "inputFieldCellID"

fileprivate let usualStyleHeaderFooterId = "usualStyleHeaderFooterId"

class AccountDetailViewController: UITableViewController {
    
    weak var accountViewController: AccountViewController!
    
    let client = APIClient()
    
    fileprivate enum SectionName: String {
        case nameAndSurname
        case studentId
        case credentials
        case logout
    }
    
    fileprivate enum TagsForTextField: Int {
        case name
        case surname
        case studentID
    }
    
    var editedName: String?
    var editedLastName: String?
    var editedStudentID: String?
    
    var nameTextField: UITextField!
    var surnameTextField: UITextField!
    var studentIdTextField: UITextField!
    
    private var sections: [SectionName] = [.nameAndSurname, .studentId, .credentials, .logout]
    
    var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        tabBarController?.hideTabBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: usualStyleCellId)
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: currentUserCellId)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: value1styleCellID)
        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: inputFieldCellID)
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: usualStyleHeaderFooterId)
        
        doneButton = UIBarButtonItem(title: Localizer.string(for: .done), style: .done, target: self, action: #selector(doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
        
        tableView.keyboardDismissMode = .interactive
        
        title = Localizer.string(for: .back)
        navigationItem.titleView = UIView()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabBarController?.hideTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    fileprivate func changeUserInfo() {
        let currentUser = PersistentStore.shared.user!
        
        client.changeUserInfo(to: (firstName: editedName ?? currentUser.firstName, lastName: editedLastName ?? currentUser.lastName, studentID: editedStudentID ?? currentUser.studentID ?? ""))
        RootViewController.startLoadingIndicator()
    }
    
    @objc func doneButtonPressed(_ doneButton: UIBarButtonItem) {
        changeUserInfo()
    }
    
    
    @objc func valueChanged(in textField: UITextField) {
        if textField.tag == TagsForTextField.name.rawValue {
            editedName = textField.text
        } else if textField.tag == TagsForTextField.surname.rawValue {
            editedLastName = textField.text
        } else if textField.tag == TagsForTextField.studentID.rawValue {
            editedStudentID = textField.text
        }
        
        // Check the entered data
        if editedName != nil && editedName!.count == 0 {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionInfo = sections[section]
        
        switch sectionInfo {
        case .nameAndSurname:
            return Localizer.string(for: .accountDetailNameSectionDescription)
        case .studentId:
            return Localizer.string(for: .accountDetailStudentID) + "."
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = sections[section]
        
        if sectionInfo == .credentials {
            return 2
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .nameAndSurname {
            let cell = tableView.dequeueReusableCell(withIdentifier: currentUserCellId, for: indexPath) as! CurrentUserTableViewCell
            
            let currentUser = PersistentStore.shared.user!
            cell.generateProfileImage(for: currentUser)
            cell.isEditingAlailable = true
            cell.nameField.text = currentUser.firstName
            cell.surnameField.text = currentUser.lastName
            cell.setupCell()
            cell.selectionStyle = .none
            
            cell.nameField.tag = TagsForTextField.name.rawValue
            cell.surnameField.tag = TagsForTextField.surname.rawValue
            cell.nameField.addTarget(self, action: #selector(valueChanged(in:)), for: .editingChanged)
            cell.surnameField.addTarget(self, action: #selector(valueChanged(in:)), for: .editingChanged)
            
            cell.nameField.delegate = self
            cell.nameField.returnKeyType = .next
            cell.nameField.autocorrectionType = .no
            nameTextField = cell.nameField
            
            cell.surnameField.delegate = self
            cell.surnameField.returnKeyType = .next
            cell.surnameField.autocorrectionType = .no
            surnameTextField = cell.surnameField

            return cell
        } else if sectionInfo == .studentId {
            let cell = tableView.dequeueReusableCell(withIdentifier: inputFieldCellID, for: indexPath) as! TableViewCellWithInputField
            cell.inputField.placeholder = "18И0513"
            
            cell.inputField.tag = TagsForTextField.studentID.rawValue
            cell.inputField.addTarget(self, action: #selector(valueChanged(in:)), for: .editingChanged)
            
            cell.inputField.clearButtonMode = .whileEditing
            cell.inputField.delegate = self
            cell.inputField.returnKeyType = .done
            studentIdTextField = cell.inputField
            
            let currentUser = PersistentStore.shared.user!
            studentIdTextField.text = currentUser.studentID

            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: value1styleCellID, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        switch sectionInfo {
        case .logout:
            cell.textLabel?.text = Localizer.string(for: .accountDetailLogout)
            if #available(iOS 13, *) {
                cell.textLabel?.textColor = .systemRed
            } else {
                cell.textLabel?.textColor = .red
            }
        case .credentials:
            if indexPath.row == 0 {
                cell.textLabel?.text = Localizer.string(for: .accountDetailEmail)
                cell.detailTextLabel?.text = PersistentStore.shared.user!.email
            } else {
                cell.textLabel?.text = Localizer.string(for: .accountDetailPassword)
            }
        default:
            break
        }
        
        return cell
    }
    
    fileprivate func presentCredentialsDetailVC(_ indexPath: IndexPath) {
        if indexPath.row == 0 {
            let emailVC = EmailTableViewController(style: .grouped)
            navigationController?.pushViewController(emailVC, animated: true)
        } else if indexPath.row == 1 {
            let passwordVC = PasswordTableViewController(style: .grouped)
            navigationController?.pushViewController(passwordVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let sectionInfo = sections[indexPath.section]
        if sectionInfo == .studentId {
            studentIdTextField.becomeFirstResponder()
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .logout {
            RootViewController.main.logout()
        } else if sectionInfo == .credentials {
            
            // if there're unsaved changes
            if doneButton.isEnabled {
                let alert = UIAlertController(title: nil, message: Localizer.string(for: .accountDetailChangeAlertMessage), preferredStyle: .alert)
                
                let saveAction = UIAlertAction(title: Localizer.string(for: .save), style: .default) { _ in
                    self.changeUserInfo()
                    
                    self.presentCredentialsDetailVC(indexPath)
                }
                
                let cancelAction = UIAlertAction(title: Localizer.string(for: .accountDetailChangeAlertCancel), style: .cancel) { _ in
                    let currentUser = PersistentStore.shared.user!
                    self.nameTextField.text = currentUser.firstName
                    self.surnameTextField.text = currentUser.lastName
                    self.studentIdTextField.text = currentUser.studentID
                    
                    self.presentCredentialsDetailVC(indexPath)
                }
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                alert.preferredAction = saveAction
                present(alert, animated: true, completion: nil)
            } else {
                presentCredentialsDetailVC(indexPath)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionInfo = sections[section]
        
        if sectionInfo == .nameAndSurname {
            return 0
        }
        return UITableView.automaticDimension
    }

}




extension AccountDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == TagsForTextField.name.rawValue {
            surnameTextField.becomeFirstResponder()
        } else if textField.tag == TagsForTextField.surname.rawValue {
            studentIdTextField.becomeFirstResponder()
        } else if textField.tag == TagsForTextField.studentID.rawValue {
            textField.resignFirstResponder()
        }
        
        return false
    }
}






extension AccountDetailViewController: APIClientDelegate {
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        RootViewController.stopLoadingIndicator(with: .fail)
        doneButton.isEnabled = true
    }
    
    func apiClient(_ client: APIClient, didChangeUserInfo newUserInfo: (firstName: String, lastName: String, studentID: String)) {
        let cUser = PersistentStore.shared.user! // currentUser
        PersistentStore.shared.user = User(id: cUser.id, firstName: newUserInfo.firstName, lastName: newUserInfo.lastName, email: cUser.email, studentID: newUserInfo.studentID, password: nil)
        NotificationCenter.default.post(name: AppDelegateNotification.forceDataUpdate.name, object: nil)
        
        RootViewController.stopLoadingIndicator(with: .success) {
            if self.navigationController?.visibleViewController === self {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        doneButton.isEnabled = false
        
        accountViewController.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)

    }
}
