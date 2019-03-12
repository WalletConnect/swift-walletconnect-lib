//
//  WCCodeParser.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation

public class WCCodeParser {
    
    private let publicAddressRegex = try! NSRegularExpression(pattern: "(0x)?[0-9A-Fa-f]{40}")
    private let walletConnectUriPrefix = "ethereum:wc-"
    
    public enum ParserResult {
        case error
        case success(session: WCSession)
    }
    
    public init() {
        
    }
    
    public func parse(string: String) -> ParserResult {
        
        if string.hasPrefix(walletConnectUriPrefix) {
            return parseWalletConnect(string: string)
        } else {
            return .error
        }
    }
    
    private func parseWalletConnect(string s: String) -> ParserResult {
        
        guard var s = s.removingPercentEncoding else {
            return .error
        }
        
        s = String(s.dropFirst(walletConnectUriPrefix.count))
        
        guard let sessionIdLength = s.firstIndex(of: "@")?.encodedOffset else {
            return .error
        }
        
        let sessionId = String(s.prefix(sessionIdLength))
        
        guard let questionMarkIndex = s.firstIndex(of: "?")?.encodedOffset else {
            return .error
        }
        
        s = String(s.dropFirst(questionMarkIndex + 1))
        var keys = Set(["name", "bridge", "symKey"])
        var name = "", bridgeUrl = "", symkey = ""
        
        while !keys.isEmpty {
            
            guard let prefixKey = keys.first(where: { s.hasPrefix($0) }) else {
                return .error
            }
            
            keys.remove(prefixKey)
            
            let prefixValue: String
            s = String(s.dropFirst(prefixKey.count + 1))
            
            if let fieldLength = s.firstIndex(of: "&")?.encodedOffset {
                prefixValue = String(s.prefix(fieldLength))
                s = String(s.dropFirst(fieldLength + 1))
            } else {
                prefixValue = s
                s = ""
            }
            
            switch prefixKey {
            case "name":
                name = prefixValue
            case "bridge":
                bridgeUrl = prefixValue
            case "symKey":
                symkey = prefixValue
            default:
                return .error
            }
        }
        
        if bridgeUrl.last == "/" {
            bridgeUrl = String(bridgeUrl.dropLast())
        }
        
        guard let hexSymKey = Data(base64Encoded: symkey)?.hexString else {
            return .error
        }
        
        symkey = hexSymKey
        
        let result = WCSession(sessionId: sessionId, name: name, bridgeUrl: bridgeUrl, symKey: symkey)
        return .success(session: result)
    }
}
