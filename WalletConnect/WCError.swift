//
//  WCError.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation

public enum WCError: Error {
    
    case badServerResponse
    case unknown
    case some(description: String)
}
