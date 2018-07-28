//
//  NCAppManager.m
//  NetCoreiOSPlugin
//
//  Created by Kamalkumar Jha on 7/28/18.
//  Copyright © 2018 Kamalkumar Jha. All rights reserved.
//

#import "NCAppManager.h"
#import <NetCorePush/NetCorePush.h>

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

NCAppManager *manager = nil;

@interface NCAppManager()<NetCorePushTaskManagerDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *identity;
@property (nonatomic, strong) NSString *group;

@end

@implementation NCAppManager
@synthesize launchOptions;
@synthesize deviceToken;
@synthesize applicationId;
@synthesize identity;
@synthesize group;

+(NCAppManager *)sharedInstance {
    if (manager == nil) {
        manager = [[NCAppManager alloc] init];
    }
    
    return manager;
}

-(void)setAppLaunchOptions:(NSDictionary *)launchOptions {
    self.launchOptions = launchOptions;
}

-(void)setNotificationDeviceToken:(NSData *)token {
    NSString * deviceTokenString = [[[[token description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    self.deviceToken = deviceTokenString;
    [[NetCoreInstallation sharedInstance] netCorePushRegisteration:self.deviceToken Block:^(NSInteger statusCode) {
        NSLog(@"Registration Status: %d",(int)statusCode);
    }];
}

-(void)registerDevice {
    [[NetCoreSharedManager sharedInstance] setUpAppGroup:self.group];
    [[NetCoreSharedManager sharedInstance] handleApplicationLaunchEvent:self.launchOptions forApplicationId:self.applicationId];
    [[NetCorePushTaskManager sharedInstance] setDelegate:self];
    
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    [[NetCorePushTaskManager sharedInstance] userNotificationdidReceiveNotificationResponse:response];
}

-(void)handleNotificationOpenAction:(NSDictionary *)userInfo DeepLinkType:(NSString *)strType {
    //TODO: Need to add code here
}

#pragma mark - Cordova Triggered Functions
#pragma mark - Cordova Triggered Functions
-(void)track:(CDVInvokedUrlCommand*)command {
    NSDictionary *trackableData = [[command arguments] objectAtIndex:0];
    int eventId = (int)trackableData[@"eventId"];
    
    if (eventId == 0) {
        [self updateProfile:trackableData[@"profile"] forIdentity:trackableData[@"identity"]];
    } else if (eventId == 22) {
        [self login:trackableData[@"identity"]];
    } else if (eventId == 23) {
        [self logout:trackableData[@"identity"]];
    } else  if (eventId == 25) {
        [self registerAppWithID:trackableData[@"applicationId"] Identity:trackableData[@"identity"] Group:trackableData[@"group"]];
    } else  {
        [self trackCustomEvent:eventId payload:trackableData[@"payload"]];
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
