//
//  CustomURLSchemeHandler.m
//  WKScheme
//
//  Created by fcs on 2019/8/5.
//  Copyright © 2019 fcs. All rights reserved.
//

#import "CustomURLSchemeHandler.h"
#import <CoreServices/CoreServices.h>
#import "SouFunUserBasicInfo.h"

@implementation CustomURLSchemeHandler

//当 WKWebView 开始加载自定义scheme的资源时，会调用
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask
API_AVAILABLE(ios(11.0)){
    
    //加载本地资源
   
    NSMutableURLRequest *newRequest = [urlSchemeTask.request mutableCopy];

    [NSURLProtocol setProperty:@YES forKey:@"MyURLProtocolHandledKey" inRequest:newRequest];
    NSString *absoluteString        = newRequest.URL.absoluteString;
    NSLog(@"absoluteString::::::%@",absoluteString);
    NSString *fileName = [absoluteString stringByReplacingOccurrencesOfString:@"creisscheme://js.soufunimg.com" withString:@""];
    NSString *dirPath = [[NSBundle mainBundle] bundlePath];
    dirPath = [dirPath stringByAppendingPathComponent:@"WebSource"];
    dirPath = [dirPath stringByAppendingPathComponent:fileName];

    if ([self checkBlack:absoluteString blackList:[SouFunUserBasicInfo sharedSouFunUserBasicInfo].webBlackList]) {
        //黑名单
               NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/blackList.js",[[NSBundle mainBundle] bundlePath]]];
               NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL
                                                                   MIMEType:[self getMimeTypeWithFilePath:dirPath]
                                                      expectedContentLength:data.length
                                                           textEncodingName:nil];
               [urlSchemeTask didReceiveResponse:response];
               [urlSchemeTask didReceiveData:data];
               [urlSchemeTask didFinish];
    }else{
        //文件不存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            [self netLoad:newRequest.URL.absoluteString urlSchemeTask:urlSchemeTask];
        } else {
            NSData *data = [NSData dataWithContentsOfFile:dirPath];
            if (data) {
                NSLog(@">>>>dirPath:%@",dirPath);
                NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL
                                                                    MIMEType:[self getMimeTypeWithFilePath:dirPath]
                                                       expectedContentLength:data.length
                                                            textEncodingName:nil];
                [urlSchemeTask didReceiveResponse:response];
                [urlSchemeTask didReceiveData:data];
                [urlSchemeTask didFinish];
            }else{
                [self netLoad:newRequest.URL.absoluteString urlSchemeTask:urlSchemeTask];

            }
            
        }
    }
    
}
- (void)netLoad:(NSString *)url urlSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask API_AVAILABLE(ios(11.0)){
    NSString *replacedStr = @"https";
    NSString *schemeUrl = url;
    schemeUrl = [schemeUrl stringByReplacingOccurrencesOfString:@"creisscheme" withString:replacedStr];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:schemeUrl]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        if (error) {
            [urlSchemeTask didFailWithError:error];
        } else {
            [urlSchemeTask didFinish];
        }
    }];
    [dataTask resume];
}
- (void)webView:(WKWebView *)webVie stopURLSchemeTask:(id)urlSchemeTask {
}

//根据路径获取MIMEType
- (NSString *)getMimeTypeWithFilePath:(NSString *)filePath {
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    
    //The UTI can be converted to a mime type:
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    
    return mimeType;
}
-(BOOL)checkBlack:(NSString *)originUrlString blackList:(NSArray *)blackList{
    BOOL isBlack = NO;
    if (blackList.count) {
        for (NSString * blackItem in blackList) {
            if (blackItem && blackItem.length && [originUrlString containsString:blackItem]) {
                isBlack = YES;
                break;
            }
        }
    }
    
    return isBlack;
}
@end
