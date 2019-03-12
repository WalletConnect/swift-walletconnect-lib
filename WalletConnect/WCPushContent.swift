//
//  WCPushContent.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation
import ObjectMapper

public class WCPushContent: Mappable {

    public private(set) var sessionId = ""
    public private(set) var callId = ""
    public private(set) var dappName = ""
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
        sessionId <- map["sessionId"]
        callId <- map["callId"]
        dappName <- map["dappName"]
    }
    
    static public func fromUserInfo(_ userInfo: [AnyHashable : Any]) -> WCPushContent? {
        
        guard let json = userInfo["custom"] as? [String : Any] else { return nil }
        let content = WCPushContent(JSON: json)
        return content
    }
}
