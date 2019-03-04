//
//  WCClient.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public enum RequestResponse<ErrorType> {
    case success
    case failure(error: ErrorType)
}

public enum RequestObjectResponse<ObjectType, ErrorType> {
    case success(result: ObjectType)
    case failure(error: ErrorType)
}

public typealias SimpleRequestCompletion = (RequestResponse<WCError>) -> Void
public typealias ObjectRequestCompletion<ObjectType> = (RequestObjectResponse<ObjectType, WCError>) -> Void


class WCClient {
    
    let sessionManager = SessionManager.default
    
    func process(_ requestConvertible: URLRequestConvertible,
                 completion: @escaping SimpleRequestCompletion) {
        
        let request = sessionManager.request(requestConvertible).validate(statusCode: 200...200)
        request.response { response in
            self.handleResponse(response, completion: completion)
        }
    }
    
    func process<ObjectType: Mappable>(_ requestConvertible: URLRequestConvertible,
                                       keyPath: String? = nil,
                                       completion: @escaping ObjectRequestCompletion<ObjectType>) {
        
        let request = sessionManager.request(requestConvertible).validate(statusCode: 200...200)
        request.responseObject(keyPath: keyPath) { response in
            self.handleResponse(response, completion: completion)
        }
    }

    func extractError(data: Data?) -> String? {
        
        if let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String],
            let errorString = json?["message"] {
            return errorString
        } else {
            return nil
        }
    }
    
    func handleResponse(_ response: DefaultDataResponse, completion: @escaping SimpleRequestCompletion) {
       
        if let error = response.error {
            if let message = extractError(data: response.data) {
                completion(.failure(error: .some(description: message)))
            } else {
                completion(.failure(error: .some(description: error.localizedDescription)))
            }
        } else {
            completion(.success)
        }
    }
    
    func handleResponse<ObjectType>(_ response: DataResponse<ObjectType>, completion: @escaping ObjectRequestCompletion<ObjectType>) {
        
        switch response.result {
        case .success(let value):
            completion(.success(result: value))
        case .failure(let error):
            if let message = extractError(data: response.data) {
                completion(.failure(error: .some(description: message)))
            } else {
                completion(.failure(error: .some(description: error.localizedDescription)))
            }
        }
    }
    
    func sendSessionStatus(url: String, payload: [String: Any], completion: @escaping ObjectRequestCompletion<WCApproveSessionResponse>) {
        
        process(WCNetworkingRouter.sendSessionStatus(url: url, payload: payload), completion: completion)
    }
    
    func killSession(url: String, completion: @escaping SimpleRequestCompletion) {
        
        process(WCNetworkingRouter.killSession(url: url), completion: completion)
    }
    
    func fetchCallRequestData(url: String, completion: @escaping ObjectRequestCompletion<WCEncryptedPayloadResponse>) {
        
        process(WCNetworkingRouter.fetchCallRequestData(url: url), keyPath: "data.encryptionPayload", completion: completion)
    }
    
    func sendCallStatus(url: String, payload: [String: Any], completion: @escaping SimpleRequestCompletion) {
        
        process(WCNetworkingRouter.sendCallStatus(url: url, payload: payload), completion: completion)
    }
}
