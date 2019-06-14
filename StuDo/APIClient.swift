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
    case decodingFailure
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
    typealias APIClientCompletion = (APIResult<Data?>) -> ()
    
    private let session = URLSession.shared
    private let baseURL = URL(string: "https://dev.studo.rtuitlab.ru/api/")!
    
    var delegate: APIClientDelegate?
    
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
            completion(.failure(.invalidURL)); return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        request.headers?.forEach {
            urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
        }
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.requestFailed)); return
            }
            completion(.success(APIResponse(statusCode: httpResponse.statusCode, body: data)))
        }
        task.resume()
    }
    
}



// MARK:- StuDo API Requests

protocol APIClientDelegate {
    func apiClient(_ client: APIClient, didFailRequest: APIRequest, withError error: Error)

    func apiClient(_ client: APIClient, didFinishRegistrationRequest: APIRequest, andRecievedUser user: User)
    func apiClient(_ client: APIClient, didFinishLoginRequest: APIRequest, andRecievedUser user: User)
}


extension APIClient {
    
    // FIXME: This code may fail depending on the kind of data the server returns. Please check when the server is available!
    func register(user: User) {
        if let request = try? APIRequest(method: .post, path: "auth/register", body: user) {
            self.perform(request) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let user = try response.decode(to: User.self).body
                        self.delegate?.apiClient(self, didFinishRegistrationRequest: request, andRecievedUser: user)
                    } catch let error {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                case .failure(let error):
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
    
    func login(withCredentials creds: Credentials) {
        if let request = try? APIRequest(method: .post, path: "auth/login", body: creds) {
            self.perform(request) { [self] (result) in
                switch result {
                case .success(let response):
                    do {
                        if let data = response.body, let decodedJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            guard let userDictionary = decodedJSON["user"] as? [String: Any] else {
                                throw APIError.decodingFailure
                            }
                            guard let accessToken = decodedJSON["accessToken"] as? String else {
                                throw APIError.decodingFailure
                            }
                            
                            self.accessToken = accessToken
                            let user = try self.decode(userDictionary: userDictionary)
                            self.delegate?.apiClient(self, didFinishLoginRequest: request, andRecievedUser: user)
                        }
                    } catch let error {
                        self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                    }
                case .failure(let error):
                    self.delegate?.apiClient(self, didFailRequest: request, withError: error)
                }
            }
        }
    }
}







