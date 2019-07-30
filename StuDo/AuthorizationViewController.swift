//
//  AuthorizationViewController.swift
//  StuDo
//
//  Created by Вячеслав Клевлеев on 15/06/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    @IBOutlet weak var firstName_textField: UITextField!
    @IBOutlet weak var lastName_textField: UITextField!
    @IBOutlet weak var login_textField: UITextField!
    @IBOutlet weak var password_textField: UITextField!
    @IBOutlet weak var check_password_textField: UITextField!
    @IBOutlet weak var ready_button: UIButton!
    @IBOutlet weak var segmented_control: UISegmentedControl!
    
    var client = APIClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        client.delegate = self
        
        self.HideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height * 0.25
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    fileprivate func clear_textFields() {
        firstName_textField.text = ""
        lastName_textField.text = ""
        login_textField.text = ""
        password_textField.text = ""
        check_password_textField.text = ""
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmented_control.selectedSegmentIndex {
        case 0:
            firstName_textField.isHidden = false
            lastName_textField.isHidden = false
            check_password_textField.isHidden = false
            
            clear_textFields()
            
            break
        case 1:
            firstName_textField.isHidden = true
            lastName_textField.isHidden = true
            check_password_textField.isHidden = true
            
            clear_textFields()
            break
        default:
            break
        }
        
        self.DissmissKeyboard()
    }
    
    
    @IBAction func ready_button_clicked(_ sender: Any) {
        self.DissmissKeyboard()
        
        let login = login_textField.text
        let pass = password_textField.text
        let pass_2 = check_password_textField.text
        let firstName = firstName_textField.text
        let lastName = lastName_textField.text
        
        switch segmented_control.selectedSegmentIndex {
        case 0:
            if login == "" || pass == "" || pass_2 == "" || firstName == "" || lastName == "" {
                displayMessage(userMessage: "Заполнены не все поля")
                return
            }
            if pass != pass_2 {
                displayMessage(userMessage: "Пароли не совпадают")
                return
            }
            let user = User(id: nil, firstName: firstName!, lastName: lastName!, email: login!, studentID: nil, password: pass!)
            client.register(user: user)
            break
        case 1:
            if login == "" || pass == "" {
                displayMessage(userMessage: "Заполнены не все поля")
                return
            }
            client.login(withCredentials: Credentials(email: login!, password: pass!))
            break
        default:
            break
        }
        
    }
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            let OkButton = UIAlertAction(title: "Ok", style: .default)
            {
                (action:UIAlertAction!) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            alertController.addAction(OkButton)
        }
    }
}

extension AuthorizationViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        displayMessage(userMessage: error.localizedDescription)
    }
    
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User) {
        
        PersistentStore.shared.user = user
        PersistentStore.save()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.tabBarController.refreshDataInsideControllers()
        }
        
        dismiss(animated: true, completion: nil)
    }
    func apiClient(_ client: APIClient, didFinishRegistrationRequest request: APIRequest, andRecievedUser user: User) {
        client.login(withCredentials: Credentials(email: user.email, password: user.password!))
    }
}


extension AuthorizationViewController {
    func HideKeyboard() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DissmissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func DissmissKeyboard() {
        view.endEditing(true)
    }
}
