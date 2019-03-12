//
//  Data+Hex.swift
//  WalletConnect
//
//  Created by Igor Shmakov on 22/02/2019.
//  Copyright © 2019 Tokenary. All rights reserved.
//

import Foundation

extension Data {
    
    var hexString: String {
        
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    static func fromHexString(_ rawHexString: String) -> Data {
        
        var hexString = rawHexString
        if rawHexString.hasPrefix("0x") {
            hexString = String(rawHexString.dropFirst(2))
        }
        
        var resultBytes = [UInt8]()
        var currentWord = ""
        for char in hexString {
            currentWord += String(char)
            if currentWord.count == 2 {
                let scanner = Scanner(string: currentWord)
                var value: CUnsignedInt = 0
                scanner.scanHexInt32(&value)
                resultBytes.append(UInt8(value))
                currentWord = ""
            }
        }
        
        let resultData = Data(bytes: resultBytes)
        return resultData
    }
}
