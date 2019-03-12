//
//  WCApproveSessionResponse.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import ObjectMapper

public class WCApproveSessionResponse: Mappable {
    
    public private(set) var expires: Int = 0
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        expires <- map["expires"]
    }
}
