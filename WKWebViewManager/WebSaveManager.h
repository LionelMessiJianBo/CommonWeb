//
//  WebSaveManager.h
//  SouFun
//
//  Created by fcs on 2020/2/8.
//  Copyright © 2020 房天下 Fang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebSaveManager : NSObject<NSCoding>

@property(nonatomic,strong)NSMutableDictionary *saveData;

+ (NSString *)systemMsgCachePath;

@end

NS_ASSUME_NONNULL_END
