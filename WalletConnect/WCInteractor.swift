//
//  WCInteractor.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation
import CryptoSwift

public class WCInteractor {
    
    private let session: WCSession
    private let pushData: WCPushNotificationData?
    private let client: WCClient
    
    public init(session: WCSession, pushData: WCPushNotificationData? = nil) {
        
        self.session = session
        self.pushData = pushData
        self.client = WCClient()
    }
    
    public func approveSession(accounts: [String], completion: @escaping ObjectRequestCompletion<WCApproveSessionResponse>) {
        
        let accountsString = "[" + accounts.map { "\"\($0)\"" }.joined(separator: ",") + "]"
        let sessionStatus = "{\"data\":{\"chainId\":1,\"accounts\":\(accountsString),\"approved\":true}}"
        sendSessionStatus(pushData: pushData, sessionStatus: sessionStatus, completion: completion)
    }
    
    public func rejectSession(completion: @escaping ObjectRequestCompletion<WCApproveSessionResponse>) {
        
        let sessionStatus = "{\"data\":{\"approved\":false}}"
        sendSessionStatus(pushData: nil, sessionStatus: sessionStatus, completion: completion)
    }
    
    public func killSession(completion: @escaping SimpleRequestCompletion) {
        
        let methodUrl = "\(session.bridgeUrl)/session/\(session.sessionId)"
        self.client.killSession(url: methodUrl, completion: completion)
    }
    
    public func fetchCallRequest(callId: String, completion: @escaping ObjectRequestCompletion<WCCallRequest>) {
        
        let methodUrl = "\(session.bridgeUrl)/session/\(session.sessionId)/call/\(callId)"
        
        self.client.fetchCallRequestData(url: methodUrl) { [weak self] apiResponse in
            switch apiResponse {
            case let .failure(error):
                completion(.failure(error: error))
            case let .success(encryptedPayload):
                self?.decryptCallPayload(encryptedPayload: encryptedPayload, completion: completion)
            }
        }
    }
    
    public func approveCallRequest(callId: String, result: String, completion: @escaping SimpleRequestCompletion) {
        
        let callStatus = "{\"data\":{\"result\":\"\(result)\",\"approved\":true}}"
        sendCallStatus(callId: callId, callStatus: callStatus, completion: completion)
    }
    
    public func rejectCallRequest(callId: String, completion: @escaping SimpleRequestCompletion) {
        
        let callStatus = "{\"data\":{\"approved\":false}}"
        sendCallStatus(callId: callId, callStatus: callStatus, completion: completion)
    }
    
    private func sendSessionStatus(pushData: WCPushNotificationData?, sessionStatus: String,
                                   completion: @escaping ObjectRequestCompletion<WCApproveSessionResponse>) {
        
        guard let (data, hmac, iv) = try? encrypt(payload: sessionStatus) else {
            completion(.failure(error: .unknown))
            return
        }
        
        var payload: [String: Any?] = [
            "encryptionPayload": [
                "data": "\(data)",
                "hmac": "\(hmac)",
                "iv": "\(iv)"
            ]
        ]
        
        if let pushData = pushData {
            payload["push"] = [
                "type": "apn",
                "token": "\(pushData.deviceToken)",
                "webhook": "\(pushData.webhookUrl)"
            ]
        } else {
            payload.updateValue(nil, forKey: "push")
        }
        
        let methodUrl = "\(session.bridgeUrl)/session/\(session.sessionId)"
        self.client.sendSessionStatus(url: methodUrl, payload: payload as [String: Any], completion: completion)
    }
    
    private func sendCallStatus(callId: String, callStatus: String, completion: @escaping SimpleRequestCompletion) {
        
        guard let (data, hmac, iv) = try? encrypt(payload: callStatus) else {
            completion(.failure(error: .unknown))
            return
        }
        
        let payload = [
            "encryptionPayload": [
                "data": "\(data)",
                "hmac": "\(hmac)",
                "iv": "\(iv)"
            ]
        ]
        
        let methodUrl = "\(session.bridgeUrl)/call-status/\(callId)/new"
        self.client.sendCallStatus(url: methodUrl, payload: payload, completion: completion)
    }
    
    private func decryptCallPayload(encryptedPayload: WCEncryptedPayloadResponse,
                                    completion: @escaping ObjectRequestCompletion<WCCallRequest>) {
        guard
            let decryptedString = try? decrypt(data: encryptedPayload.data, hmac: encryptedPayload.hmac,
                                               iv: encryptedPayload.iv),
            let decryptedData = decryptedString.data(using: .utf8),
            let decryptedObject = (try? JSONSerialization.jsonObject(with: decryptedData, options: .allowFragments)) as? [String: Any],
            let callData = decryptedObject["data"] as? [String: Any],
            let method = callData["method"] as? String
        else {
            completion(.failure(error: .badServerResponse))
            return
        }
        
        switch method {
        case "eth_sign":
            
            guard let params = callData["params"] as? [String], params.count == 2 else {
                completion(.failure(error: .badServerResponse))
                return
            }
            completion(.success(result: WCCallRequest.signMessage(account: params[0], message: params[1])))
            
        case "eth_sendTransaction":
            
            guard let transaction = (callData["params"] as? [[String: Any]])?.first else {
                completion(.failure(error: .badServerResponse))
                return
            }
            
            completion(.success(result: WCCallRequest.sendTransaction(transaction: transaction)))
            
        default:
            completion(.failure(error: .badServerResponse))
        }
    }
    
    private func encrypt(payload: String) throws -> (data: String, hmac: String, iv: String) {
        
        let ivBytes = randomBytes(16)
        let keyBytes = Data.fromHexString(session.symKey).bytes
        let aesCipher = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes))
        let cipherInput = Array(payload.utf8)
        let encryptedBytes = try aesCipher.encrypt(cipherInput)
        
        let data = Data(bytes: encryptedBytes).hexString
        let iv = Data(bytes: ivBytes).hexString
        let hmac = try makeHmac(payload: data, iv: iv, key: keyBytes)
        return (data, hmac, iv)
    }
    
    private func decrypt(data: String, hmac: String, iv: String) throws -> String {
        
        let keyBytes = Data.fromHexString(session.symKey).bytes
        let computedHmac = try makeHmac(payload: data, iv: iv, key: keyBytes)
        
        guard computedHmac == hmac else {
            throw WCError.badServerResponse
        }
        
        let dataBytes = Data.fromHexString(data).bytes
        let ivBytes = Data.fromHexString(iv).bytes
        let aesCipher = try AES(key: keyBytes, blockMode: CBC(iv: ivBytes))
        let decryptedBytes = try aesCipher.decrypt(dataBytes)
        
        guard let result = String(bytes: decryptedBytes, encoding: .utf8) else {
            throw WCError.unknown
        }
        
        return result
    }
    
    func makeHmac(payload: String, iv: String, key: [UInt8]) throws -> String {
        
        guard
            let payloadBytes = payload.data(using: .utf8)?.bytes,
            let ivBytes = iv.data(using: .utf8)?.bytes
        else {
            throw WCError.unknown
        }
        
        let bytes = payloadBytes + ivBytes
        let hmacBytes = try HMAC(key: key, variant: .sha256).authenticate(bytes)
        let hmac = Data(bytes: hmacBytes).hexString
        return hmac
    }
    
    private func randomBytes(_ n: Int) -> [UInt8] {
     
        var result = [UInt8]()
        for _ in 1...n {
            result.append(UInt8(arc4random_uniform(256)))
        }
        return result
    }
}
