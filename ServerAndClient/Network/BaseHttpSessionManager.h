//
//  BaseHttpSessionManager.h
//  优汇圈商家
//
//  Created by yuhao on 2017/4/6.
//  Copyright © 2017年 uhqsh. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface BaseHttpSessionManager : AFHTTPSessionManager

+(nonnull instancetype)shareManger;
+(nonnull instancetype)shareManagerAddToken;
-(nonnull NSURLSessionTask *)DefaultGET:(nonnull NSString *)URLString parameters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull))downloadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull error))failure;


-(nonnull NSURLSessionTask *)DefaultPOST:(nonnull NSString *)URLString parameters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;
-(nonnull NSURLSessionTask *)DefaultGETAddToken:(nonnull NSString *)URLString parameters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull))downloadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull error))failure;


-(nonnull NSURLSessionTask *)DefaultPOSTAddToken:(nonnull NSString *)URLString parameters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

/**
 *  为链接添加token
 *
 *  @param url 地址
 *
 *  @return 字符串
 */
+ (nonnull NSString *)addAccessToken:(nonnull NSString *)url;
/**
 *  get方法专用 拼接链接信息
 *
 *  @param compose 带入信息字典
 *  @param url     链接地址
 *
 *  @return 拼接完成链接  xxxx/xxx?xxx=xxx&yy=yy&zzzz=zzzzz
 */
+ (nonnull NSString *)getUrlCompose:(nonnull NSMutableDictionary *)compose withUrl:(nonnull NSString *)url;

/**
 *  拼接特殊id
 *
 *  @param especid 信息id
 *
 *  @return 拼接字符串
 */
+ (nonnull NSString *)getUrl:(nonnull NSString *)url addEspecid:(nonnull NSString *)especid;



/***************   Get方法链接拼接方法 start  *************************/
+ (nonnull NSString *)getUrl:(nonnull NSString *)url addEspecid:(nonnull NSString *)especid needToken:(Boolean) need params:(nonnull id)params;


/***************   Post方法链接拼接方法 start  *************************/
+ (nonnull NSString *)postUrl:(nonnull NSString *)url addEspecid:(nonnull NSString *)especid needToken:(Boolean) need;


/**
 取消所有HTTP请求
 */
-(void)cancelAllRequest;




/**
 取消指定URL的HTTP请求
 */
-(void)cancelRequestWithURL:(NSString *)URL;

/**
 实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
 */



















@end
