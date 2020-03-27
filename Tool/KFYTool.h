//
//  KFYTool.h
//  SouFun
//
//  Created by fcs on 2019/8/19.
//  Copyright © 2019 房天下 Fang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KFYTool : NSObject

//根据内容返回尺寸
+ (CGSize)getTextWidthtextString:(NSString *)textString font:(UIFont *)font maxSize:(CGSize)size;

//字典转json
+ (NSString*)dicTOjsonString:(id)object;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
//返回文件类型
+(NSString *)fileType:(NSString *)fileUrl;

+(NSString*)safeString:(id)obj;
+ (void)setHeader:(NSMutableURLRequest *)request;
+ (UIViewController *)getCurrentViewController;

+ (void)homeEventStatisticsWithPageName:(NSString *)pageName EventName:(NSString *)eventName;
+ (void)removeLauchCache;
+ (void)showAlertWithMessage:(NSString *)message;
+ (void)setTextFieldPlaceholder:(UIColor *)placeholderColor textField:(UITextField *)textField;
+ (void)setTextFieldPlaceholder:(UITextField *)textField font:(nullable id)value;
+(void)loginOut;
+(void)screenDirection:(BOOL)rotation;
+ (NSString * )replaceWithData:(NSString * )str;
+ (void)navigationToEnd:(CLLocationCoordinate2D )endCoordinate endAddress:(NSString *)endAddress;
@end

NS_ASSUME_NONNULL_END
