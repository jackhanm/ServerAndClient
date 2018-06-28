//
//  JKAFNetTool.h
//  JKqyApp
//
//  Created by dllo on 15/12/15.
//  Copyright © 2015年 dllo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JKresponseStyle) {
    JKJSON,
    JKXMl,
    JkDATA,
};



typedef NS_ENUM(NSUInteger, JKrequestStyle) {
    JKrequestJSON,
    JKrequestString,
    
};

@interface JKAFNetTool : NSObject



/**
 *  get请求
 *
 *  @param url           请求网址
 *  @param body          body体
 *  @param headFile      请求头
 *  @param responseStyle 返回数据类型
 *  @param success       请求成功回调
 *  @param failure       请求失败回调
 */
+ (void)getNetWithURL:(NSString *)url body:(id)body headFile:(NSDictionary *)headFile responseStyle:(JKresponseStyle)responseStyle success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)PostNetWithURL:(NSString *)url
                  body:(id)body
             bodyStyle:(JKrequestStyle)requestStyle
              headFile:(NSDictionary *)headFile
         responseStyle:(JKresponseStyle)responseStyle
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
+ (void)uploadImageName:(NSString *)name;
+(void)uploadImage;
+ (void)postWithUrl:(NSString *)url  parameters:(id)parameters;
+ (void)uploadimageWithName:(NSString *)name URL:(NSString *)urlStr;
@end
