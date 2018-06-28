//
//  CommenHttpAPI.h
//  优汇圈商家
//
//  Created by yuhao on 2017/4/6.
//  Copyright © 2017年 uhqsh. All rights reserved.
//

#import "BaseHttpSessionManager.h"
#import "NetUrl.h"
@interface CommenHttpAPI : BaseHttpSessionManager

+(void)klLoginWithParemeters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull progress))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseobject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

+(void)KLRegistWithParemeters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull progress))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseobject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;
+(void)KLUPloadWithParemeters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull progress))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseobject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;
// 上传图片
+ (void)uploadWithURLString:(NSString *)URLString
                 parameters:(id)parameters
                 uploadData:(NSData *)uploadData
                 uploadName:(NSString *)uploadName
                    success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success
                    failure:(void (^)(NSError *))failure;
@end
