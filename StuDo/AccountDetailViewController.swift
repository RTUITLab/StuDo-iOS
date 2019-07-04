//
//  AccountDetailViewController.swift
//  StuDo
//
//  Created by Andrew on 6/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AccountDetailViewController: UIViewController {
    
    let firstNameTextField = UITextField()
    let logoutButton = UIButton()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(firstNameTextField)
        
        
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logoutButton.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        logoutButton.setTitle("Log out", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed(_:)), for: .touchUpInside)
    }
    
    @objc func logoutButtonPressed(_ button: UIButton) {
        PersistentStore.shared.user = nil
        PersistentStore.save()
        
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        
        let authVC = storyboard.instantiateViewController(withIdentifier: "CustomViewController")
        
        self.present(authVC, animated: true, completion: nil)
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
