//
//  WCPushNotificationData.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation

public struct WCPushNotificationData {
    
    public let deviceToken: String
    public let webhookUrl: String
    
    public init (deviceToken: String, webhookUrl: String) {
        
        self.deviceToken = deviceToken
        self.webhookUrl = webhookUrl
    }
    
    public init (deviceToken: Data, webhookUrl: String) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
        self.init(deviceToken: token, webhookUrl: webhookUrl)
    }
}
