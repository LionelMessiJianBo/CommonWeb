//
//  CCRequestManager.h
//  WeexDemo
//
//  Created by bjb on 2018/4/9.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
//网络状态枚举
typedef NS_ENUM(NSInteger,NetworkReachabilityStatus) {
    NetworkReachabilityStatusUnknown          = -1, //未知
    NetworkReachabilityStatusNotReachable     = 0,  //无网络
    NetworkReachabilityStatusReachableViaWWAN = 1,  //蜂窝网络
    NetworkReachabilityStatusReachableViaWiFi = 2,  //WIFI
};
@interface CCRequestManager : NSObject
/**
 网络超时时间
 */
@property (nonatomic) CGFloat timeoutInterval;
@property (nonatomic,readonly) NetworkReachabilityStatus networkStatus;
@property (nonatomic,strong) NSString *_Nullable netWorkName;

+(instancetype _Nullable ) shareInstance;
/**
 *  网络是否可用
 */
+ (BOOL )networkReachibility;

/*
 上传头像
 */
- (void)postHeadWithURLString:(NSString *_Nullable)urlString
                         head:(UIImage*_Nullable)head
                  requestBody:(NSDictionary *_Nullable)body
          uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                      success:(void(^_Nullable)(id  _Nullable responseObject))success
                      failurl:(void(^_Nullable)(NSError * _Nonnull error))failure;



- (void)postApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                            requestBody:(NSString *_Nullable)body
                    uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                                success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                                failurl:(void(^_Nullable)(void))failure;

- (void)getApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                   uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                               success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                               failurl:(void(^_Nullable)(void))failure;
@end
