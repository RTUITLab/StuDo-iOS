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

fileprivate let userIdFieldName = "id"
fileprivate let firstNameFieldName = "Firstname"
fileprivate let lastNameFieldName = "Surname"
fileprivate let emailFieldName = "Email"
fileprivate let passwordFieldName = "Password"
fileprivate let passwordConfirmFieldName = "PasswordConfirm"
fileprivate let studentCardNumberFieldName = "StudentCardNumber"

extension User {
    var registerDictionaryFormat: [String: String] {
        return [
            firstNameFieldName: firstName,
            lastNameFieldName: lastName,
            emailFieldName: email,
            passwordFieldName: password!,
            passwordConfirmFieldName: password!,
            studentCardNumberFieldName: studentID ?? "" // FIXME: handle somehow null values as well, not it will send an empty string to the server if no card id is specified
        ]
    }
    
    var userDefaultsFormat: [String: String] {
        return [
            userIdFieldName: id ?? "",
            firstNameFieldName: firstName,
            lastNameFieldName: lastName,
            emailFieldName: email,
            studentCardNumberFieldName: studentID ?? ""
        ]
    }
    
    init?(fromUserDefaultsDictionary dictionary: [String: String]) {
        guard let id = dictionary[userIdFieldName],
            let firstName = dictionary[firstNameFieldName],
            let lastName = dictionary[lastNameFieldName],
            let email = dictionary[emailFieldName],
            let studentID = dictionary[studentCardNumberFieldName] else {
                return nil
        }
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.studentID = studentID
        self.password = nil
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



struct Organization {
    
}




struct Ad {
    let id: String
    let name: String
    let description: String?
    let shortDescription: String
    let beginTime: Date
    let endTime: Date
    
    let userName: String?
    let organizationName: String?

    var userId: String?
    let organizationId: String?
    
    let user: User?
    let organization: Organization?
    
    init(id: String, name: String, description: String?, shortDescription: String, beginTime: String, endTime: String, userName: String?, organizationName: String? = nil, user: User? = nil, organization: Organization? = nil, userId: String? = nil, organizationId: String? = nil) {
        self.id = id
        
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        
        self.userName = userName
        self.organizationName = organizationName
        
        self.user = user
        self.userId = userId
        
        self.organizationId = organizationId
        self.organization = organization
        
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        self.beginTime = isoFormatter.date(from: beginTime)!
        self.endTime = isoFormatter.date(from: endTime)!
    }
}

struct AdUpdateForm: Codable {
    let id: String
    let name: String
    let description: String
    let shortDescription: String
    let beginTime: String
    let endTime: String
}




// MARK:- Decoding
extension APIClient {
    func decode(userDictionary dictionary: [String: Any]) throws -> User {
        let idField = "id", firstNameField = "firstname", lastNameField = "surname", emailField = "email", studentIDField = "studentCardNumber"
        
        guard let id = dictionary[idField] as? String else { throw APIError.decodingFailure }
        guard let firstName = dictionary[firstNameField] as? String else { throw APIError.decodingFailure }
        guard let lastName = dictionary[lastNameField] as? String else { throw APIError.decodingFailure }
        guard let email = dictionary[emailField] as? String else { throw APIError.decodingFailure }
        let studentID = dictionary[studentIDField] as? String
        
        return User(id: id, firstName: firstName, lastName: lastName, email: email, studentID: studentID, password: nil)
    }
    
    
    
    
    func decodeAd(from object: [String: Any], fullDecode: Bool = false) throws -> Ad {
        let idField = "id"
        guard let id = object[idField] as? String else {
            throw APIError.decodingFailureWithField(idField)
        }
        
        let nameField = "name"
        guard let name = object[nameField] as? String else {
            throw APIError.decodingFailureWithField(nameField)
        }
        
        let shortDescriptionField = "shortDescription"
        guard let shortDescription = object[shortDescriptionField] as? String else {
            throw APIError.decodingFailureWithField(shortDescriptionField)
        }
        
        
        
        let beginTimeField = "beginTime"
        guard let beginTime = object[beginTimeField] as? String else {
            throw APIError.decodingFailureWithField(beginTimeField)
        }
        
        let endTimeField = "endTime"
        guard let endTime = object[endTimeField] as? String else {
            throw APIError.decodingFailureWithField(endTimeField)
        }
        
        
        if fullDecode == false {
            let userNameField = "userName"
            guard let userName = object[userNameField] as? String else {
                throw APIError.decodingFailureWithField(userNameField)
            }
            
            let organizationNameField = "organizationName"
            let organizationName = object[organizationNameField] as? String
            
            
            return Ad(id: id, name: name, description: nil, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime, userName: userName, organizationName: organizationName, user: nil)
        }
        
        
        
        
        
        
        // === === === === ===
        // === Full decode ===
        
        let organizationIdField = "organizationId"
        let organizationId = object[organizationIdField] as? String
        
        
        let organizationField = "organization"
        let organizationDictionary = object[organizationField] as? [String: Any]
        
        let organization: Organization? = nil
        
        
        
        
        let userIdField = "userId"
        guard let userId = object[userIdField] as? String? else {
            throw APIError.decodingFailureWithField(userIdField)
        }
        
        let userField = "user"
        guard let userDictionary = object[userField] as? [String: Any] else {
            throw APIError.decodingFailureWithField(userField)
        }
        
        let user = try decode(userDictionary: userDictionary)
        
        
        
        
        let descriptionField = "description"
        guard let description = object[descriptionField] as? String else {
            throw APIError.decodingFailureWithField(descriptionField)
        }
        
        return Ad(id: id, name: name, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime, userName: nil, organizationName: nil, user: user, organization: organization, userId: userId, organizationId: organizationId)
        
    }
}
