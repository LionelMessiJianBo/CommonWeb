//
//  SouFangNormalViewModel.h
//  SouFun
//
//  Created by fcs on 2019/8/6.
//  Copyright © 2019 房天下 Fang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewManager.h"
#import "SouFangNormalWKViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SouFangNormalViewModel : NSObject



-(void)addScriptMessageHandler:(WebViewManager *)webViewManager controller:(id <WKScriptMessageHandler>)controller;

- (void)removeScriptMessageHandler:(WebViewManager *)webViewManager;
//定位
- (void)startLocationAction:(WebViewManager *)webViewManager;
//选择图片
- (void)chooseImage:(SouFangNormalWKViewController *)controller webViewManager:(WebViewManager *)webViewManager imageCount:(NSString *)imageCount;

- (void)share:(NSDictionary *)body controller:(SouFangNormalWKViewController *)controller;


@end

NS_ASSUME_NONNULL_END
