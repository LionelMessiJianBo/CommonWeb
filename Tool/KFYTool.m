//
//  KFYTool.m
//  SouFun
//
//  Created by fcs on 2019/8/19.
//  Copyright © 2019 房天下 Fang.com. All rights reserved.
//

#import "KFYTool.h"
#import "UIDevice+IdentifierAddition.h"
#import "SouFunUserBasicInfo.h"
#import "SouFunPBService.h"
#import <objc/runtime.h>
#import "Utilities.h"
#import "ServiceManager.h"
#import "SouFunLogout.h"
#import "FangChat.h"
#import "UIToastView.h"
#import "JJYFrameworkManager.h"
#import "UIDevice+CCDevice.h"
#import "FangToastView.h"

@implementation KFYTool

+ (CGSize)getTextWidthtextString:(NSString *)textString font:(UIFont *)font maxSize:(CGSize)size{
    CGSize textSize = [textString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return textSize;
}
//json字符串格式化
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil  ) {
        return nil;
    }
    if (![jsonString isKindOfClass:[NSString class]]) {
        return (NSDictionary *)jsonString;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        return nil;
    }
    return dic;
}

+ (NSString*)dicTOjsonString:(id)object
{
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        //        CYXLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    //    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    //    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}
+(NSString *)fileType:(NSString *)fileUrl{
    NSString *type = [fileUrl componentsSeparatedByString:@"/"].lastObject;
    type = [type componentsSeparatedByString:@"."].lastObject;
    return type;
}
+(NSString*)safeString:(id)obj{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",obj];
    }
    if (!obj || [obj isKindOfClass:[NSNull class]] || ![obj isKindOfClass:[NSString class]]){
        return @"";
    }
    return obj;
}
+ (void)setHeader:(NSMutableURLRequest *)request{
    
    NSString * header2 = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    NSString * header4 = [NSString stringWithString:[[UIDevice currentDevice] SFAgentUniqueDeviceIdentifier]];
    
    NSString * imei7 = [SouFunUserBasicInfo sharedSouFunUserBasicInfo].ios7UDID;
    NSString * header1 = @"ios_sby";
    
    header1= [header1 stringByAppendingString:@"~"];
    header1=[header1 stringByAppendingString:[[UIDevice currentDevice] model]];
    header1= [header1 stringByAppendingString:@"~"];
    header1=[header1 stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
    
    [request setValue:header2 forHTTPHeaderField:@"version"];
    [request setValue:imei7 forHTTPHeaderField:@"imei"];
    [request setValue:imei7 forHTTPHeaderField:@"imei7"];
    [request setValue:@"notuse" forHTTPHeaderField:@"notuse"];
    [request setValue:@"ios_sby" forHTTPHeaderField:@"appname"];
    [request setValue:@"wifi" forHTTPHeaderField:@"posmode"];
     if ((@available(iOS 11.0, *))) {
           if ([[SouFunUserBasicInfo sharedSouFunUserBasicInfo].webIntercept isEqualToString:@"on"]) {
               [request setValue:@"creisScheme:" forHTTPHeaderField:@"requestProtocol"];

           }
       }
    SouFunUserBasicInfo *userinfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
    NSString *sfut_cookie = [self safeString:userinfo.sfut_cookie];
    [request setValue:sfut_cookie forHTTPHeaderField:@"sfut"];
    NSString *sfyt_cookie = [KFYTool safeString:userinfo.sfyt];
    [request setValue:sfyt_cookie forHTTPHeaderField:@"sfyt"];
    //    [request setValue:header1 forHTTPHeaderField:@"User-Agent"];
    
    
}

+ (UIViewController *)jsd_getRootViewController{
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");
    return window.rootViewController;
}

+ (UIViewController *)getCurrentViewController{
    
    UIViewController* currentViewController = [self jsd_getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
            
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                
                currentViewController = currentViewController.childViewControllers.lastObject;
                
                return currentViewController;
            } else {
                
                return currentViewController;
            }
        }
        
    }
    return currentViewController;
}
//根据不同身份调用方法 埋码
+ (void)homeEventStatisticsWithPageName:(NSString *)pageName EventName:(NSString *)eventName
{
    [[SouFunPBService sharedPBService] addEventTJ:eventName pageName:pageName eveType:E_Click extDic:nil];
//    [self judgeRoleWithBeforLoginBlock:^{
//        [[SouFunPBService sharedPBService] addEventTJ:eventName pageName:pageName eveType:E_Click extDic:nil];
//    } personalBlock:^{
//        [[SouFunPBService sharedPBService] addEventTJ:eventName pageName:pageName eveType:E_Click extDic:nil];
//    } enterpriseBlock:^{
//        [[SouFunPBService sharedPBService] addEventTJ:eventName pageName:pageName eveType:E_Click extDic:nil];
//    } visitorBlock:^{
//        [[SouFunPBService sharedPBService] addEventTJ:eventName pageName:pageName eveType:E_Click extDic:nil];
//    }];
}

+ (void)judgeRoleWithBeforLoginBlock:(void(^)(void))beforLoginBlock personalBlock:(void(^)(void))personalBlock enterpriseBlock:(void(^)(void))enterpriseBlock visitorBlock:(void(^)(void))visitorBlock
{
    SouFunUserBasicInfo *userInfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
    if ([[SouFunUserBasicInfo sharedSouFunUserBasicInfo].islogin isEqualToString:@"1"]) { //登录用户
        if ([userInfo.customerType isEqualToString:@"1"]) {//个人
            personalBlock();
        } else if ([userInfo.customerType isEqualToString:@"2"]) { //企业
            enterpriseBlock();
        } else { //游客
            visitorBlock();
        }
    } else { //登录前
        beforLoginBlock();
    }
    
}
+ (void)removeLauchCache {
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[pathsArray objectAtIndex:0] stringByAppendingString:@"/LaunchImages"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}
+ (void)showAlertWithMessage:(NSString *)message {
    
    UIView *contentView = [[UIApplication sharedApplication].keyWindow viewWithTag:10000];
    if(contentView)
    {
        [contentView removeFromSuperview];
        contentView = nil;
    }
    
    contentView = [[UIView alloc] init];
    
    contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    contentView.layer.cornerRadius = 3;
    contentView.layer.masksToBounds = YES;
    contentView.tag = 10000;
    [[UIApplication sharedApplication].keyWindow addSubview:contentView];
    
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    alertLabel.backgroundColor = [UIColor clearColor];
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.numberOfLines = 0;
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.font = [UIFont systemFontOfSize:15];
    alertLabel.text = message;
    [contentView addSubview:alertLabel];
    
    if( message && message.length )
    {
        CGSize size = [message sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        CGFloat width;
        if( size.width >  [UIApplication sharedApplication].keyWindow.bounds.size.width-80 )
        {
            width = [UIApplication sharedApplication].keyWindow.bounds.size.width-80;
        }
        else
        {
            width = size.width;
        }
        
        CGRect rect = [message boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil];
        contentView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
        contentView.bounds = CGRectMake(0, 0, width+30, rect.size.height+30);
        alertLabel.frame = CGRectMake(15, 15, width, rect.size.height);
    }
    
    [contentView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2];
}
+ (void)setTextFieldPlaceholder:(UIColor *)placeholderColor textField:(UITextField *)textField{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(textField, ivar);
    placeholderLabel.textColor = placeholderColor;
}
+ (void)setTextFieldPlaceholder:(UITextField *)textField font:(nullable id)value{
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(textField, ivar);
    placeholderLabel.font = value;
}
+(void)loginOut{
    SouFunUserBasicInfo *userInfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
       
       NSMutableDictionary *params = [NSMutableDictionary dictionary];
       [params setObject:@"exitapplicationByIphone" forKey:@"messagename"];
       if (userInfo.agentid) {
           [params setObject:userInfo.agentid forKey:@"agentid"];
       }
       if (userInfo.m_PushSettingStartTime) {
           [params setObject:userInfo.m_PushSettingStartTime forKey:@"time"];
       }
       if (userInfo.m_SwitchIsOpen) {
           [params setObject:[NSString stringWithFormat:@"%@",userInfo.m_PushSettingStartTime] forKey:@"pushstate"];
       }
       if (userInfo.verifyCode) {
           [params setObject:userInfo.verifyCode forKey:@"verifycode"];
       }
       if (userInfo.tuisongToken) {
           [params setObject:userInfo.tuisongToken forKey:@"token"];
       }
       [params setObject:@"1" forKey:@"logout"];
       NSString *url  = [UtilityHelper getInterfaceAndParamersUrl:INTERFACE_FOR_SPACE paramers:params];
       
       ServiceManager *moreManager =[ServiceManager sharedInstance];
       ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
       request.tag = SOUFUNREQUEST_TYPE_XML_LOGOUT;
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestCompleteForLogout:) name:NOTIFICATION_TYPE_XML_LOGOUT object:nil];
       [[[moreManager getMoreServices] getNetworkQueue] addOperation:request];
       [[moreManager getMoreServices] go];
       
}
+ (void)requestCompleteForLogout:(NSNotification *)sender {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TYPE_XML_LOGOUT object:nil];
    
    if([[sender object] isMemberOfClass:[NSError class]]) {
        
        if([(NSError*)[sender object] domain] != NetworkRequestErrorDomain || [(NSError*)[sender object] code] != ASIRequestCancelledErrorType) {
            NSInteger err = [(NSError*)[sender object] code];
            [self notifyListRequestFailedDoWith:err];
        }
        
    } else {
        
        if ([[sender object] isKindOfClass:[SouFunLogout class]]) {
            SouFunLogout *data = [sender object];
            if (![data.result isEqualToString:@"0"]) {
                
                //                [[SouFunIMChatService sharedChatService] endChatServiceSocket];// 退出聊天
                [[FChatSDK shareFChatSDK] endManager:^(NSString *status) {
                    [[SouFunUserBasicInfo sharedSouFunUserBasicInfo] logout];// 退出登录
                }];
                
                //                [[SouFunIMUserBasicInfo sharedIMUserBasicInfo] logout];
               
               if ([[SouFunUserBasicInfo sharedSouFunUserBasicInfo].customerType isEqualToString:@"1"])
               {
//                    [[SouFunIMChatService sharedChatService] endChatServiceWithSuccessBlock:^{
//                        [[SouFunUserBasicInfo sharedSouFunUserBasicInfo] logout];// 退出登录
//                    } andFailureBlock:^{
//                        [[SouFunIMChatService sharedChatService] endChatServiceSocket];// 退出聊天
//                        [[SouFunIMUserBasicInfo sharedIMUserBasicInfo] logout];
//                        [[SouFunUserBasicInfo sharedSouFunUserBasicInfo] logout];// 退出登录
//                    }];
                   [[FChatSDK shareFChatSDK] endManager:^(NSString *status) {
                       [[SouFunUserBasicInfo sharedSouFunUserBasicInfo] logout];// 退出登录
                   }];
                }else{
                    [[SouFunUserBasicInfo sharedSouFunUserBasicInfo] logout];
                }
//
                [SouFunUserBasicInfo sharedSouFunUserBasicInfo].customerType = @"";//再次置customertype
                [SouFunUserBasicInfo sharedSouFunUserBasicInfo].issuperlogin = @"";//再次置customertype
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[SouFunUserBasicInfo sharedSouFunUserBasicInfo].issuperlogin forKey:KEY_ISSUPERLOGIN];//addby黄雷 超级账号
                [self backToLoginView];
                
            }
            else {
                [UIToastView showToastViewWithContent:@"网络连接异常，退出登录失败，请重试" andRect:CGRectMake(60, 100, KSCREEN_WIDTH-60*2, 50) andTime:2.0f andObject:[self getCurrentViewController]];
            }
        }
    }
}

//网络请求超时
+ (void)notifyListRequestFailedDoWith:(NSInteger) errCode {
    if (errCode == ASIRequestTimedOutErrorType || errCode == ASIConnectionFailureErrorType) {
        [UIToastView showToastViewWithContent:@"网络连接超时，请稍候重试" andRect:CGRectMake(60, 100, KSCREEN_WIDTH-60*2, 50) andTime:2.0f andObject:[self getCurrentViewController]];
    }
}
+ (void)backToLoginView {
    [SouFunUserBasicInfo sharedSouFunUserBasicInfo].islogin = @"0";
    
    [[JJYFrameworkManager sharedInstance] toLoginFramework];
}
+(void)screenDirection:(BOOL)rotation{
    SBYAppDelegate *delegate = (SBYAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.imRotation = rotation;
    if (rotation) {
        //调用横屏代码
        [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
    }else{
        //切换到竖屏
        [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
    }
    
}
+ (NSString * )replaceWithData:(NSString * )str{
    
    str = [str stringByReplacingOccurrencesOfString:@"\r"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\t"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\a"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\b"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\f"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\v"withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\\"withString:@""];
    
     NSMutableString *responseString = [NSMutableString stringWithString:str];
//    NSString *characterStart = [responseString substringWithRange:NSMakeRange(0, 1)];
//    if ([characterStart isEqualToString:@"\""]) {
//        [responseString deleteCharactersInRange:NSMakeRange(0, 1)];
//    }
//    NSString *characterEnd = [responseString substringWithRange:NSMakeRange(responseString.length - 1, 1)];
//    if ([characterEnd isEqualToString:@"\""]) {
//        [responseString deleteCharactersInRange:NSMakeRange(responseString.length - 1, 1)];
//    }
//    for (int i = 0; i < responseString.length; i ++) {
//        character = [responseString substringWithRange:NSMakeRange(i, 1)];
//        if ([character isEqualToString:@"\\"])
    //去掉\
//            [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
//    }

    return responseString;
}
+ (void)navigationToEnd:(CLLocationCoordinate2D )endCoordinate endAddress:(NSString *)endAddress{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"导航将会跳转到第三方App" preferredStyle:UIAlertControllerStyleActionSheet];
       UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
       
       UIAlertAction *amap = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           [self jumpToAmap:endCoordinate];
       }];
       UIAlertAction *baidu = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           [self jumpToBaiduMap:endCoordinate];
       }];
       UIAlertAction *appleMap = [UIAlertAction actionWithTitle:@"Apple地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           [self jumpToAppleMap:endAddress];
       }];
       
       [alertVC addAction:cancel];
       [alertVC addAction:amap];
       [alertVC addAction:baidu];
       [alertVC addAction:appleMap];
       [[KFYTool getCurrentViewController] presentViewController:alertVC animated:YES completion:nil];
}
+ (void)jumpToAmap:(CLLocationCoordinate2D )endCoordinate {
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]){
       
        //坐标（经纬度)
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",@"商办云",@"soufunagent",endCoordinate.latitude, endCoordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@NO} completionHandler:nil];
    }else{
        [FangToastView showText:@"您的iPhone未安装高德地图，请进行安装！" forView:[KFYTool getCurrentViewController].view];

    }
}
+ (void)jumpToBaiduMap:(CLLocationCoordinate2D )endCoordinate {
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]){
       //坐标（经纬度)
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",endCoordinate.latitude, endCoordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @NO} completionHandler:nil];
    }else{
        //添加提示
        [FangToastView showText:@"您的iPhone未安装百度地图，请进行安装！" forView:[KFYTool getCurrentViewController].view];

    }
}
#pragma mark - 跳转到苹果地图
+ (void)jumpToAppleMap:(NSString *)endAddress {
    
    //这个判断其实是不需要的
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]){
        //MKMapItem 使用场景: 1. 跳转原生地图 2.计算线路
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        
        //地理编码器
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        //我们假定一个终点坐标，上海嘉定伊宁路2000号报名大厅:121.229296,31.336956
        [geocoder geocodeAddressString:endAddress completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark *endPlacemark  = placemarks.lastObject;
            
            //创建一个地图的地标对象
            MKPlacemark *endMKPlacemark = [[MKPlacemark alloc] initWithPlacemark:endPlacemark];
            //在地图上标注一个点(终点)
            MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endMKPlacemark];
            
            //MKLaunchOptionsDirectionsModeKey 指定导航模式
            //NSString * const MKLaunchOptionsDirectionsModeDriving; 驾车
            //NSString * const MKLaunchOptionsDirectionsModeWalking; 步行
            //NSString * const MKLaunchOptionsDirectionsModeTransit; 公交
            [MKMapItem openMapsWithItems:@[currentLocation, endMapItem]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
            
        }];
    }else{
        [FangToastView showText:@"您的iPhone未安装苹果地图，请进行安装！" forView:[KFYTool getCurrentViewController].view];

    }
    
}
@end
