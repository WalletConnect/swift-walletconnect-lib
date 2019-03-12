//
//  WCCallRequest.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation

public typealias WCTransaction = [String: Any]

public enum WCCallRequest {
    
    case sendTransaction(transaction: WCTransaction)
    case signMessage(account: String, message: String)
}
