//
//  ESUMessagePushManager.h
//  ESUMessagePushManager_objc
//
//  Created by codeLocker on 2017/9/14.
//  Copyright © 2017年 codeLocker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMessage_NOIDFA/UMessage.h>

@class ESUMessagePushManager;
@protocol ESUMessagePushManagerDelegate <NSObject>
/**
 iOS 10 系统下后台收到远程推送

 @param umessagePushManager manager
 @param notification 推送
 */
- (void)umessagePushManager:(ESUMessagePushManager *)umessagePushManager didReciveRemoteBackgroundNotification:(UNNotificationResponse *)notification;
/**
 iOS 10 系统下前台收到远程推送
 
 @param umessagePushManager manager
 @param response 推送
 */
- (void)umessagePushManager:(ESUMessagePushManager *)umessagePushManager didReciveRemoteForegroundNotification:(UNNotification *)response;
@end

@interface ESUMessagePushManager : NSObject

@property (nonatomic, weak) id<ESUMessagePushManagerDelegate> delegate;

+ (ESUMessagePushManager *)maanger;

/**
 注册推送

 @param appKey UMessage appKey
 @param launchOptions 启动参数
 @param allow 允许推送回调(需要系统版本10.0以上)
 @param reject 拒绝推送回调(需要系统版本10.0以上)
 */
- (void)registerUMessage:(NSString *)appKey launchOptions:(NSDictionary *)launchOptions allow:(void(^)(NSError *))allow reject:(void(^)(NSError *))reject;
@end
