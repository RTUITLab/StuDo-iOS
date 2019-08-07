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
    
    private var sections: [SectionName] = [.nameAndSurname, .studentId, .credentials, .logout]
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: usualStyleCellId)
        tableView.register(CurrentUserTableViewCell.self, forCellReuseIdentifier: currentUserCellId)
        tableView.register(TableViewCellValue1Style.self, forCellReuseIdentifier: value1styleCellID)
        tableView.register(TableViewCellWithInputField.self, forCellReuseIdentifier: inputFieldCellID)
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: usualStyleHeaderFooterId)
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
        
        tableView.keyboardDismissMode = .interactive
    }
    
    @objc func doneButtonPressed(_ doneButton: UIBarButtonItem) {
        
        // TODO: Send the edited data to server here
        
        navigationController?.popViewController(animated: true)
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
            return "Edit your name and surname."
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
            cell.profileImage.image = #imageLiteral(resourceName: "person")
            cell.isEditingAlailable = true
            cell.nameField.text = PersistentStore.shared.user.firstName
            cell.surnameField.text = PersistentStore.shared.user.lastName
            cell.setupCell()
            cell.selectionStyle = .none
            
            cell.nameField.tag = TagsForTextField.name.rawValue
            cell.surnameField.tag = TagsForTextField.surname.rawValue
            cell.nameField.addTarget(self, action: #selector(valueChanged(in:)), for: .editingChanged)
            cell.surnameField.addTarget(self, action: #selector(valueChanged(in:)), for: .editingChanged)

            return cell
        } else if sectionInfo == .studentId {
            let cell = tableView.dequeueReusableCell(withIdentifier: inputFieldCellID, for: indexPath) as! TableViewCellWithInputField
            cell.inputField.placeholder = "Your student ID"
            
            cell.inputField.tag = TagsForTextField.studentID.rawValue
            cell.inputField.addTarget(self, action: #selector(valueChanged(in:)), for: .editingChanged)

            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: value1styleCellID, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        switch sectionInfo {
        case .logout:
            cell.textLabel?.text = "Log out"
            cell.textLabel?.textColor = .red
        case .credentials:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Change email"
                cell.detailTextLabel?.text = PersistentStore.shared.user!.email
            } else {
                cell.textLabel?.text = "Change password"
            }
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionInfo = sections[indexPath.section]
        
        if sectionInfo == .logout {
            PersistentStore.shared.user = nil
            
            if !GCIsUsingFakeData {
                PersistentStore.save()
            }
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                dismiss(animated: true) {
                    appDelegate.presentInitialController(shouldAnimate: true)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionInfo = sections[indexPath.section]
        
        switch sectionInfo {
        case .nameAndSurname:
            return UITableView.automaticDimension
        default:
            return 46
        }
    }

}
