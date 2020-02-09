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



struct Organization: Encodable {
    let id: String!
    let name: String
    let description: String
    let creatorId: String!
    let creator: User?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if id != nil {
            try container.encode(id, forKey: .id)
        }
        
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        
    }
}


extension Organization {
    init(id: String?, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
        
        self.creatorId = nil
        self.creator = nil
    }
}





struct OrganizationMember {
    let user: User
    let rights: [OrganizationMemberRight]
}

enum OrganizationMemberRight: String {
    case canEditMembers = "CanEditMembers"
    case canEditRights = "CanEditRights"
    case canEditAd = "CanEditAd"
    case canEditOrganizationInformation = "CanEditOrganizationInformation"
    case canDeleteOrganization = "CanDeleteOrganization"
    case member = "Member"
}



struct Ad {
    let id: String!
    let name: String
    let description: String?
    let shortDescription: String
    let beginTime: Date
    let endTime: Date
    
    let userName: String?
    let organizationName: String?

    let userId: String?
    let organizationId: String?
    
    let user: User?
    let organization: Organization?
    
    let comments: [Comment]?
    
    
    // initializer for ad creation and update
    init(id: String?, name: String, description: String, shortDescription: String, beginTime: Date, endTime: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        self.beginTime = beginTime
        self.endTime = endTime
        
        self.userName = nil
        self.organizationName = nil
        self.user = nil
        self.userId = nil
        self.organizationId = nil
        self.organization = nil
        self.comments = nil
    }
    
    init(organizationId: String, name: String, description: String, shortDescription: String, beginTime: Date, endTime: Date) {
        self.organizationId = organizationId
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
        self.beginTime = beginTime
        self.endTime = endTime
        
        self.id = nil
        self.userName = nil
        self.organizationName = nil
        self.user = nil
        self.userId = nil
        self.organization = nil
        self.comments = nil
    }
    
    // initializer for ads fetched from the server
    init(id: String, name: String, description: String?, shortDescription: String, beginTime: String, endTime: String, userName: String?, organizationName: String? = nil, user: User? = nil, organization: Organization? = nil, userId: String? = nil, organizationId: String? = nil, comments: [Comment]?) {
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
        
        
        self.beginTime = DateFormatter.dateFromISO8601String(beginTime)
        self.endTime = DateFormatter.dateFromISO8601String(endTime)
        
        self.comments = comments
    }
    
}


extension Ad {
    var creatorName: String {
        var creator: String!
        if let userName = self.userName {
            creator = userName
        } else if let organizationName = self.organizationName {
            creator = organizationName
        } else if let user = self.user {
            creator = user.firstName + " " + user.lastName
        } else if let organization = self.organization {
            creator = organization.name
        }
        return creator
    }
    
    var dateRange: String {
        let calendar = Calendar.current
        
        let intervalFormatter = DateIntervalFormatter()
        intervalFormatter.locale = Localizer.currentLocale
        
        var dateString = ""
        if calendar.isDate(beginTime, inSameDayAs: endTime) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Localizer.currentLocale
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            
            dateString = dateFormatter.string(from: beginTime) + " "
            
            intervalFormatter.dateStyle = .none
            intervalFormatter.timeStyle = .short
        } else {
            intervalFormatter.dateStyle = .medium
            intervalFormatter.timeStyle = .none
        }
        
        let dateRangeString = dateString + intervalFormatter.string(from: beginTime, to: endTime)
        return dateRangeString.replacingOccurrences(of: "—", with: " – ")
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

struct AdCreateForm: Codable {
    let name: String
    let description: String
    let shortDescription: String
    let beginTime: String
    let endTime: String
    let organizationId: String?
}



struct Comment {
    let id: String!
    let text: String
    let commentTime: Date!
    let authorId: String!
    let author: String!
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case commentTime
        case authorId
        case author
    }
}

extension Comment: Equatable {}

extension Comment: Encodable {
    init(text: String) {
        self.text = text
        
        self.id = nil
        self.commentTime = nil
        self.authorId = nil
        self.author = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if id != nil {
            try container.encode(id, forKey: .id)
        }
        
        try container.encode(text, forKey: .text)
    }
}




struct Profile: Decodable {
    let id: String?
    let name: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
    }
    
    init(id: String, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}

extension Profile: Encodable {
    
    init(name: String, description: String) {
        self.id = nil
        self.name = name
        self.description = description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let id = id {
            try container.encode(id, forKey: .id)
        }

        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
    }
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
        
        
        
        let userIdField = "userId"
        let userId = object[userIdField] as? String
        
        let organizationIdField = "organizationId"
        let organizationId = object[organizationIdField] as? String
        
        
        if fullDecode == false {
            let userNameField = "userName"
            let userName = object[userNameField] as? String
            
            let organizationNameField = "organizationName"
            let organizationName = object[organizationNameField] as? String
            
            
            return Ad(id: id, name: name, description: nil, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime, userName: userName, organizationName: organizationName, user: nil, organization: nil, userId: userId, organizationId: organizationId, comments: nil)
        }
        
        
        
        
        
        
        // === === === === ===
        // === Full decode ===
        
        
        var organization: Organization?
        
        let organizationField = "organization"
        if let organizationDictionary = object[organizationField] as? [String: Any] {
            organization = try decodeOrganization(from: organizationDictionary)
        }
        
        
        
        
        
        var user: User?
        
        let userField = "user"
        if let userDictionary = object[userField] as? [String: Any] {
            user = try decode(userDictionary: userDictionary)
        }
        

        
        
        
        let descriptionField = "description"
        guard let description = object[descriptionField] as? String else {
            throw APIError.decodingFailureWithField(descriptionField)
        }
        
        let commentsField = "comments"
        guard let commentsObject = object[commentsField] as? [[String: Any]] else {
            throw APIError.decodingFailureWithField(commentsField)
        }
        
        var comments = [Comment]()
        for object in commentsObject {
            let comment = try decodeComment(from: object)
            comments.append(comment)
        }
        
        return Ad(id: id, name: name, description: description, shortDescription: shortDescription, beginTime: beginTime, endTime: endTime, userName: nil, organizationName: nil, user: user, organization: organization, userId: userId, organizationId: organizationId, comments: comments)
        
    }
    
    
    
    
    func decodeProfile(from object: [String: Any]) throws ->  Profile  {
        
        let idField = "id"
        guard let id = object[idField] as? String else {
            throw APIError.decodingFailureWithField(idField)
        }
        
        let nameField = "name"
        guard let name = object[nameField] as? String else {
            throw APIError.decodingFailureWithField(nameField)
        }
        
        let descriptionField = "description"
        guard let description = object[descriptionField] as? String else {
            throw APIError.decodingFailureWithField(descriptionField)
        }
        
        return Profile(id: id, name: name, description: description)
    }
    
    
    
    
    func decodeOrganization(from object: [String: Any], fullDecode: Bool = false) throws -> Organization {
        
        let idField = "id"
        guard let id = object[idField] as? String else {
            throw APIError.decodingFailureWithField(idField)
        }
        
        let nameField = "name"
        guard let name = object[nameField] as? String else {
            throw APIError.decodingFailureWithField(nameField)
        }
        
        let descriptionField = "description"
        guard let description = object[descriptionField] as? String else {
            throw APIError.decodingFailureWithField(descriptionField)
        }
        
        let creatorIdField = "creatorId"
        guard let creatorId = object[creatorIdField] as? String else {
            throw APIError.decodingFailureWithField(creatorIdField)
        }
        
        
        if fullDecode {
            let descriptionField = "creator"
            guard let creatorDictionary = object[descriptionField] as? [String: Any] else {
                throw APIError.decodingFailureWithField(descriptionField)
            }
            
            let creator = try self.decode(userDictionary: creatorDictionary)
            
            return Organization(id: id, name: name, description: description, creatorId: creatorId, creator: creator)
        } else {
            return Organization(id: id, name: name, description: description, creatorId: creatorId, creator: nil)
        }
        
    }
    
    
    func decodeOrganizationMember(from object: [String: Any], fullDecode: Bool = false) throws -> OrganizationMember {
        
        let userField = "user"
        guard let userDictionary = object[userField] as? [String: Any] else {
            throw APIError.decodingFailureWithField(userField)
        }
        
        let user = try self.decode(userDictionary: userDictionary)
        
        let organizationRightsField = "organizationRights"
        guard let organizationRightsArray = object[organizationRightsField] as? [[String: String]] else {
            throw APIError.decodingFailureWithField(organizationRightsField)
        }
        
        var userRights = [OrganizationMemberRight]()
        for right in organizationRightsArray {
            let rightNameField = "rightName"
            guard let rightName = right[rightNameField] else {
                throw APIError.decodingFailureWithField(rightNameField)
            }
            guard let rightValue = OrganizationMemberRight.init(rawValue: rightName) else {
                throw APIError.decodingFailureWithFieldAndValue(rightNameField, rightName)
            }
            userRights.append(rightValue)
        }
        
        return OrganizationMember(user: user, rights: userRights)
        
    }
    
    
    func decodeComment(from object: [String: Any]) throws -> Comment {
        
        let idField = "id"
        guard let id = object[idField] as? String else {
            throw APIError.decodingFailureWithField(idField)
        }
        
        let textField = "text"
        guard let text = object[textField] as? String else {
            throw APIError.decodingFailureWithField(textField)
        }
        
        let commentTimeField = "commentTime"
        guard let commentTimeString = object[commentTimeField] as? String else {
            throw APIError.decodingFailureWithField(commentTimeField)
        }
        
        let commentTime = DateFormatter.dateFromISO8601String(commentTimeString)
        
        let authorIdField = "authorId"
        guard let authorId = object[authorIdField] as? String else {
            throw APIError.decodingFailureWithField(authorIdField)
        }
        
        let authorField = "author"
        guard let author = object[authorField] as? String else {
            throw APIError.decodingFailureWithField(authorField)
        }
        
        return Comment(id: id, text: text, commentTime: commentTime, authorId: authorId, author: author)
        
    }
    
    
    
    
}
