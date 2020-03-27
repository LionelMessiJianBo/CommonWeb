//
//  CCRequestManager.m
//  WeexDemo
//
//  Created by bjb on 2018/4/9.
//  Copyright © 2018年 taobao. All rights reserved.
//

#import "CCRequestManager.h"
#import "Reachability.h"
#import "NSString+Extension.h"


//网络请求超时时间(单位：秒)
#define NETWORK_REQUST_TIME_OUT 15

@interface CCRequestManager ()

@property (nonatomic, strong) AFHTTPSessionManager * _Nonnull httpSessionManager;

//网络数据请求任务集合
@property (nonatomic, strong) NSMutableArray *urlSessionTasks;

//自定义线程池
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end


@implementation CCRequestManager

static CCRequestManager* instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    }) ;
    return instance ;
}
+(id) allocWithZone:(struct _NSZone *)zone
{
    return [CCRequestManager shareInstance] ;
}
-(id) copyWithZone:(struct _NSZone *)zone
{
    return [CCRequestManager shareInstance] ;
}
-(AFHTTPSessionManager *)httpSessionManager{
    if (!_httpSessionManager) {
        //需要在建立 AFHTTPSessionManager的同时设置baseUrl
        _httpSessionManager = [AFHTTPSessionManager manager] ;
        //指定可接收服务器的数据的类型
        _httpSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //指定向服务器发送的数据的类型
        [_httpSessionManager.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        self.timeoutInterval = NETWORK_REQUST_TIME_OUT;
        _httpSessionManager.requestSerializer.timeoutInterval = self.timeoutInterval;
        //网络初始值默认为Unknown
        //        _networkStatus = NetworkReachabilityStatusUnknown;
        //        _httpSessionManager.securityPolicy.allowInvalidCertificates = YES;
        //        _httpSessionManager.securityPolicy.validatesDomainName = NO;
        //        if ([Connect_Host_Url containsString:@"https"]) {
//                    [_httpSessionManager setSecurityPolicy:[CCRequestManager customSecurityPolicy]];
        //        }
    }
    return _httpSessionManager;
}

+ (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"pdhz" ofType:@"cer"];//证书的路径
    
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certData, nil];
    
    return securityPolicy;
}
- (void)postHeadWithURLString:(NSString *_Nullable)urlString
                         head:(UIImage*_Nullable)head
                  requestBody:(NSDictionary *_Nullable)body
          uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                      success:(void(^_Nullable)(id  _Nullable responseObject))success
                      failurl:(void(^_Nullable)(NSError * _Nonnull error))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //    NSDictionary *dict = @{@"username":@"Saup"};
    
    //formData: 专门用于拼接需要上传的数据,在此位置生成一个要上传的数据体
    [manager POST:urlString parameters:body constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSData *data = UIImageJPEGRepresentation(head, 0.2);
        
        
        // 在网络开发中，上传文件时，是文件不允许被覆盖，文件重名
        // 要解决此问题，
        // 可以在上传时使用当前的系统事件作为文件名
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        
        //上传
        /*
         此方法参数
         1. 要上传的[二进制数据]
         2. 对应网站上[upload.php中]处理文件的[字段"file"]
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
         */
        [formData appendPartWithFileData:data name:@"img" fileName:fileName mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (uploadProgressBlock) {
            uploadProgressBlock( uploadProgress );
        }
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if( task.state != NSURLSessionTaskStateCanceling ){
                    if( success ) {
                        success(responseObject);
                    }
                }else{
                    if( success ) {
                        success(nil);
                    }
                }
            });
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        
    }];
}

- (void)postApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                            requestBody:(NSString *_Nullable)body
                    uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                                success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                                failurl:(void(^_Nullable)(void))failure{
    
    //1、判断网络，无网络return。
    if( ![CCRequestManager networkReachibility] )
    {
        if( failure ){
            failure();
        }
        return;
    }
    //2、打开手机上网络请求提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLSessionTask *sessionTask = [self.httpSessionManager POST:urlString parameters:body progress:^(NSProgress * _Nullable uploadProgress) {
        
        if( uploadProgressBlock ){
            uploadProgressBlock(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        __block id response = responseObject;
        __block id result = nil;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             result = [[response gtm_stringByUnescapingFromURLArgument] objectFromJSONString_Ext];
            result = [response objectFromJSONString_Ext];
           
            dispatch_async(dispatch_get_main_queue(), ^{
                if( task.state != NSURLSessionTaskStateCanceling ){
                    if( success ) {
                        success(result);
                    }
                }else{
                    if( success ) {
                        success(nil);
                    }
                }
            });
            
        });
        
        [self removeUrlSessionTask:task];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        
        if( error.code != -999 ){  //任务被取消,则不弹出警告框
            //            [ZTool showAlertWithMessage:@"连接超时"];
        }
        if( failure )
        {
             failure();
        }
           
        
        [self removeUrlSessionTask:task];
    }];
    sessionTask.taskDescription = urlString;
    [self.urlSessionTasks addObject:sessionTask];
}
- (void)getApiSessionTaskWithURLString:(NSString *_Nullable)urlString
                   uploadProgressBlock:(void(^_Nullable)(NSProgress * _Nullable uploadProgress))uploadProgressBlock
                               success:(void(^_Nullable)(NSDictionary * _Nullable result))success
                               failurl:(void(^_Nullable)(void))failure{
    //1、判断网络，无网络return。
    if( [CCRequestManager networkReachibility] == NO )
    {
        if( failure )   failure();
        return;
    }
    //2、打开手机上网络请求提示
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionTask *sessionTask = [self.httpSessionManager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        if( downloadProgress ){
            uploadProgressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        __block id response = responseObject;
        __block id result = nil;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            result = [[response gtm_stringByUnescapingFromURLArgument] objectFromJSONString_Ext];
            result = [response objectFromJSONString_Ext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if( task.state != NSURLSessionTaskStateCanceling ){
                    if( success )  {
                        success(result);
                    }
                }else{
                    if( success )  {
                        success(nil);
                    }
                }
            });
            
        });
        
        [self removeUrlSessionTask:task];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        
        if( error.code != -999 ){  //任务被取消,则不弹出警告框
            //            [ZTool showAlertWithMessage:@"连接超时"];
        }
        if( failure )
        {
            failure();
        }
            
        
        [self removeUrlSessionTask:task];
    }];
    sessionTask.taskDescription = urlString;
    [self.urlSessionTasks addObject:sessionTask];
}
//判断网络状态
+ (BOOL )networkReachibility{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    NSString *net = @"WIFI";
    if (internetStatus == ReachableViaWiFi) {
         net = @"WIFI";
        return YES;
        
    }else if (internetStatus == ReachableViaWWAN){
        net = @"蜂窝数据";

        return YES;

    }else if (internetStatus == NotReachable){
        net = @"当前无网路连接";

        return NO;

    }else{

        return NO;

    }

}
//移除任务队列中的任务task
-(void)removeUrlSessionTask:(NSURLSessionTask *)task{
    if( [self.urlSessionTasks containsObject:task] ){
        [self.urlSessionTasks  removeObject:task];
    }
}
//字典转json

@end
