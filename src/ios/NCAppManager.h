//
//  NCAppManager.h
//  NetCoreiOSPlugin
//
//  Created by Kamalkumar Jha on 7/28/18.
//  Copyright © 2018 Kamalkumar Jha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>
#import <NetCorePush/NetCorePush.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NCAppManager : CDVPlugin

+(NCAppManager *)sharedInstance;

-(void)setAppLaunchOptions:(NSDictionary *)launchOptions;
-(void)setNotificationDeviceToken:(NSData *)token;

// Cordova Triggred Methods
-(void)track:(CDVInvokedUrlCommand*)command;

@end
