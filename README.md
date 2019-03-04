WalletConnect
============

Library to use [WalletConnect](https://walletconnect.org) with Swift.

## Requirements

- iOS 10.0+ / macOS 10.12+ / tvOS 10.0+ / watchOS 3.0+
- Xcode 10.1+
- Swift 4.2+

## Installation
WalletConnect can be added to your project using [CocoaPods](https://cocoapods.org/) by adding the following line to your Podfile:
```
pod 'WalletConnect', '~> 0.0.1'
```

# Usage
Parse scanned QR code:
```swift
let scannedCode = "..."
let parser = WCCodeParser()
let result = parser.parse(string: scannedCode)
        
if case let .success(session) = result {
    // Handle session
} else {
    // Bad QR
}
```

Approve session for account with device push token to receive notifications with requests:
```swift
let deviceToken = "..."
let pushData = WCPushNotificationData(deviceToken: deviceToken, webhookUrl: "https://foo.io/walletconnect/push")
let interactor = WCInteractor(session: session, pushData: pushData)
interactor.approveSession(accounts: [account]) { result in          
    if case let .success(response) = result {
        // Session approved
    } else {
        // Something went wrong
    }
}
```

Reject session:
```swift
let interactor = WCInteractor(session: session)
interactor.rejectSession(accounts: [account]) { result in          
    if case let .success(response) = result {
        // Session rejected
    } else {
        // Something went wrong
    }
}
```
## Call requests handling
Register your app in the Apple Push Notification Service:
```swift
let center = UNUserNotificationCenter.current()
center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
    // Enable or disable features based on authorization.
}
```

Configure push handling:
```swift
import UserNotifications
UNUserNotificationCenter.current().delegate = self

func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
       
    let userInfo = response.notification.request.content.userInfo
    if let push = WCPushContent.fromUserInfo(userInfo) {
        handlePush(push: push)
    }
}
```

Handle push:
```swift
func handlePush(push: WCPushContent) {
 
    guard let session = self.currentSession, push.sessionId == session.sessionId else { return }
    
    let interactor = WCInteractor(session: session)
    interactor.fetchCallRequest(callId: push.callId) { response in
        
        guard case let .success(callRequest) = response else { return }
        
        switch callRequest {
        case let .sendTransaction(transaction):
            // Approve and sign or reject 
        case let .signMessage(accountAddress, message):
            // Approve and sign or reject
        }
    }
}
```
Approve call request:
```swift
self.signTransaction(transaction) { hash in

    guard let hash = hash else { return }
    
    let interactor = WCInteractor(session: session)
    interactor.approveCallRequest(callId: push.callId, result: hash) { response in 
        // Handle response
    }
}
```

Reject call request:
```swift
let interactor = WCInteractor(session: session)
interactor.rejectCallRequest(callId: push.callId) { response in 
    // Handle response
}
```
