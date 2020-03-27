//
//  SouFangNormalWKViewController.h
//  SouFun
//
//  Created by fcs on 2019/8/5.
//  Copyright © 2019 房天下 Fang.com. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "SouFunNormalUIWebViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class SouFangNormalWKViewController;

//代理协议
@protocol SouFangNormalWKViewControllerDelegate <NSObject>
@optional

/**
选择城市
 */
- (void)souFangNormalWKViewController:(SouFangNormalWKViewController *)souFangNormalWKViewController selectInfo:(NSDictionary *)selectInfo ;

@end
@interface SouFangNormalWKViewController : UIViewController

@property (nonatomic, copy) NSString *webUrl;
//@property (nonatomic, assign) NormalSFBusinessType businessType;
@property (nonatomic, assign) BOOL isJJYDX;
@property (nonatomic, assign) BOOL setCookies;
@property (nonatomic, assign) BOOL isHangyekuaixun;
@property (nonatomic, assign) BOOL isInvite;   //是否“邀请下载”
@property (nonatomic, assign) BOOL isTuPaiYuGao; //土拍直播 控制分享所需要的标题
@property (nonatomic, strong) NSString *inviteShareLink;   //“邀请下载”的分享链接
@property (nonatomic, copy) NSString *tabTitle;   
@property (nonatomic, weak) id<SouFangNormalWKViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
