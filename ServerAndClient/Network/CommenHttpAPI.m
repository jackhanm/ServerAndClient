//
//  CommenHttpAPI.m
//  优汇圈商家
//
//  Created by yuhao on 2017/4/6.
//  Copyright © 2017年 uhqsh. All rights reserved.
//

#import "CommenHttpAPI.h"

@implementation CommenHttpAPI

+(void)klLoginWithParemeters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull progress))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseobject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure{
    NSLog(@"%@",[serverUrl stringByAppendingString:KLlogin ]);
    
     NSString *str= [NSString stringWithFormat:@"%@?username=%@&password=%@",[serverUrl stringByAppendingString:KLlogin],@"yuhao",@"123456"];
    [[self shareManger] DefaultPOST:str parameters:parameters progress:uploadProgress success:success failure:failure];
}

+(void)KLRegistWithParemeters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull progress))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseobject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    
    NSString *str= [NSString stringWithFormat:@"%@?username=%@&password=%@",[serverUrl stringByAppendingString:KLRegist],@"yuhao",@"123456"];
    [[self shareManger] DefaultPOST:str  parameters:parameters progress:uploadProgress success:success failure:failure];

}
+(void)KLUPloadWithParemeters:(nonnull id)parameters progress:(nonnull void (^)(NSProgress * _Nonnull progress))uploadProgress success:(nonnull void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseobject))success failure:(nonnull void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure
{
    
   
    [[self shareManger] DefaultPOST:[serverUrl stringByAppendingString:KLRegist]  parameters:parameters progress:uploadProgress success:success failure:failure];
    
}
#pragma mark -- 上传图片 --
+ (void)uploadWithURLString:(NSString *)URLString
                 parameters:(id)parameters
                 uploadData:(NSData *)uploadData
                 uploadName:(NSString *)uploadName
                    success:(void (^)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject))success
                    failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html",@"form", nil];
    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id< AFMultipartFormData >  _Nonnull formData) {
        [formData appendPartWithFileData:uploadData name:uploadName fileName:uploadName mimeType:@"image/png"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
           success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
