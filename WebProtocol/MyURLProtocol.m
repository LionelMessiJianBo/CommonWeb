//
//  MyURLProtocol.m
//  WebViewTest
//
//  Created by sjpsega on 15/6/4.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import "MyURLProtocol.h"
//#import <CommonCrypto/CommonDigest.h>
//#import "NSURLRequest+CYLNSURLProtocolExtension.h"
#import <CoreServices/CoreServices.h>
//这个头必须加，防止请求重复，导致死循环
static NSString *WingTextURLHeader = @"Wing-Cache";

@implementation MyURLProtocol{
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{

    if([NSURLProtocol propertyForKey:@"MyURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    return [self checkUrl:request.URL.absoluteString];
}
+ (BOOL)checkUrl:(NSString *)absoluteString{
    
    NSString *fileName = [absoluteString stringByReplacingOccurrencesOfString:@"https://js.soufunimg.com" withString:@""];
    NSString *dirPath = [[NSBundle mainBundle] bundlePath];
    dirPath = [dirPath stringByAppendingPathComponent:@"WebSource"];
    dirPath = [dirPath stringByAppendingPathComponent:fileName];
//    BOOL existPath                  = [[NSFileManager defaultManager]fileExistsAtPath:dirPath];
    NSData *data = [NSData dataWithContentsOfFile:dirPath];
    if (data) {
        return YES;
    }else{
        return NO;
    }

}
+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
//    NSLog(@"request.HTTPBodyStream:%@",request.HTTPBodyStream);

//    return [request cyl_getPostRequestIncludeBody];
}

+(BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    
    return [super requestIsCacheEquivalent:a toRequest:b];
}

-(void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];

    [NSURLProtocol setProperty:@YES forKey:@"MyURLProtocolHandledKey" inRequest:newRequest];
    NSString *absoluteString        = newRequest.URL.absoluteString;

    NSString *fileName = [absoluteString stringByReplacingOccurrencesOfString:@"https://js.soufunimg.com" withString:@""];
    NSString *dirPath = [[NSBundle mainBundle] bundlePath];
    dirPath = [dirPath stringByAppendingPathComponent:@"WebSource"];
    dirPath = [dirPath stringByAppendingPathComponent:fileName];

    BOOL existPath                  = [[NSFileManager defaultManager]fileExistsAtPath:dirPath];
    if (existPath ) {
//        NSLog(@"dirPath:%@",dirPath);

        NSData *data = [NSData dataWithContentsOfFile:dirPath];
        if (data) {
 

//            NSLog(@"absoluteString:%@",absoluteString);

            NSString *type = [self getMimeTypeWithFilePath:dirPath];

            [self sendResponseWithData:data mimeType:type];
        }else{
            [self startWithSession:newRequest];
        }
        
    }else{
        [self startWithSession:newRequest];
    }
    
}
- (void)sendResponseWithData:(NSData *)data mimeType:(nullable NSString *)mimeType
{
    if (mimeType == nil) {
        mimeType = @"*/*";
    }
    NSMutableDictionary* responseHeaders = [[NSMutableDictionary alloc] init];
    responseHeaders[@"Cache-Control"] = @"no-cache";
    responseHeaders[@"Content-Type"] = mimeType;
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:super.request.URL
                                                          statusCode:200
                                                         HTTPVersion:@"HTTP/1.1"
                                                        headerFields:responseHeaders];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    if (data) {
        [[self client] URLProtocol:self didLoadData:data];
    }
    [[self client] URLProtocolDidFinishLoading:self];
}

- (NSString *)getMimeTypeWithFilePath:(NSString *)filePath{
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[filePath pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    
    //The UTI can be converted to a mime type:
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (type != NULL)
        CFRelease(type);
    
    return mimeType;
}
- (void)startWithSession:(NSMutableURLRequest *)newRequest{
    
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSArray *protocolArray = @[ [self class] ];
    configure.protocolClasses = protocolArray;
    self.session  = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.queue];
    self.task = [self.session dataTaskWithRequest:newRequest];
    [self.task resume];
}
- (void)stopLoading {
    //    NSLog(@"stopLoading");
    if (_session) {
        [self.session invalidateAndCancel];
        _session = nil;
    }
    
}
- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    return _queue;
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error != nil) {
        [self.client URLProtocol:self didFailWithError:error];
    }else
    {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //    NSLog(@"data:::::::%@",data);
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler
{
    completionHandler(proposedResponse);
}

//TODO: 重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest*    redirectRequest;
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:@"MyURLProtocolHandledKey" inRequest:redirectRequest];
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    [self.task cancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

@end
