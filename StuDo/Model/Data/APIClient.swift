//
//  APIClient.swift
//  StuDo
//
//  Created by Andrew on 5/31/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import JWTDecode


// MARK:- Request

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

struct HTTPHeader {
    let field: String
    let value: String
}

struct APIRequest {
    let method: HTTPMethod
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader]?
    var body: Data?
    
    init(method: HTTPMethod, path: String) {
        self.method = method
        self.path = path
    }
    
    init<Body: Encodable>(method: HTTPMethod, path: String, body: Body) throws {
        self.method = method
        self.path = path
        self.body = try JSONEncoder().encode(body)
    }
}



// MARK:- Response

enum APIError: Error {
    case invalidURL
    case requestFailed
    case wrongResponseStatus(Int)
    case decodingFailure
    case decodingFailureWithField(String)
    case decodingFailureWithFieldAndValue(String, String)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL in API request", comment: "")
        case .requestFailed:
            return NSLocalizedString("Server returned no response", comment: "")
        case .decodingFailure:
            return NSLocalizedString("Cannot decode data recieved with API request", comment: "")
        case .wrongResponseStatus(let status):
            return NSLocalizedString("Server responded with the error status code: \(status)", comment: "")
        case .decodingFailureWithField(let field):
            return NSLocalizedString("Cannot decode the following field: \(field)", comment: "")
        case .decodingFailureWithFieldAndValue(let field, let value):
            return NSLocalizedString("Cannot decode the value '\(value)' in field '\(field)'", comment: "")
        }
    }
}


struct APIResponse<Body> {
    let statusCode: Int
    let body: Body
}

extension APIResponse where Body == Data? {
    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
        guard let data = body else {
            throw APIError.decodingFailure
        }
        
        let json = try JSONDecoder().decode(BodyType.self, from: data)
        return APIResponse<BodyType>(statusCode: self.statusCode, body: json)
    }
}


// MARK:- APIClient

enum APIResult<Body> {
    case success(APIResponse<Body>)
    case failure(APIError)
}

class APIClient {
    
    typealias APIClientCompletion = (APIResult<Data?>) throws -> ()
    
    static private var shouldRefreshTokens = false
    static private var requestQueue = [(APIRequest, APIClientCompletion)]()
    
    private let session = URLSession.shared
    #if DEBUG
    private let baseURL = URL(string: "https://dev.studo.rtuitlab.ru/api/")!
    #else
    private let baseURL = URL(string: "https://studo.rtuitlab.ru/api/")!
    #endif

    weak var delegate: APIClientDelegate?
    
    static private let keychainAccessTokenKey: String = "ru.rtuitlab.studo.accessTokenData"
    static private let keychainRefreshTokenKey: String = "ru.rtuitlab.studo.refreshTokenData"
    
    static private func tokenIsValid(accessToken: String) -> Bool {
        guard let decodedJWT = try? JWTDecode.decode(jwt: accessToken) else { return false }
        let error = IDTokenValidation(issuer: decodedJWT.body["iss"] as! String, audience: decodedJWT.body["aud"] as! String).validate(decodedJWT)
        return error == nil
        
    }
    
    static private func update(accessToken: String, refreshToken: String) {
        let aTokenItem = tokenItem(forKey: keychainAccessTokenKey)
        let rTokenItem = tokenItem(forKey: keychainRefreshTokenKey)
        do {
            try aTokenItem.savePassword(accessToken)
            try rTokenItem.savePassword(refreshToken)
            print("Tokens updated")
        } catch {
            print("Tokens NOT updated")
        }
    }
    
    static private func getTokens() -> (accessToken: String, refreshToken: String)? {
        let aTokenItem = tokenItem(forKey: keychainAccessTokenKey)
        let rTokenItem = tokenItem(forKey: keychainRefreshTokenKey)
        do {
            let aToken = try aTokenItem.readPassword()
            let rToken = try rTokenItem.readPassword()
            return (aToken, rToken)
        } catch {
            print("Tokens NOT read")
            return nil
        }
    }
    
    static func deleteTokens() {
        let aTokenItem = tokenItem(forKey: keychainAccessTokenKey)
        let rTokenItem = tokenItem(forKey: keychainRefreshTokenKey)
        do {
            try aTokenItem.deleteItem()
            try rTokenItem.deleteItem()
        } catch {
            print("Tokens NOT deleted")
        }
    }
    
    static private func tokenItem(forKey key: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(
            service: KeychainPasswordItem.KeychainConfiguration.serviceName,
            account: key,
            accessGroup: KeychainPasswordItem.KeychainConfiguration.accessGroup
        )
    }
    
    
    private func perform(_ request: APIRequest, _ completion: @escaping APIClientCompletion) {
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path
        
        urlComponents.queryItems = request.queryItems
        
        guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
            try? completion(.failure(.invalidURL)); return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        request.headers?.forEach {
            urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
        }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            do {
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed
                }
                guard httpResponse.statusCode != 401 else {
                    print(request.path)
                    RootViewController.main.logout()
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    throw APIError.wrongResponseStatus(httpResponse.statusCode)
                }
            
                try completion(.success(APIResponse(statusCode: httpResponse.statusCode, body: data)))
            } catch {
                if error is APIError {
                    try! completion(.failure(error as! APIError))
                }
            }
        }
        task.resume()
    }
    
    private func perform(secureRequest request: APIRequest, _ completion: @escaping APIClientCompletion) {
        guard let tokens = APIClient.getTokens(),
            APIClient.tokenIsValid(accessToken: tokens.accessToken) else {
                APIClient.requestQueue.append((request, completion))
                APIClient.shouldRefreshTokens = true
                refreshTokens(); return
        }
        
        DispatchQueue.global(qos: .userInitiated).sync {
            let tokenHeader = HTTPHeader(field: "Authorization", value: "Bearer " + tokens.accessToken)
            
            var requestCopy = request
            if requestCopy.headers != nil {
                requestCopy.headers!.append(tokenHeader)
            } else {
                requestCopy.headers = [tokenHeader]
            }
            
            self.perform(requestCopy, completion)
        }
        
    }

    
}



// MARK: - Delegate

protocol APIClientDelegate: class {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error)
    
    func apiClient(_ client: APIClient, didFinishRegistrationRequest request: APIRequest, andRecievedUser user: User)
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User)
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad])
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad)
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forUserWithId: String)
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forOrganizationWithId: String)
    
    func apiClient(_ client: APIClient, didCreateCommentForAdWithId adId: String)
    func apiClient(_ client: APIClient, didDeleteCommentWithId commentId: String)


    func apiClient(_ client: APIClient, didCreateAd newAd: Ad)
    func apiClient(_ client: APIClient, didUpdateAd updatedAd: Ad)
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String, userInfo: [String: Any]?)
    
    func apiClient(_ client: APIClient, didBookmarkAdWithId adId: String)
    func apiClient(_ client: APIClient, didUnbookmarkAdWithId adId: String, userInfo: [String : Any]?)
    func apiClient(_ client: APIClient, didRecieveBookmarkedAds ads: [Ad])
    
    
    func apiClient(_ client: APIClient, didRecieveProfiles profiles: [Profile])
    func apiClient(_ client: APIClient, didRecieveProfile profile: Profile)
    
    func apiClient(_ client: APIClient, didCreateProfile newProfile: Profile)
    func apiClient(_ client: APIClient, didUpdateProfile updatedProfile: Profile)
    func apiClient(_ client: APIClient, didDeleteProfileWithId profileID: String)
    
    
    
    func apiClient(_ client: APIClient, didSentPasswordResetRequest: APIRequest)
    func apiClient(_ client: APIClient, didChangePasswordWithRequest: APIRequest)
    
    func apiClient(_ client: APIClient, didChangeEmailWithRequest: APIRequest)
    func apiClient(_ client: APIClient, didChangeUserInfo newUserInfo: (firstName: String, lastName: String, studentID: String))
    
    func apiClient(_ client: APIClient, didRecieveOrganizations organizations: [Organization], withOptions options: [APIClient.OrganizationRequestOption]?)
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization)
    func apiClient(_ client: APIClient, didRecieveOrganizationMembers members: [OrganizationMember])
    func apiClient(_ client: APIClient, didRecieveOrganizationWishers wishers: [OrganizationMember])
    func apiClientDidSendApplyOrganizationRequest(_ client: APIClient)
    func apiClientDidAttachOrganizationRight(_ client: APIClient, _ right: OrganizationMemberRight, forMember member: OrganizationMember)
    func apiClientDidDetachOrganizationRight(_ client: APIClient, _ right: OrganizationMemberRight, forMember member: OrganizationMember)
    func apiClient(_ client: APIClient, didCreateOrganization newOrganization: Organization)
    func apiClient(_ client: APIClient, didUpdateOrganization updatedOrganization: Organization)
    func apiClient(_ client: APIClient, didDeleteOrganizationWithId organizationId: String)
    
    func apiClient(_ client: APIClient, didRecieveUser user: User)

}

extension APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func apiClient(_ client: APIClient, didFinishRegistrationRequest request: APIRequest, andRecievedUser user: User) {}
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User) {}
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {}
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forUserWithId: String) {}
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad], forOrganizationWithId: String) {}
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {}
    func apiClient(_ client: APIClient, didCreateCommentForAdWithId adId: String) {}
    func apiClient(_ client: APIClient, didDeleteCommentWithId commentId: String) {}
    func apiClient(_ client: APIClient, didCreateAd newAd: Ad) {}
    func apiClient(_ client: APIClient, didUpdateAd updatedAd: Ad) {}
    func apiClient(_ client: APIClient, didBookmarkAdWithId adId: String) {}
    func apiClient(_ client: APIClient, didUnbookmarkAdWithId adId: String, userInfo: [String : Any]?) {}
    func apiClient(_ client: APIClient, didRecieveBookmarkedAds ads: [Ad]) {}
    func apiClient(_ client: APIClient, didRecieveProfiles profiles: [Profile]) {}
    func apiClient(_ client: APIClient, didRecieveProfile profile: Profile) {}
    func apiClient(_ client: APIClient, didDeleteAdWithId adId: String, userInfo: [String: Any]?) {}
    func apiClient(_ client: APIClient, didCreateProfile newProfile: Profile) {}
    func apiClient(_ client: APIClient, didUpdateProfile updatedProfile: Profile) {}
    func apiClient(_ client: APIClient, didDeleteProfileWithId profileID: String) {}
    func apiClient(_ client: APIClient, didSentPasswordResetRequest: APIRequest) {}
    func apiClient(_ client: APIClient, didChangePasswordWithRequest: APIRequest) {}
    func apiClient(_ client: APIClient, didChangeEmailWithRequest: APIRequest) {}
    func apiClient(_ client: APIClient, didChangeUserInfo newUserInfo: (firstName: String, lastName: String, studentID: String)) {}
    func apiClient(_ client: APIClient, didRecieveOrganizations organizations: [Organization], withOptions options: [APIClient.OrganizationRequestOption]?) {}
    func apiClient(_ client: APIClient, didRecieveOrganization organization: Organization) {}
    func apiClient(_ client: APIClient, didRecieveOrganizationMembers members: [OrganizationMember]) {}
    func apiClient(_ client: APIClient, didRecieveOrganizationWishers wishers: [OrganizationMember]) {}
    func apiClientDidSendApplyOrganizationRequest(_ client: APIClient) {}
    func apiClientDidAttachOrganizationRight(_ client: APIClient, _ right: OrganizationMemberRight, forMember member: OrganizationMember) {}
    func apiClientDidDetachOrganizationRight(_ client: APIClient, _ right: OrganizationMemberRight, forMember member: OrganizationMember) {}
    func apiClient(_ client: APIClient, didCreateOrganization newOrganization: Organization) {}
    func apiClient(_ client: APIClient, didUpdateOrganization updatedOrganization: Organization) {}
    func apiClient(_ client: APIClient, didDeleteOrganizationWithId organizationId: String) {}
    func apiClient(_ client: APIClient, didRecieveUser user: User) {}
}










extension APIClient {
    
    
    // ==========================
    // MARK: - Authorization requests
    // ==========================
    
    func register(user: User) {
        if let request = try? APIRequest(method: .post, path: "auth/register/", body: user.registerDictionaryFormat) {
            self.perform(request) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFinishRegistrationRequest: request, andRecievedUser: user)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    func login(withCredentials creds: Credentials) {
        if let request = try? APIRequest(method: .post, path: "auth/login/", body: creds) {
            self.perform(request) { [self] (result) in
                switch result {
                case .success(let response):
                    if let user = try self.processLoginInfo(from: response) {
                        DispatchQueue.main.async {
                            self.delegate?.apiClient(self, didFinishLoginRequest: request, andRecievedUser: user)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    
    private func refreshTokens() {
        DispatchQueue.global(qos: .userInitiated).sync {
            guard let tokens = APIClient.getTokens() else {
                RootViewController.main.logout(); return
            }
            guard APIClient.shouldRefreshTokens else {
                return
            }
            APIClient.shouldRefreshTokens = false
            
            let dictionary = ["RefreshToken": tokens.refreshToken]
            if let request = try? APIRequest(method: .post, path: "refresh/", body: dictionary) {
                self.perform(request) { [self] (result) in
                    switch result {
                    case .success(let response):
                        try self.processLoginInfo(from: response)
                        print("TOKEN REFRESHED")
                        for (request, completion) in APIClient.requestQueue {
                            self.perform(secureRequest: request, completion)
                        }
                        APIClient.requestQueue = []
                    case .failure(let _):
                        RootViewController.main.logout(); return
                    }
                }
            }
            
        }

    }
    
    
    
    
    
    
    
    
    // ==========================
    // MARK: - Ad-related requests
    // ==========================
    
    
    
    
    func getAds() {
        let request = APIRequest(method: .get, path: "ad/")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let ads = try self.decodeAds(from: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveAds: ads)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    func getAds(forUserWithId userId: String) {
        let request = APIRequest(method: .get, path: "ad/user/\(userId)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let ads = try self.decodeAds(from: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveAds: ads, forUserWithId: userId)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    
    func getAds(forOrganizationWithId organizationId: String) {
        let request = APIRequest(method: .get, path: "ad/organization/\(organizationId)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let ads = try self.decodeAds(from: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveAds: ads, forOrganizationWithId: organizationId)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    
    
    func getAd(withId id: String) {
        let request = APIRequest(method: .get, path: "ad/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let ad = try self.decodeAd(from: decodedJSON, fullDecode: true)
                    
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didRecieveAd: ad)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    func create(ad: Ad) {
        
        let beginTime = DateFormatter.iso8601StringFromDate(ad.beginTime)
        let endTime = DateFormatter.iso8601StringFromDate(ad.endTime)
        
        
        let createForm = AdCreateForm(name: ad.name, description: ad.description!, shortDescription: ad.shortDescription, beginTime: beginTime, endTime: endTime, organizationId: ad.organizationId)
        
        if let request = try? APIRequest(method: .post, path: "ad/", body: createForm) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(let response):
                    guard let data = response.body else { throw APIError.decodingFailure }
                    
                    if let adDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let newAd = try self.decodeAd(from: adDictionary, fullDecode: true)
                        
                        DispatchQueue.main.async {
                            self.delegate?.apiClient(self, didCreateAd: newAd)
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    func replaceAd(with ad: Ad) {
        
        let beginTime = DateFormatter.iso8601StringFromDate(ad.beginTime)
        let endTime = DateFormatter.iso8601StringFromDate(ad.endTime)
        
        let updateForm = AdUpdateForm(id: ad.id, name: ad.name, description: ad.description!, shortDescription: ad.shortDescription, beginTime: beginTime, endTime: endTime)
        
        if let request = try? APIRequest(method: .put, path: "ad/", body: updateForm) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(let response):
                    guard let data = response.body else { throw APIError.decodingFailure }
                    
                    if let adDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let updatedAd = try self.decodeAd(from: adDictionary, fullDecode: true)
                        
                        DispatchQueue.main.async {
                            self.delegate?.apiClient(self, didUpdateAd: updatedAd)
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
    }
    
    
    func deleteAd(withId id: String, userInfo: [String: Any]? = nil) {
        let request = APIRequest(method: .delete, path: "ad/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                guard let data = response.body, let deletedAdID = String(data: data, encoding: .utf8) else {
                    throw APIError.decodingFailure
                }
                
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didDeleteAdWithId: id, userInfo: userInfo)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    
    
    func getBookmarkedAds() {
        let request = APIRequest(method: .get, path: "ad/bookmarks/")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let ads = try self.decodeAds(from: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveBookmarkedAds: ads)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    func bookmarkAd(withId adId: String) {
        
        let request =  APIRequest(method: .post, path: "ad/bookmarks/\(adId)")
        
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didBookmarkAdWithId: adId)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
        
    }
    
    func unbookmarkAd(withId adId: String, userInfo: [String: Any]? = nil) {
        
        let request =  APIRequest(method: .delete, path: "ad/bookmarks/\(adId)")
        
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didUnbookmarkAdWithId: adId, userInfo: userInfo)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
        
    }
    
    
    
    
    // ==========================
    // MARK: - Organization-related requests
    // ==========================
    
    enum OrganizationRequestOption: String {
        case canPublish
        case isMember = "member"
    }
    
    func getOrganizations(_ filterItems: [OrganizationRequestOption]? = nil) {
        var request = APIRequest(method: .get, path: "organization/")
        
        if let filterItems = filterItems, !filterItems.isEmpty {
            var queries = [URLQueryItem]()
            for item in filterItems {
                queries.append(URLQueryItem(name: item.rawValue, value: "true"))
            }
            request.queryItems = queries
        }
        
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let organizations = try self.decodeOrganizations(from: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveOrganizations: organizations, withOptions: filterItems)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    func getOrganization(withId id: String) {
        let request = APIRequest(method: .get, path: "organization/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let organization = try self.decodeOrganization(from: decodedJSON, fullDecode: true)
                    
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didRecieveOrganization: organization)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    func getMembers(forOrganizationWithId id: String) {
        let request = APIRequest(method: .get, path: "organization/members/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let members = try self.decodeOrganizationMembers(from: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveOrganizationMembers: members)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    func getWishers(forOrganizationWithId id: String) {
        let request = APIRequest(method: .get, path: "organization/wish/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let wishers = try self.decodeOrganizationMembers(from: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveOrganizationWishers: wishers)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    func deleteOrganization(withId id: String) {
        let request = APIRequest(method: .delete, path: "organization/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let deletedOrganizationId = try self.decodeString(from: response)
                
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didDeleteOrganizationWithId: deletedOrganizationId)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    func apply(to organization: Organization) {
        if let request = try? APIRequest(method: .post, path: "organization/wish/\(organization.id)") {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.delegate?.apiClientDidSendApplyOrganizationRequest(self)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    func replaceOrganization(with organization: Organization) {
        
        if let request = try? APIRequest(method: .put, path: "organization", body: organization) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(let response):
                    if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let updatedOrganization = try self.decodeOrganization(from: decodedJSON, fullDecode: true)
                        
                        DispatchQueue.main.async {
                            self.delegate?.apiClient(self, didUpdateOrganization: updatedOrganization)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
    }
    
    func attach(right: OrganizationMemberRight, for member: OrganizationMember, in organization: Organization) {
        let dict = [
            "OrganizationId": organization.id,
            "UserId": member.user.id!,
            "Right": right.rawValue
        ]
        if let request = try? APIRequest(method: .post, path: "organization/right/attach", body: dict) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.delegate?.apiClientDidAttachOrganizationRight(self, right, forMember: member)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    func detach(right: OrganizationMemberRight, for member: OrganizationMember, in organization: Organization) {
        let dict = [
            "OrganizationId": organization.id,
            "UserId": member.user.id!,
            "Right": right.rawValue
        ]
        if let request = try? APIRequest(method: .post, path: "organization/right/detach", body: dict) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.delegate?.apiClientDidDetachOrganizationRight(self, right, forMember: member)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    
    
    func create(organization: Organization) {
        
        if let request = try? APIRequest(method: .post, path: "organization", body: organization) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(let response):
                    if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let newOrganization = try self.decodeOrganization(from: decodedJSON, fullDecode: true)
                        
                        DispatchQueue.main.async {
                            self.delegate?.apiClient(self, didCreateOrganization: newOrganization)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
    }
    
    
    func add(comment: Comment, forAdWithId adId: String) {
        
        if let request = try? APIRequest(method: .post, path: "ad/comment/\(adId)", body: comment) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didCreateCommentForAdWithId: adId)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
    }
    
    func deleteComment(withId id: String, adId: String) {
        let request = APIRequest(method: .delete, path: "ad/comment/\(adId)/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):                
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didDeleteCommentWithId: id)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    
    
    // ==========================
    // MARK: - Profile-related requests
    // ==========================
    
    
    func getProfiles(forUserWithId userId: String) {
        let request = APIRequest(method: .get, path: "resumes/user/\(userId)")
        
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let profiles = try self.decodeProfiles(form: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveProfiles: profiles)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }

    }
    
    func getProfiles() {
        let request = APIRequest(method: .get, path: "resumes/")
        
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let profiles = try self.decodeProfiles(form: response)
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveProfiles: profiles)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }

    }
    
    
    func getProfile(withId id: String) {
        let request = APIRequest(method: .get, path: "resumes/\(id)")
        
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                guard let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    throw APIError.decodingFailure
                }
                
                let profile = try self.decodeProfile(from: decodedJSON, fullDecode: true)
                
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didRecieveProfile: profile)
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
        
    }
    
    
    
    
    
    func create(profile: Profile) {
        
        if let request = try? APIRequest(method: .post, path: "resumes", body: profile) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(let response):
                    guard let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        throw APIError.decodingFailure
                    }
                    
                    let profile = try self.decodeProfile(from: decodedJSON, fullDecode: true)

                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didCreateProfile: profile)
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
    }
    
    
    
    func deleteProfile(withId id: String) {
        let request = APIRequest(method: .delete, path: "resumes/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                let deletedProfileId = try self.decodeString(from: response)
                
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didDeleteProfileWithId: deletedProfileId)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    func replaceProfile(with profile: Profile) {
        
        if let request = try? APIRequest(method: .put, path: "resumes", body: profile) {
            self.perform(secureRequest: request) { (result) in
                switch result {
                case .success(let response):
                    
                    guard let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                        throw APIError.decodingFailure
                    }
                    
                    let profile = try self.decodeProfile(from: decodedJSON, fullDecode: true)
                    
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didUpdateProfile: profile)
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
    }
    
    
    
    
    
    
    // ==========================
    // MARK: - User-related requests
    // ==========================
    
    
    func getUser(id: String) {
        let request = APIRequest(method: .get, path: "user/\(id)")
        self.perform(secureRequest: request) { [self] (result) in
            switch result {
            case .success(let response):
                if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let user = try self.decode(userDictionary: decodedJSON)
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didRecieveUser: user)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    func requestPasswordRest(forEmail email: String) {
        let bodyDictionary = ["email": email]
        if let request = try? APIRequest(method: .post, path: "user/password/reset", body: bodyDictionary) {
            self.perform(request) { [self] (result) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didSentPasswordResetRequest: request)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    
    func changePassword(from currentPassword: String, to newPassword: String) {
        let currentUser = PersistentStore.shared.user!
        let credentialsDictionary = [
            "Id": currentUser.id!,
            "OldPassword": currentPassword,
            "NewPassword": newPassword
        ]
        
        if let request = try? APIRequest(method: .post, path: "user/password/change", body: credentialsDictionary) {
            self.perform(secureRequest: request) { [self] (result) in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didChangePasswordWithRequest: request)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
        
        
    }
    
    
    
    
    func changeEmail(to newEmail: String) {
        let currentUser = PersistentStore.shared.user!
        let emailRequestDictionary = [
            "id": currentUser.id!,
            "oldEmail": currentUser.email,
            "newEmail": newEmail
        ]
        
        if let request = try? APIRequest(method: .post, path: "user/change/email", body: emailRequestDictionary) {
            self.perform(secureRequest: request) { [self] result in
                switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.delegate?.apiClient(self, didChangeEmailWithRequest: request)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    
    
    func changeUserInfo(to newInfo: (firstName: String, lastName: String, studentID: String)) {
        let currentUser = PersistentStore.shared.user!
        let userInfoRequestDictionary = [
            "id": currentUser.id!,
            "firstname": newInfo.firstName,
            "surname": newInfo.lastName,
            "studentCardNumber": newInfo.studentID
        ]
        
        if let request = try? APIRequest(method: .post, path: "user/change/info", body: userInfoRequestDictionary) {
            self.perform(secureRequest: request) { [self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didChangeUserInfo: newInfo)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                }
            }
        }
    }
    
    
    
    
}





extension APIClient {
    
    fileprivate func decodeString(from response: (APIResponse<Data?>), inQuotes: Bool = true) throws -> String {
        
        guard let data = response.body, let resultString = String(data: data, encoding: .utf8) else {
            throw APIError.decodingFailure
        }
        
        if inQuotes {
            let regex = try NSRegularExpression(pattern: "\"(.*)\"", options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: resultString, options: [], range: NSRange(location: 0, length: resultString.utf16.count))
            
            if let match = matches.first {
                let range = match.range(at:1)
                if let swiftRange = Range(range, in: resultString) {
                    let textInsideQuotes = resultString[swiftRange]
                    return String(textInsideQuotes)
                }
            }
        }
        
        return resultString
        
    }
    
    
    
    fileprivate func decodeAds(from response: (APIResponse<Data?>), fullDecode: Bool = false ) throws -> [Ad] {
        guard let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw APIError.decodingFailure
        }
        var ads = [Ad]()
        for object in decodedJSON {
            let ad = try self.decodeAd(from: object, fullDecode: fullDecode)
            ads.append(ad)
        }
        
        return ads
    }
    
    fileprivate func decodeProfiles(form response: (APIResponse<Data?>)) throws -> [Profile] {
        guard let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw APIError.decodingFailure
        }
        
        var profiles = [Profile]()
        for object in decodedJSON {
            let profile = try self.decodeProfile(from: object)
            profiles.append(profile)
        }
        return profiles
    }
    
    
    fileprivate func decodeOrganizations(from response: (APIResponse<Data?>), fullDecode: Bool = false ) throws -> [Organization] {
        guard let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw APIError.decodingFailure
        }
        var organizations = [Organization]()
        for object in decodedJSON {
            let organization = try self.decodeOrganization(from: object, fullDecode: fullDecode)
            organizations.append(organization)
        }
        
        return organizations
    }
    
    
    fileprivate func decodeOrganizationMembers(from response: (APIResponse<Data?>)) throws -> [OrganizationMember] {
        guard let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw APIError.decodingFailure
        }
        var organizationMembers = [OrganizationMember]()
        for object in decodedJSON {
            let member = try self.decodeOrganizationMember(from: object)
            organizationMembers.append(member)
        }
        
        return organizationMembers
    }
    
    @discardableResult fileprivate func processLoginInfo(from response: APIResponse<Data?>) throws -> User? {
        if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            guard let userDictionary = decodedJSON["user"] as? [String: Any] else {
                throw APIError.decodingFailure
            }
            guard let accessToken = decodedJSON["accessToken"] as? String else {
                throw APIError.decodingFailure
            }
            
            guard let refreshToken = decodedJSON["refreshToken"] as? String else {
                throw APIError.decodingFailure
            }
            
            APIClient.update(accessToken: accessToken, refreshToken: refreshToken)
            
            let user = try self.decode(userDictionary: userDictionary)
            PersistentStore.shared.user = user
            return user
        }
        return nil
    }
    
    
    
    
}

