# Smartech Cordova iOS Plugin

Smartech plugin for Activity tracking in cordova iOS Application Using Smartech iOS SDK.



This plugin provides Activity tracking in cordova iOS Application.



## Using

Create a new Cordova Project
```
$ cordova create <project name> <project package name> <Display name>

$ cd <Display Name>
```

Install iOS Platform
```
$ cordova platform add ios
```

Install Cocoapod installer

```
$ cordova plugin add cordova-plugin-cocoapod-support --save
```

Install Cordova Broadcaster

```
$ cordova plugin add cordova-plugin-broadcaster --save
```

Install NetCore iOS Cordova Plugin
```
cordova plugin add https://github.com/kjhaSSI/SmartechiOSCordova.git
```

Navigate to iOS Project

```
$ cd platforms/ios
```

Open .xcworkspace and build.

Add following capabilities inside your application

```
Push Notification

Keychain

Background Mode -> Remote Notification

App Groups

Set URL Scheme (Needed for deep linking)
```

## NetCore SDK Initialization

Add header in AppDelegate.h

```objectivec
#import <UserNotifications/UserNotifications.h>

#import <UserNotificationsUI/UserNotificationsUI.h>

#import "NetCoreIOSCordovaSDK.h"
```



Add Delegate in AppDelegate.h

```objectivec
UNUserNotificationCenterDelegate
```

Open AppDelegate.m

Add following code in didFinishLaunchingWithOptions:

```objectivec
[[NetCoreIOSCordovaSDK sharedInstance] setAppLaunchOptions:launchOptions];
```

Add below code in AppDelegate.m

```objectivec
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
[[NetCoreIOSCordovaSDK sharedInstance] setNotificationDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
[[NetCorePushTaskManager  sharedInstance] didReceiveRemoteNotification:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
[[NetCorePushTaskManager  sharedInstance] didReceiveRemoteNotification:userInfo];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
[[NetCorePushTaskManager  sharedInstance] didReceiveLocalNotification:notification];
}

```

## Uses in cordova project

Edit `www/js/index.js` and add the following code inside `onDeviceReady` function



```js
var data = {};

data["eventId"] = "25";

data["identity"] = "<Login identity>";  // provide “” or primary key defined on smartech panel

data["applicationId"] = "<ApplicationId>";  // provide AppId which you get from Smartech panel

data["group"] = "<App Group>"

smartech.track(data);
```



For Activity Tracking, Add below js code for track activity where activity performed:

```js
var data = {};

data["eventId"] = "<EventId>";  // compulsory field

smartech.track(data);
```

For Deep Linking, add below JS listener:
```js
var listener = function( e ) {
// Add Your code here
// Get data from e which is json object
alert("handleNotificationOpenAction : " + e.strType);
}
window.broadcaster.addEventListener( "handleNotificationOpenAction", listener);
```

****Note:****

****For Event Id:**** EventId is mandatory field to track Activity (get from Smartech Panel).

For profile update, login and logout, eventId must be 0, 22 and 23 respectively



****For identity :**** pass identity in data with key “identity” if identity is present



****For payload :**** pass payload in data with key “payload” if payload is required

****Format of  payload :**** Payload must be in below format as a Json object containing array of json Objects

'{"payload":[{--data here--}]}



****For profile :**** pass profile details in data with key “profile” if profile build event called

****Format of profile :****  profile must be in below format as a Json object with key must be in Capital.

{“NAME":"SSI","MOBILE":9768362862,"CITY":"Mumbai","AGE":28}

------

****App can be tested for push notifications only with the help of Distribution APN profile.****
