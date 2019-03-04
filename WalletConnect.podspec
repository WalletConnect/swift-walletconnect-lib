#
#  Be sure to run `pod spec lint WalletConnect.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "WalletConnect"
  s.version      = "0.0.1"
  s.summary      = "WalletConnect SDK for iOS and macOS"
  s.description  = "WalletConnect SDK for iOS and macOS"
  s.homepage     = "https://walletconnect.org"
  s.license      = "MIT"
  s.author             = { "Igor Shmakov" => "shmakoff.work@gmail.com" }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.source       = { :git => 'https://github.com/WalletConnect/swift-walletconnect-lib.git', :tag => s.version }
  s.source_files  = "WalletConnect/*.swift"
  s.requires_arc = true
  s.swift_version = "4.2"
  s.dependency "AlamofireObjectMapper", "~> 5.2.0"
  s.dependency "CryptoSwift", "~> 0.14.0"

end
