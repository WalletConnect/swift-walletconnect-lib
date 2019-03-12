//
//  WCNetworkingRouter.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation
import Alamofire

typealias EncodingResult = (
    method: HTTPMethod,
    url: String,
    parameters: [String: Any]?,
    encoding: ParameterEncoding
)

enum WCNetworkingRouter: URLRequestConvertible {
    
    case sendSessionStatus(url: String, payload: [String: Any])
    case killSession(url: String)
    case fetchCallRequestData(url: String)
    case sendCallStatus(url: String, payload: [String: Any])
    
    func asURLRequest() throws -> URLRequest {
        
        let (method, path, parameters, encoding): EncodingResult = {
            
            switch self {
            case let .sendSessionStatus(url, payload):
                return encodeSendSessionStatus(url, payload)
            case let .killSession(url):
                return encodeKillSession(url)
            case let .fetchCallRequestData(url):
                return encodeFetchCallRequestData(url)
            case let .sendCallStatus(url, payload):
                return encodeSendCallStatus(url, payload)
            }
        }()
        
        var urlRequest = URLRequest(url: try path.asURL())
        urlRequest.httpMethod = method.rawValue
        
        let request = try encoding.encode(urlRequest, with: parameters)
        return request
    }        
    
    func encodeSendSessionStatus(_ url: String, _ payload: [String: Any]) -> EncodingResult {
       
        return (.put, url, payload, JSONEncoding.default)
    }
    
    func encodeKillSession(_ url: String) -> EncodingResult {
       
        return (.delete, url, nil, JSONEncoding.default)
    }
    
    func encodeFetchCallRequestData(_ url: String) -> EncodingResult {
       
        return (.get, url, nil, JSONEncoding.default)
    }
    
    func encodeSendCallStatus(_ url: String, _ payload: [String: Any]) -> EncodingResult {
      
        return (.post, url, payload, JSONEncoding.default)
    }
}
