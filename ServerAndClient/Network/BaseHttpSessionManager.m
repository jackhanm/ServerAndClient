//
//  BaseHttpSessionManager.m
//  优汇圈商家
//
//  Created by yuhao on 2017/4/6.
//  Copyright © 2017年 uhqsh. All rights reserved.
//

#import "BaseHttpSessionManager.h"

@implementation BaseHttpSessionManager
static NSMutableArray *_allSessionTask;

+(instancetype)shareManger{
    
//    static BaseHttpSessionManager *_manager=nil;
//    static dispatch_once_t predite;
//    dispatch_once(&predite, ^{
      BaseHttpSessionManager *_manager =  [BaseHttpSessionManager manager];
//        _manager=[self manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/x-json",@"text/html", nil];
//        [_manager.requestSerializer setTimeoutInterval:15];
    [_manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    _manager.requestSerializer.timeoutInterval = 8.f;
    [_manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        //_manager.requestSerializer=[AFJSONRequestSerializer serializer];
        // _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        _manager.requestSerializer=[AFHTTPRequestSerializer serializer];
        // 加上这行代码，https ssl 验证。
        //[_manager setSecurityPolicy:[self customSecurityPolicy]];
//    });
    return _manager;
    
    
}

+(instancetype)shareManagerAddToken{
    
//    static BaseHttpSessionManager *_managerAddToken=nil;
//    static dispatch_once_t predite;
//    dispatch_once(&predite, ^{
     BaseHttpSessionManager *_managerAddToken =  [BaseHttpSessionManager manager];
//        _managerAddToken=[self manager];
        _managerAddToken.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"application/x-json",@"text/html", nil];
    
        _managerAddToken.requestSerializer=[AFHTTPRequestSerializer serializer];
    [_managerAddToken.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    _managerAddToken.requestSerializer.timeoutInterval = 8.f;
    [_managerAddToken.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//        _managerAddToken.requestSerializer=[AFJSONRequestSerializer serializer];
    
//        _managerAddToken.requestSerializer=[AFHTTPRequestSerializer serializer];
//         _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 加上这行代码，https ssl 验证。
        //[_manager setSecurityPolicy:[self customSecurityPolicy]];
//    });
    return _managerAddToken;
    
    
}

/**
 存储着所有的请求task数组
 */
-(NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}

-(NSURLSessionTask *)DefaultGET:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))downloadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@",URLString );

   NSURLSessionTask *sessionTask = [[BaseHttpSessionManager shareManger] GET:URLString parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(task,responseObject);
       [[self allSessionTask] removeObject:task];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(task,error);
        [[self allSessionTask] removeObject:task];
    }];
    
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
    
}

-(NSURLSessionTask *)DefaultPOST:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    
    
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@",URLString );
    
    
    NSURLSessionTask *sessionTask = [[BaseHttpSessionManager shareManger] POST:URLString parameters:parameters progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[self allSessionTask] removeObject:task];
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[self allSessionTask] removeObject:task];
        failure(task,error);
    }];
    // 添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;

}
-(NSURLSessionTask *)DefaultGETAddToken:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))downloadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@",URLString );

    NSURLSessionTask *sessionTask =[[BaseHttpSessionManager shareManagerAddToken] GET:URLString parameters:parameters progress:downloadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[self allSessionTask] removeObject:task];
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[self allSessionTask] removeObject:task];
        failure(task,error);
    }];
    
    // 添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
    
}

-(NSURLSessionTask *)DefaultPOSTAddToken:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    
    
    URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@",URLString );
    
    
    NSURLSessionTask *sessionTask =[[BaseHttpSessionManager shareManagerAddToken] POST:URLString parameters:parameters progress:uploadProgress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [[self allSessionTask] removeObject:task];
        success(task,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [[self allSessionTask] removeObject:task];
        failure(task,error);
    }];
    // 添加最新的sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}

-(void)cancelAllRequest {
    // 锁操作
    
    @synchronized(self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}

-(void)cancelRequestWithURL:(NSString *)URL {
    if (!URL) { return; }
    @synchronized (self) {
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

/**
 *  为链接添加token
 *
 *  @param url <#url description#>
 *
 *  @return <#return value description#>
 */
//+ (NSString *)addAccessToken:(NSString *)url{
//    
//    return [url stringByAppendingString:[NSString stringWithFormat:@"?access_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:ACCESSTOKEN]]];
//}




@end
