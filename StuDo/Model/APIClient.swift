//
//  APIClient.swift
//  StuDo
//
//  Created by Andrew on 5/31/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}


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
    
    private let session = URLSession.shared
    private let baseURL = URL(string: "https://dev.studo.rtuitlab.ru/api/")!
//    private let baseURL = URL(string: "http://65706bbf.ngrok.io/api/")!

    
    weak var delegate: APIClientDelegate?
    
    private let keychainTokenLabel: String = "tokenAccessData"
    private var accessToken: String? = nil {
        didSet {
            do {
                try saveAccessTokenToKeychain()
            } catch {
                
            }
        }
    }
    private func saveAccessTokenToKeychain() throws {
        guard let tokenData = accessToken?.data(using: .utf8) else { return }
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: keychainTokenLabel,
                                    kSecValueData as String: tokenData]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    private func restoreAccessTokenFromKeychain() throws -> String {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: keychainTokenLabel,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let tokenData = existingItem[kSecValueData as String] as? Data,
            let token = String(data: tokenData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        return token
    }
    
    init() {
        if let accessToken = try? restoreAccessTokenFromKeychain() {
            self.accessToken = accessToken
        } else {
            accessToken = nil
        }
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
        guard let token = self.accessToken else { return }
        
        let tokenHeader = HTTPHeader(field: "Authorization", value: "Bearer " + token)
        
        var requestCopy = request
        if requestCopy.headers != nil {
            requestCopy.headers!.append(tokenHeader)
        } else {
            requestCopy.headers = [tokenHeader]
        }
        
        self.perform(requestCopy, completion)
    }

    
}



// MARK:- StuDo API Requests

protocol APIClientDelegate: class {
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error)

    func apiClient(_ client: APIClient, didFinishRegistrationRequest request: APIRequest, andRecievedUser user: User)
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User)
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad])
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad)
    func apiClient(_ client: APIClient, didUpdateAdWithID: String)
    func apiClient(_ client: APIClient, didDeleteAdWithID: String)
}

extension APIClientDelegate {
    func apiClient(_ client: APIClient, didFinishRegistrationRequest request: APIRequest, andRecievedUser user: User) {}
    func apiClient(_ client: APIClient, didFinishLoginRequest request: APIRequest, andRecievedUser user: User) {}
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {}
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {}
    func apiClient(_ client: APIClient, didUpdateAdWithID: String) {}
    func apiClient(_ client: APIClient, didDeleteAdWithID: String) {}
}










extension APIClient {
    
    func register(user: User) {
        if let request = try? APIRequest(method: .post, path: "auth/register", body: user.registerDictionaryFormat) {
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
        if let request = try? APIRequest(method: .post, path: "auth/login", body: creds) {
            self.perform(request) { [self] (result) in
                switch result {
                case .success(let response):
                    if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        guard let userDictionary = decodedJSON["user"] as? [String: Any] else {
                            throw APIError.decodingFailure
                        }
                        guard let accessToken = decodedJSON["accessToken"] as? String else {
                            throw APIError.decodingFailure
                        }
                        
                        self.accessToken = accessToken
                        let user = try self.decode(userDictionary: userDictionary)
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
    
    
    
    
    
    
    func getAdds() {
        let request = APIRequest(method: .get, path: "ad")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    
                    var ads = [Ad]()
                    for object in decodedJSON {
                        let ad = try self.decodeAd(from: object)
                        ads.append(ad)
                    }
                    
                    DispatchQueue.main.async {
                        self.delegate?.apiClient(self, didRecieveAds: ads)
                    }
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
    
    
    
    
    
    
    func replaceAd(with ad: Ad) {
        
        // TODO: Check if description is filled!
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
//        let updateForm = AdUpdateForm(id: ad.id, name: ad.name, description: ad.fullDescription!, shortDescription: ad.shortDescription, beginTime: formatter.string(from: Date()), endTime: formatter.string(from: Date(timeIntervalSinceNow: 3600 * 2)))
        
//        if let request = try? APIRequest(method: .put, path: "ad", body: updateForm) {
//            self.perform(secureRequest: request) { (result) in
//                switch result {
//                case .success:
//                    DispatchQueue.main.async {
//                        self.delegate?.apiClient(self, didUpdateAd: ad)
//                    }
//                case .failure(let error):
//                    DispatchQueue.main.async {
//                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
//                    }
//                }
//            }
//        }
    }
    
    
    
    
    
    
    
    func deleteAd(withId id: String) {
        let request = APIRequest(method: .delete, path: "ad/\(id)")
        self.perform(secureRequest: request) { (result) in
            switch result {
            case .success(let response):
                guard let data = response.body, let deletedAdID = String(data: data, encoding: .utf8) else {
                    throw APIError.decodingFailure
                }
                
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didDeleteAdWithID: deletedAdID)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    
    
    
    
    
}







