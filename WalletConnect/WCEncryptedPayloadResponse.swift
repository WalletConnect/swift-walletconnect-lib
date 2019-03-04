//
//  WCEncryptedPayloadResponse.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation
import ObjectMapper

public class WCEncryptedPayloadResponse: Mappable {
    
    public private(set) var data: String = ""
    public private(set) var hmac: String = ""
    public private(set) var iv: String = ""
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
        data <- map["data"]
        hmac <- map["hmac"]
        iv <- map["iv"]
    }
}
