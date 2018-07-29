# Smartech Cordova iOS Plugin
Smartech plugin for Activity tracking in cordova iOS Application Using Smartech iOS SDK.

This plugin provides Activity tracking in cordova iOS Application.

### Using
---
Create a new Cordova Project
```
$ cordova create <project name> <project package name> <Display name>
$ cd <Display Name>
```
Install iOS Platform
```
$ cordova platform add ios
```
Navigate to iOS Project
```
$ cd platforms/ios
```
### Integration using CocoaPod
---
1. Install Cocoapods on your computer.
2. Create pod file using below command
```
pod init
```
3. Add following line in your podfile
```
pod 'Netcore-Smartech-iOS-SDK'
```
4. Run following command in your project directory
```
pod install
```
5. Add following capabilities inside your application
```
Push Notification
Keychain
Background Mode -> Remote Notification
App Groups
```
6. Open .xcworkspace and build

