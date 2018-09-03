
//  NCAppManager.m
//  NetCoreiOSPlugin
//
//  Created by Kamalkumar Jha on 7/28/18.
//  Copyright © 2018 Kamalkumar Jha. All rights reserved.
//

#import "NetCoreIOSCordovaSDK.h"
#import <NetCorePush/NetCorePush.h>

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NetCoreIOSCordovaSDK *manager = nil;

@interface NetCoreIOSCordovaSDK()<NetCorePushTaskManagerDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, strong) NSData *deviceToken;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *identity;
@property (nonatomic, strong) NSString *group;

@end

@implementation NetCoreIOSCordovaSDK
@synthesize launchOptions;
@synthesize deviceToken;
@synthesize applicationId;
@synthesize identity;
@synthesize group;

+(NetCoreIOSCordovaSDK *)sharedInstance {
    if (manager == nil) {
        manager = [[NetCoreIOSCordovaSDK alloc] init];
    }
    
    return manager;
}

-(void)setAppLaunchOptions:(NSDictionary *)launchOptions {
    self.launchOptions = launchOptions;
}

-(void)setNotificationDeviceToken:(NSData *)token {
    self.deviceToken = token;
    [[NetCoreInstallation sharedInstance] netCorePushRegisteration:self.identity withDeviceToken:token Block:^(NSInteger statusCode) {
        NSLog(@"Registration Status: %d",(int)statusCode);
    }];
}

-(void)registerDevice {
    if (self.applicationId != nil) {
        [[NetCoreSharedManager sharedInstance] setUpAppGroup:self.group];
        [[NetCoreSharedManager sharedInstance] handleApplicationLaunchEvent:self.launchOptions forApplicationId:self.applicationId];
    }
    
    if (self.deviceToken != nil) {
        [[NetCoreInstallation sharedInstance] netCorePushRegisteration:self.identity withDeviceToken:self.deviceToken Block:^(NSInteger statusCode) {
            NSLog(@"Registration Status: %d",(int)statusCode);
        }];
    }
    
    [[NetCorePushTaskManager sharedInstance] setDelegate:self];
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    [[NetCorePushTaskManager sharedInstance] userNotificationdidReceiveNotificationResponse:response];
}

-(void)handleNotificationOpenAction:(NSDictionary *)userInfo DeepLinkType:(NSString *)strType {
    NSDictionary *myInfo = @{@"strType":strType, @"userInfo":userInfo};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handleNotificationOpenAction" object:nil userInfo:myInfo];
}

#pragma mark - Cordova Triggered Functions
#pragma mark - Cordova Triggered Functions
-(void)track:(CDVInvokedUrlCommand*)command {
    NSDictionary *trackableData = [[command arguments] objectAtIndex:0];
    int eventId = [trackableData[@"eventId"] intValue];
    
    if (eventId == 0) {
        [[NetCoreIOSCordovaSDK sharedInstance] updateProfile:trackableData[@"profile"] forIdentity:trackableData[@"identity"]];
    } else if (eventId == 22) {
        [[NetCoreIOSCordovaSDK sharedInstance] login:trackableData[@"identity"]];
    } else if (eventId == 23) {
        [[NetCoreIOSCordovaSDK sharedInstance] logout:trackableData[@"identity"]];
    } else  if (eventId == 25) {
        [[NetCoreIOSCordovaSDK sharedInstance] registerAppWithID:trackableData[@"applicationId"] Identity:trackableData[@"identity"] Group:trackableData[@"group"]];
    } else  {
        [[NetCoreIOSCordovaSDK sharedInstance] trackCustomEvent:eventId payload:trackableData[@"payload"]];
    }
    
    NSString *trackingMessage = [NSString stringWithFormat:@"Tracking Done For %d", eventId];
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:trackingMessage];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - NetCore Methods
-(void)registerAppWithID:(NSString *)applicationId Identity:(NSString *)identity Group:(NSString *)group {
    [self setGroup:group];
    [self setApplicationId:applicationId];
    [self setIdentity:identity];
    [self registerDevice];
}

-(void)login:(NSString *)identity {
    [[NetCoreInstallation sharedInstance] netCorePushLogin:identity Block:nil];
    if (self.deviceToken != nil) {
        [[NetCoreInstallation sharedInstance] netCorePushRegisteration:self.identity withDeviceToken:self.deviceToken Block:^(NSInteger statusCode) {
            NSLog(@"Registration Status: %d",(int)statusCode);
        }];
    }
}

-(void)logout:(NSString *)identity {
    [[NetCoreInstallation sharedInstance] netCorePushLogout:nil];
}

-(void)updateProfile:(NSDictionary *)profile forIdentity:(NSString *)identity {
    [[NetCoreInstallation sharedInstance] netCoreProfilePush:identity Payload:profile Block:nil];
}

-(void)trackCustomEvent:(int)eventCode payload:(NSMutableArray *)payload {
    [[NetCoreAppTracking sharedInstance] sendAppTrackingEventWithCustomPayload:eventCode Payload:payload Block:nil];
}

@end
