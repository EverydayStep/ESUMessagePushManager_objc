//
//  ESUMessagePushManager.m
//  ESUMessagePushManager_objc
//
//  Created by codeLocker on 2017/9/14.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import "ESUMessagePushManager.h"

@interface ESUMessagePushManager()<UNUserNotificationCenterDelegate>

@end

@implementation ESUMessagePushManager

+ (ESUMessagePushManager *)maanger {
    static ESUMessagePushManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ESUMessagePushManager alloc] init];
    });
    return manager;
}

- (void)registerUMessage:(NSString *)appKey launchOptions:(NSDictionary *)launchOptions allow:(void(^)(NSError *))allow reject:(void(^)(NSError *))reject  {
    if (!appKey || appKey.length == 0) {
        return;
    }
    [UMessage startWithAppkey:appKey launchOptions:launchOptions];
    [UMessage registerForRemoteNotifications];
    //仅在iOS 10 以上可使用
    if ([[UIDevice currentDevice] systemVersion].floatValue > 10) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNAuthorizationOptions type = UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound;
        [center requestAuthorizationWithOptions:type completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                //点击允许
                allow(error);
            } else {
                //点击不允许
                reject(error);
            }
        }];
    }
}

#pragma mark - UNUserNotificationCenterDelegate
//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(umessagePushManager:didReciveRemoteForegroundNotification:)]) {
            [self.delegate umessagePushManager:self didReciveRemoteForegroundNotification:notification];
        }
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        if (self.delegate && [self.delegate respondsToSelector:@selector(umessagePushManager:didReciveRemoteBackgroundNotification:)]) {
            [self.delegate umessagePushManager:self didReciveRemoteBackgroundNotification:response];
        }
        
    }else{
        //应用处于后台时的本地推送接受
    }
}
@end
