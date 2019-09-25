//
//  DataChecker.swift
//  StuDo
//
//  Created by Andrew on 8/9/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class DataChecker: NSObject {
    static let shared = DataChecker()
    
    func isEmailValid(_ email: String) -> Bool {
        guard !email.isEmpty else { return false }
        
        let range = NSRange(location: 0, length: email.utf16.count)
        let regex = try! NSRegularExpression(pattern: #".+@.+\..{2,}"#)
        if regex.firstMatch(in: email, options: [], range: range) == nil {
            return false
        }
        
        return true
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        if password.isEmpty || password.count < 6 {
            return false
        }
        
        return true
    }
}
