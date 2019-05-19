//
//  SignInUserViewController.swift
//  StuDo
//
//  Created by Вячеслав Клевлеев on 19/05/2019.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class SignInUserViewController: UIViewController {

    @IBOutlet weak var LoginTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func SignInButtonTapped(_ sender: Any) {
        print("Тап")
        
        let login = LoginTextField.text
        let pass = PasswordTextField.text
        
        if (login?.isEmpty)! || (pass?.isEmpty)! {
            print("User name \(String(describing: login)) or password \(String(describing: pass)) is empty")
            
            displayMessage(userMessage: "Одно из полей не заполнено")
            
            //Place for http request
            
            return
        }
        
            if (login == "test@test.com") && (pass == "Qwer") {
                let accountPage = self.storyboard?.instantiateViewController(withIdentifier: "AccountPageViewController")
                let appDelegate = UIApplication.shared.delegate
                appDelegate?.window??.rootViewController = accountPage
            } else {
                displayMessage(userMessage: "Ошибка! Неправильный логин или пароль")
            }
        
    }
    
    func displayMessage(userMessage:String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            let OkButton = UIAlertAction(title: "Ok", style: .default)
            {
                (action:UIAlertAction!) in
                print("Ok tap")
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            alertController.addAction(OkButton)
            self.present(alertController, animated: true, completion: nil)
            
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
