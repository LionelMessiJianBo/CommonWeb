//
//  ViewController.m
//  TudiyunWeb
//
//  Created by fcs on 2019/7/31.
//  Copyright © 2019 fcs. All rights reserved.
//

#import "SouFangNormalWKViewController.h"
#import "WebViewManager.h"
//#import "SouFunUserBasicInfo.h"
//#import "SouFunNormalWKWebViewController.h"
//#import "PZLWURLRequestFilter.h"
//#import "UIView+TDYDynamicHudView.h"
//#import "NOSJJYPaymentOrderViewController.h"
//#import "SouFunAppDelegate.h"
//#import "SouFunTabBarController.h"
//#import "JJYProductDetailViewController_RebuildVersion.h"
//#import "JJYHouseManagementContainerVC.h"
#import "SouFangNormalViewModel.h"
//#import "SouFunProductDetailViewController.h"
//#import "UIBarButtonItem+FangBarButtonItem.h"
//#import "SouFunShareService.h"
//#import "UIToastView.h"
#import "KFYTool.h"
#import "SouFunScanViewCtrl.h"
#import "NSURLProtocol+WKWebView.h"
#import "MyURLProtocol.h"
#import "UIView+TDYDynamicHudView.h"
#import "SBYAppDelegate.h"
#import "WebSaveManager.h"
#import "FangToastView.h"
#import "SBYTabBarController.h"
#import "SBYAppDelegate.h"
#import "FangChat.h"
#import "FangChatControl.h"
#import "SouFunUserBasicInfo.h"

@interface SouFangNormalWKViewController ()<WebViewManagerDelegate,WKScriptMessageHandler>{
    
    BOOL _firstLoad;
    
}
@property (nonatomic,strong) WebViewManager *webViewManager;
@property (nonatomic, strong) SouFangNormalViewModel *viewModel;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, strong) NSDate *startDate;
@property(nonatomic,assign)BOOL finishSuccess;
@end

@implementation SouFangNormalWKViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [NSURLProtocol registerClass:[MyURLProtocol class]];
//    [NSURLProtocol wk_registerScheme:@"http"];
//    [NSURLProtocol wk_registerScheme:@"https"];
    if ((@available(iOS 11.0, *))) {
          if ([[SouFunUserBasicInfo sharedSouFunUserBasicInfo].webIntercept isEqualToString:@"on"]) {
              [NSURLProtocol wk_registerScheme:@"creisScheme"];
          }
          if ([SouFunUserBasicInfo sharedSouFunUserBasicInfo].webBlackList.count) {
              for (NSString *black in [SouFunUserBasicInfo sharedSouFunUserBasicInfo].webBlackList) {
                  if (black && black.length) {
                      [NSURLProtocol wk_registerScheme:black];
                  }
              }
          }
      }

//    [self.webViewManager deleteWebCache];

    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    _firstLoad = YES;
    [self.webViewManager webViewLoadUrl:self.webUrl];

    
}
- (void)backAction:(id)sender {
    if ([self.webViewManager.webView canGoBack]) {
        [self.webViewManager.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)shareAction:(id)sender {
//    UIImage *shareimag=[UIImage imageNamed:@"jjyIcon.png"];
//    NSData *shareimagdata=UIImageJPEGRepresentation(shareimag, 1);
//    SouFunShareService * shareService = [SouFunShareService sharedSouFunShareService];
//    shareService.shareOrigin = FangShareOriginalWebPage;
//    ShareDataModel * shareData = [[ShareDataModel alloc] init];
//    shareData.shareOrigin = FINANCE_LOAN_PLAN;
//    shareData.shareTitle = self.shareTitle;
//    shareData.shareShortContent = self.shareTitle;
//    shareData.shareContent = self.shareTitle;
//    shareData.wechatContent = self.shareTitle;
//    shareData.wechatCirleTitle = self.shareTitle;
//    shareData.shareImage = shareimag;
//    shareData.shareImageData = shareimagdata;
//    shareData.webURL = self.webViewManager.webView.URL.absoluteString;
//
//    //抖房房争霸赛
//    if ([shareData.webURL containsString:@"shakehouse.hd?m=personalStyle"]) {
//        NSString *bid = [SouFunUserBasicInfo sharedSouFunUserBasicInfo].customerid;
//        shareData.webURL = [NSString stringWithFormat:@"%@&bid=%@", shareData.webURL, bid];
//    }
//
//
//    //对“邀请下载”的分享链接的特殊处理
//    if (self.isInvite) {
//        SouFunUserBasicInfo *userInfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
//        NSString *text = [NSString stringWithFormat:@"经纪人%@邀请您下载房天下APP，实时关注我的房源变动", userInfo.agentname];
//        //微信好友 - 主标题
//        shareData.shareTitle = text;
//        //微信好友 - 副标题
//        shareData.wechatContent = self.shareTitle;
//        //微信朋友圈 - 标题
//        shareData.wechatCirleTitle = text;
//        //链接 - url
//        shareData.webURL = self.inviteShareLink;
//    } else if (self.isTuPaiYuGao) {
//        NSString *tupaiShareTitle = @"土拍预告";
//        //微信好友 - 主标题
//        shareData.shareTitle = tupaiShareTitle;
//        //微信好友 - 副标题
//        shareData.wechatContent = tupaiShareTitle;
//        //微信朋友圈 - 标题
//        shareData.wechatCirleTitle = tupaiShareTitle;
//    }
//
//    if ([shareData.webURL isEqualToString:@""] || shareData.webURL == nil) {
//        [UIToastView showToastViewWithContent:@"请等待页面加载完成之后再分享" andRect:CGRectMake(40, 100, SCREEN_WIDTH - 40*2, 50) andTime:3.0f andObject:self];
//        return;
//    }
//    [shareService showPanelInViewController:self andShareModel:shareData];
}
- (void)reloadAction:(id)sender {
    
//    SouFunUserBasicInfo *userInfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
//    if (self.setCookies && userInfo.sfut_cookie) {
//        [self.webViewManager addCookies];
//        if (self.businessType == NormalSFNadibangType ) {
//            [self.webViewManager add3fangCookies];
//        }
//    }
    [self.webViewManager webViewLoadUrl:self.webUrl];
}
- (void)hideLoadingAnimation{
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:self.startDate];
    NSString *timeStr = [NSString stringWithFormat:@"%f",time];
    if (timeStr && timeStr.length > 2) {
        timeStr = [timeStr substringToIndex:2];
    }
//    if ([timeStr integerValue] == 10 || [timeStr isEqualToString:@"na"]) {
        [self.view hideTdyActivityViewAtCenter];

//    }
//    [self.view hideTdyActivityViewAtCenter];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    [self.webViewManager resetFrame:self.view];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.isJJYDX) {
        [super.navigationController setNavigationBarHidden:YES animated:YES];
        
    }
    if (self.tabTitle) {
      
        if (_firstLoad) {
            _firstLoad = NO;
            if (!self.finishSuccess ) {
                [self.webViewManager reloadWebView];
            }
        }else{
            if (!self.finishSuccess ) {
                [self.webViewManager reloadWebView];
            }
        }
        if (!self.finishSuccess) {
            [self.view showTdyActivityViewAtCenter];

        }
    }else{
        if (!self.finishSuccess) {
            [self.view showTdyActivityViewAtCenter];

        }
    }
    self.startDate = [NSDate date];
    [self performSelector:@selector(hideLoadingAnimation) withObject:nil afterDelay:10];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [KFYTool screenDirection:NO];
    if (self.isJJYDX) {
        [super.navigationController setNavigationBarHidden:NO animated:YES];
    }
    self.startDate = nil;
    [self.view hideTdyActivityViewAtCenter];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    

}
-(void)dealloc{
    
    [self.viewModel removeScriptMessageHandler:_webViewManager];
    [NSURLProtocol unregisterClass:[MyURLProtocol class]];
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
    [_webViewManager.webView removeFromSuperview];
    _webViewManager = nil;
}
#pragma mark - webViewManager delegate
-(void)webViewManager:(WebViewManager *)webViewManager webViewTitleDidChange:(NSString *)title{
    self.title = title;
    self.shareTitle = title;
    if ([self.shareTitle isEqualToString:@""] || self.shareTitle == nil) {
        self.shareTitle = @"来自经纪云经纪人软件";
    }
    if (self.tabTitle) {
        self.title = self.tabTitle;
    }
}

-(void)webViewManagerLoadingDidFailed:(WebViewManager *)webViewManager navigation:(null_unspecified WKNavigation *)navigation error:(NSError *)error{
    
    [self.view hideTdyActivityViewAtCenter];

    NSURL *url = [error.userInfo objectForKey:@"NSURLErrorFailingURLStringErrorKey"];
    if ([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102 && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
    
    if ([[error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey] isEqualToString:@"soufun:"]) {
        return;
    }
    //特殊errorCode  过滤 -999
    if (error.code==NSURLErrorCancelled) {
        return;
    }
//    [UIToastView showToastViewWithContent:@"网络请求超时，请稍候重试" andRect:CGRectMake(40, 100, SCREEN_WIDTH - 40*2, 50) andTime:3.0f andObject:self];
    
//    if (self.businessType == NormalSFNadibangType) { //拿地帮加载失败，显示导航栏
//        [super.navigationController setNavigationBarHidden:NO animated:YES];
//        //隐藏动画
//        [self.view hideTdyActivityViewAtCenter];
//    }
}

- (void)webViewManagerLoadingDidFinished:(WebViewManager *)webViewManager
{
//    if (self.businessType == NormalSFNadibangType) {
//        [self.view hideTdyActivityViewAtCenter];
//    }
    //    [self getCookie];
//    [self.viewModel addScriptMessageHandler:self.webViewManager controller:self];
    
    NSLog(@"webViewManagerLoadingDidFinished");

//   [self.view hideTdyActivityViewAtCenter];
    
}
- (void)webViewManagerLoadingDidCommit:(WebViewManager *)webViewManager{

}




-(void)webViewManager:(WebViewManager *)webViewManager webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    NSURL *url = navigationAction.request.URL;
//    //充值活动跳转到支付页
//    if ([url absoluteString] != nil || [url absoluteString].length != 0) {
//        if ([url.absoluteString hasPrefix:@"soufunagent://openpay/buyreport/passportid="]) {
//            SouFunUserBasicInfo *userInfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
//            NSString *passportId = [url.absoluteString substringFromIndex:[@"soufunagent://openpay/buyreport/passportid=" length]];
//            if ([userInfo.userid isEqualToString:passportId]) {
//#pragma mark - 5.6.5 跳转到新版购买搜房帮页面
//                SouFunProductDetailViewController *vc = [[SouFunProductDetailViewController alloc]init];
//                vc.titleID = @"1";//搜房帮购买页面
//                vc.isFromWeb = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//
//    }
}
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"body:%@ name::::::%@",message.body,message.name);
    if (!self.finishSuccess) {
        self.finishSuccess = YES;

    }
    NSString *name = message.name;
    id body = [KFYTool dictionaryWithJsonString:message.body];

    if ([name isEqualToString:@"openView"]) {
        
        [self openView:[KFYTool safeString:message.body]];
        
    }else if ([name isEqualToString:@"openView2"]){
        [self openView2:body];

    }
    else if ([name isEqualToString:@"productDetailGoBack"]){
        [self productDetailGoBack:body];

    }else if ([name isEqualToString:@"selectCityConfirm"]){
        
        [self selectCityConfirm:body];
        
    }else if ([name isEqualToString:@"invokePay"]){
        
        [self invokePay:body];
        
    }else if ([name isEqualToString:@"gotoMine"]){
        
        [self gotoMine:body];
        
    }else if ([name isEqualToString:@"toBuyTxqk"]){
        
        [self toBuyTxqk:body];

    }else if ([name isEqualToString:@"toSettingPromotePage"]){
        
        [self toSettingPromotePage:body];
        
    }else if ([name isEqualToString:@"getLocationInfo"]){
        
        [self.viewModel startLocationAction:self.webViewManager];

        
    }else if ([name isEqualToString:@"closeLoading"]){
        [self closeLoading:body];

    }else if ([name isEqualToString:@"uploadImageToServer"]){
        
        [self uploadImageToServer:body];
    }else if ([name isEqualToString:@"sendAppShareInfo"]){
        [KFYTool screenDirection:NO];
        [self portraitResetFrame];

        [self sendAppShareInfo:body];
    }else if ([name isEqualToString:@"finishBrowser"]){
        //关闭网页
        [KFYTool screenDirection:NO];

        [self.navigationController popViewControllerAnimated:YES];
        
    }else if ([name isEqualToString:@"scanQRCode"]){
        //扫码
        [self scanQRCode:body];
        
    }else if ([name isEqualToString:@"openLoading"]){
        [self openLoading];
    }else if ([name isEqualToString:@"goBack"]){
        [KFYTool screenDirection:NO];
    }else if ([name isEqualToString:@"logoutCreisApp"]){
        [self loginOut:@{}];
    }else if ([name isEqualToString:@"setCreisData"]){
        NSDictionary *setBody = [KFYTool dictionaryWithJsonString:message.body];

        if (setBody.allKeys.count) {
            NSString *key = setBody.allKeys.firstObject;
            id saveData = message.body;
            if (saveData) {
                WebSaveManager *webSaveManager = [NSKeyedUnarchiver unarchiveObjectWithFile:[WebSaveManager systemMsgCachePath]];
               if (!webSaveManager) {
                   webSaveManager = [[WebSaveManager alloc] init];
               }
                [webSaveManager.saveData setObject:saveData forKey:key];
                [NSKeyedArchiver archiveRootObject:webSaveManager toFile:[WebSaveManager systemMsgCachePath]];
            }
        }
        
    }else if ([name isEqualToString:@"getCreisData"]){
        WebSaveManager *webSaveManager = [NSKeyedUnarchiver unarchiveObjectWithFile:[WebSaveManager systemMsgCachePath]];
        if (webSaveManager) {
             NSString *key = message.body;
            id saveData = webSaveManager.saveData[key];
            saveData = [KFYTool replaceWithData:[KFYTool safeString:saveData]];
            NSString * evaluatStr = [NSString stringWithFormat:@"getCreisData(\'%@\')",@""];
            [self.webViewManager evaluateJavaScript:evaluatStr];
        }else{
           NSString * evaluatStr = [NSString stringWithFormat:@"getCreisData(\'%@\')",@""];
            [self.webViewManager evaluateJavaScript:evaluatStr];
        }
    }else if ([name isEqualToString:@"setCreisData2"]){
        NSDictionary *setBody = [KFYTool dictionaryWithJsonString:message.body];

        if (setBody.allKeys.count) {
            NSString *key = setBody.allKeys.firstObject;
            id saveData = message.body;
            if (saveData) {
                WebSaveManager *webSaveManager = [NSKeyedUnarchiver unarchiveObjectWithFile:[WebSaveManager systemMsgCachePath]];
               if (!webSaveManager) {
                   webSaveManager = [[WebSaveManager alloc] init];
               }
                NSString *saveStr = setBody[key];
                
                [webSaveManager.saveData setObject:saveStr forKey:key];
                [NSKeyedArchiver archiveRootObject:webSaveManager toFile:[WebSaveManager systemMsgCachePath]];
            }
        }
        
    }else if ([name isEqualToString:@"getCreisData2"]){
        WebSaveManager *webSaveManager = [NSKeyedUnarchiver unarchiveObjectWithFile:[WebSaveManager systemMsgCachePath]];
//        NSString *saveStr = @"";
//        NSDictionary *dic = @{@"historyCityLists":@[@{@"cityId":@"A1168B5F-0BC2-4151-BD7F-6D55BFB4BB1F",@"region":@"华东",@"cityCode":@"371400",@"hasAuth":@"1",@"province":@"山东省",@"hot":@"0",@"fatherCode":@"D",@"cityName":@"333"}]};
//        saveStr = [KFYTool dicTOjsonString:dic];
        if (webSaveManager) {
             NSString *key = message.body;
            id saveData = webSaveManager.saveData[key];
            NSString * evaluatStr = [NSString stringWithFormat:@"getCreisData2(\'%@\')",saveData?saveData:@""];
            [self.webViewManager evaluateJavaScript:evaluatStr];
        }else{
           NSString * evaluatStr = [NSString stringWithFormat:@"getCreisData2(\'%@\')",@""];
            [self.webViewManager evaluateJavaScript:evaluatStr];
        }
    }
    else if ([name isEqualToString:@"setRequestedOrientation"]){
        BOOL landscape = NO;
        if ([[KFYTool safeString:message.body]isEqualToString:@"0"]) {
          landscape = YES;
            [self landscapeResetFrame];

        }else{
            [self portraitResetFrame];

        }
        [KFYTool screenDirection:landscape];
    }else if ([name isEqualToString:@"creisCallTel"]){
        [self creisCallTel:message.body];
    }else if ([name isEqualToString:@"openMapAppNav"]){
        
        [KFYTool navigationToEnd:CLLocationCoordinate2DMake(39.92701200, 116.42768000) endAddress:@"北京东城区南弓匠营胡同1号楼"];

    }else if ([name isEqualToString:@"sendIMHouseDetailCard"]){
        
        [self sendIMHouseDetailCard:body];
        
    }else if ([name isEqualToString:@"openIMChatList"]){
        SBYAppDelegate *appDelegate = (SBYAppDelegate *)[UIApplication sharedApplication].delegate;
        SBYTabBarController *tabBarVC = (SBYTabBarController *)appDelegate.rootnavCtrl.viewControllers[0];
        [tabBarVC setSelectedIndex:1];
    }else if ([name isEqualToString:@"reload"]){
        
        [self.view showTdyActivityViewAtCenter];
        self.startDate = [NSDate date];
        [self performSelector:@selector(hideLoadingAnimation) withObject:nil afterDelay:10];
        [self.webViewManager reloadWebView];
        
    }else if ([name isEqualToString:@"clearH5Cache"]){
        [self.webViewManager deleteWebCache:NO];
    }else if ([name isEqualToString:@"clearH5CacheAndReload"]){
        
        [self.view showTdyActivityViewAtCenter];
        self.startDate = [NSDate date];
        [self performSelector:@selector(hideLoadingAnimation) withObject:nil afterDelay:10];
        [self.webViewManager deleteWebCache:YES];
    }
}
- (void)creisCallTel:(NSString *)phoneNumber{
    NSString *number = phoneNumber;
    NSString *device = [UIDevice currentDevice].model;
    if ([device isEqualToString:@"iPhone"]) {
        number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
        number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
        number = [number stringByReplacingOccurrencesOfString:@"转" withString:@""];
        
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]];
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:url options:@{} completionHandler:nil];
        } else {
            [application openURL:url];
        }
    } else {
        [FangToastView showText:@"设备不支持该功能" forView:self.view];
    }
}
- (void)sendIMHouseDetailCard:(NSDictionary *)body{
    FangChatDBMessage *message = [FangChatDBMessage new];
    NSDictionary *msgContent = body[@"msgContent"];
    
    message.messageID = [KFYTool safeString:msgContent[@"chatUserName"]];
   NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[KFYTool safeString:body[@"command"]] forKey:FangChat_Word_command];
    [[[FangChatControl shareControl]getSupportUI:dictionary] sessionCellClick:message];
           
    NSString * houseid = [KFYTool safeString:msgContent[@"houseid"]]?[KFYTool safeString:msgContent[@"houseid"]]:@"";
    NSString * obtainRentalType = @"cz";
    NSString * city = [KFYTool safeString:msgContent[@"city"]]?[KFYTool safeString:msgContent[@"city"]]:@"";
    NSString * imageurl = [KFYTool safeString:msgContent[@"imageurl"]]?[KFYTool safeString:msgContent[@"imageurl"]]:@"";
    NSString * projname = [KFYTool safeString:msgContent[@"projname"]]?[KFYTool safeString:msgContent[@"projname"]]:@"";
    NSString * room = [KFYTool safeString:msgContent[@"room"]]?[KFYTool safeString:msgContent[@"room"]]:@"";
    NSString * hall = [KFYTool safeString:msgContent[@"hall"]]?[KFYTool safeString:msgContent[@"hall"]]:@"";
    NSString * empty = @"";
    NSString * buildarea = [KFYTool safeString:msgContent[@"buildarea"]]?[KFYTool safeString:msgContent[@"buildarea"]]:@"";
    NSString * price = [KFYTool safeString:msgContent[@"price"]]?[KFYTool safeString:msgContent[@"price"]]:@"";
    NSString * agentid = [KFYTool safeString:msgContent[@"agentid"]]?[KFYTool safeString:msgContent[@"agentid"]]:@"";
    NSString * wxsfb = @"wxsfb";
    NSString * purpose = [KFYTool safeString:msgContent[@"purpose"]]?[KFYTool safeString:msgContent[@"purpose"]]:@"";
    NSString * verifyCode = [KFYTool safeString:msgContent[@"verifyCode"]]?[KFYTool safeString:msgContent[@"verifyCode"]]:@"";
    NSString * houseshareurl = [KFYTool safeString:msgContent[@"url"]]?[KFYTool safeString:msgContent[@"url"]]:@"";
    houseshareurl = [houseshareurl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];


    NSString *tmpStr = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@",houseid,obtainRentalType,city,imageurl,projname,room,hall,empty,buildarea,price,agentid,wxsfb,purpose,verifyCode,houseshareurl];

//           NSString *str = @"经纪人为您推荐:有套中国白沟绿色食品城39万元/套30平米的房源可能符合您的要求,问问(null)刘欣甜";
    NSString *str = [NSString stringWithFormat:@"经纪人为您推荐:有套%@%@%@%@居%@平米的房源可能符合您的要求,问问%@%@",projname,price,@"",room ,buildarea,[SouFunUserBasicInfo sharedSouFunUserBasicInfo].comname,[SouFunUserBasicInfo sharedSouFunUserBasicInfo].agentname];

           NSString *projcode = [KFYTool safeString:msgContent[@"projcode"]];
           tmpStr = [NSString stringWithFormat:@"%@;%@;%@",tmpStr,str,projcode];
           NSDictionary *contentDic = @{@"buildarea":buildarea,@"city":city,@"houseid":houseid,@"housetype":[KFYTool safeString:msgContent[@"housetype"]],@"imageurl":imageurl,@"price":price,@"projcode":projcode,@"projname":projname,@"purpose":purpose,@"type":[KFYTool safeString:msgContent[@"type"]],@"url":houseshareurl};
           NSString *contentStr = [FangChatHelper fangChatParseStringFromObject:contentDic];
           [[FangChatManager shareFangChatManager] fangChatManagerSendAndOperationCustomeMessage:tmpStr MsgContent:contentStr Command:[KFYTool safeString:body[@"command"]] Purpose:nil Typeid:[KFYTool safeString:body[@"typeid"]] HouseType:nil SendTo:nil GroupID:nil Operation:YES StatusNotification:nil];
}
- (void)portraitResetFrame{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    self.webViewManager.webView.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(FIT_STATUSBAR_HEIGHT, 0,  FIT_BOTTOMSAFE_HEIGHT, 0));

}
- (void)landscapeResetFrame{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    self.webViewManager.webView.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, 0, 0));
}
- (void)loginOut:(NSDictionary *)dic{
    
    [KFYTool loginOut];
}
- (void)scanQRCode:(NSDictionary *)body{
    
    SouFunScanViewCtrl *controller = [SouFunScanViewCtrl new];
//    controller.hidePhoto = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}
- (void)openLoading{
    [self.view showTdyActivityViewAtCenter];
}
- (void)openView:(NSString *)url{
    

    SouFangNormalWKViewController *controller = [SouFangNormalWKViewController new];
    controller.webUrl = url;
    controller.isJJYDX = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)openView2:(NSDictionary *)body{
    
    NSString *displayBrowserStr = body[@"options"][@"displayBrowserHeader"];
    NSString *url = body[@"url"];
    SouFangNormalWKViewController *controller = [SouFangNormalWKViewController new];
    controller.webUrl = url;
    if ([displayBrowserStr isEqualToString:@"1"]) {
        controller.isJJYDX = NO;

    }else{
        controller.isJJYDX = YES;

    }
    [self.navigationController pushViewController:controller animated:YES];
}
- (void)productDetailGoBack:(NSDictionary *)body{
    
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    //返回到上一级页面
    if (viewcontrollers.count>1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1] == self) {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}
- (void)invokePay:(NSDictionary *)body{
    
//    NOSJJYPaymentOrderViewController *checkVC = [[NOSJJYPaymentOrderViewController alloc]init];
//    checkVC.isJJYDX = YES;
//    checkVC.runo = body[@"orderid"];
//    [self.navigationController pushViewController:checkVC animated:YES];

}
- (void)gotoMine:(NSDictionary *)body{
    
//    SouFunAppDelegate *delegate = (SouFunAppDelegate *)[UIApplication sharedApplication].delegate;
//    SouFunTabBarController *tabBarVC = (SouFunTabBarController *)delegate.rootnavCtrl.viewControllers[0];
//    tabBarVC.selectedIndex = 3;
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)toBuyTxqk:(NSDictionary *)body{
    
//    JJYProductDetailViewController_RebuildVersion *productVC = [[JJYProductDetailViewController_RebuildVersion alloc]init];
//    productVC.productID = JJYProdectTypeTianXiaYunQianKe;
//    [self.navigationController pushViewController:productVC animated:YES];
}
- (void)toSettingPromotePage:(NSDictionary *)body{
    
    NSString *comarea = body[@"comarea"];  //商圈
    NSString *proj = body[@"proj"];        //楼盘
    //设置优推页面
//    JJYHouseManagementContainerVC *controller = [[JJYHouseManagementContainerVC alloc] init];
//    controller.listType = HouseListTypePreferPromoteSetList;
//    controller.rentalTypeArr = @[@"100"];
//    if (comarea && ![comarea isEqualToString:@""]) {
//        controller.selectedComera = comarea;
//    }
//    if (proj && ![proj isEqualToString:@""]) {
//        controller.selectedProj = proj;
//    }
//    [self.navigationController pushViewController:controller animated:YES];
}

- (void)closeLoading:(NSDictionary *)body{
    [self.view hideTdyActivityViewAtCenter];

}
- (void)uploadImageToServer:(NSDictionary *)body{
    
    [self.viewModel chooseImage:self webViewManager:self.webViewManager imageCount:body[@""]];
}
- (void)selectCityConfirm:(NSDictionary *)body{
    
    if ([self.delegate respondsToSelector:@selector(souFangNormalWKViewController:selectInfo:)]) {
        [self.delegate souFangNormalWKViewController:self selectInfo:body];
    }
    
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    if (viewcontrollers.count>1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1]==self) {
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (void)sendAppShareInfo:(NSDictionary *)body{
    
    [self.viewModel share:body controller:self];
}

-(void)relodBtnClick:(UIButton *)sender{
    [self.webViewManager reloadWebView];
}
-(WebViewManager *)webViewManager{
    if (!_webViewManager) {
        _webViewManager = [[WebViewManager alloc] init];
        [_webViewManager sendWebViewToSuperView:self.view withFrame:self.view.bounds controller:self];
        _webViewManager.delegate = self;
        _webViewManager.progressHidden = NO;
    }
    return _webViewManager;
}
-(SouFangNormalViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[SouFangNormalViewModel alloc] init];
    }
    return _viewModel;
}
- (NSDictionary * )replaceWithStr:(NSString * )str{
    str = [str stringByReplacingOccurrencesOfString:@"\r"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\t"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\a"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\b"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\f"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\v"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\\"withString:@""];
    
     NSMutableString *responseString = [NSMutableString stringWithString:str];
    NSString *characterStart = [responseString substringWithRange:NSMakeRange(0, 1)];
    if ([characterStart isEqualToString:@"\""]) {
        [responseString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    NSString *characterEnd = [responseString substringWithRange:NSMakeRange(responseString.length - 1, 1)];
    if ([characterEnd isEqualToString:@"\""]) {
        [responseString deleteCharactersInRange:NSMakeRange(responseString.length - 1, 1)];
    }
    
    
    
//    for (int i = 0; i < responseString.length; i ++) {
//        character = [responseString substringWithRange:NSMakeRange(i, 1)];
//        if ([character isEqualToString:@"\\"])
    //去掉\
//            [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//    }

    NSDictionary * dataDic = [KFYTool dictionaryWithJsonString:responseString];
    return dataDic;
}
@end


