//
//  MyURLProtocol.h
//  WebViewTest
//
//  Created by sjpsega on 15/6/4.
//  Copyright (c) 2015年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MyURLProtocol : NSURLProtocol<NSURLSessionDelegate>

@property (atomic,strong,readwrite) NSURLSessionDataTask *task;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *queue;

@end
