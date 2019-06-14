//
//  DataManager.swift
//  StuDo
//
//  Created by Andrew on 6/2/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

// MARK:- Models

struct User {
    let id: String?
    let firstName: String
    let lastName: String
    let email: String
    let studentID: String?
    let password: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "firstname"
        case lastName = "surname"
        case email
        case studentID = "studentCardNumber"
        case password
    }
}

extension User: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(studentID, forKey: .studentID)
        try container.encode(password, forKey: .password)
        
    }
}

extension User: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try values.decode(String?.self, forKey: .id)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.email = try values.decode(String.self, forKey: .email)
        self.studentID = try values.decode(String?.self, forKey: .studentID)
        self.password = nil
    }
}




struct Credentials: Codable {
    let email: String
    let password: String
    enum CodingKeys: String, CodingKey {
        case email = "Email"
        case password = "Password"
    }
}





// MARK:- Decoding
extension APIClient {
    func decode(userDictionary dictionary: [String: Any]) throws -> User {
        guard let id = dictionary["id"] as? String else { throw APIError.decodingFailure }
        guard let firstName = dictionary["firstname"] as? String else { throw APIError.decodingFailure }
        guard let lastName = dictionary["surname"] as? String else { throw APIError.decodingFailure }
        guard let email = dictionary["email"] as? String else { throw APIError.decodingFailure }
        let studentID = dictionary["studentCardNumber"] as? String
        
        return User(id: id, firstName: firstName, lastName: lastName, email: email, studentID: studentID, password: nil)
    }
}
