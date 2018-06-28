//
//  BaseRequestParmsModel.h
//  优汇圈商家
//
//  Created by yuhao on 2017/4/6.
//  Copyright © 2017年 uhqsh. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * 基础数据请求
 */
@interface BaseRequestParmsModel : NSObject
+ (NSMutableDictionary *)baseGetInfoFacory:(NSMutableDictionary *)params;
@end
