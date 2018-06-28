

//
//  JKAFNetTool.m
//  JKqyApp
//
//  Created by dllo on 15/12/15.
//  Copyright © 2015年 dllo. All rights reserved.
//

#import "JKAFNetTool.h"
#import "AFNetworking.h"

@implementation JKAFNetTool

+ (void)getNetWithURL:(NSString *)url
                 body:(id)body
        headFile:(NSDictionary *)headFile
        responseStyle:(JKresponseStyle)responseStyle
              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    //1, 创建网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求超时
    manager.requestSerializer.timeoutInterval = 10;
    if (manager.requestSerializer.timeoutInterval  < 10) {
        [manager.operationQueue cancelAllOperations];
        
        NSLog(@"结束请求");


    }
    //2, 请求头的添加
    if (headFile) {
        for (NSString *key in headFile.allKeys) {
            [manager.requestSerializer setValue:headFile[key] forHTTPHeaderField:key];
            
            
                   }
    }
    //3, 返回数据的类型
    switch (responseStyle) {
        case JKJSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case JKXMl:
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        case JkDATA:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        default:
            break;
    }
    
    
    
    //4. 响应返回数据类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", @"application/javascript",@"application/x-javascript",@"image/jpeg", nil]];
    //5. 转码
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //6. 发送请求
    
    
    [manager GET:url parameters:body success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        NSString *path = [NSString stringWithFormat:@"%ld.plist", (unsigned long)[url hash]];
        // 存储的沙盒路径
        NSString *path_doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // 归档
        [NSKeyedArchiver archiveRootObject:responseObject toFile:[path_doc stringByAppendingPathComponent:path]];
        

        
        if (responseObject) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        // 缓存的文件夹
        NSString *path = [NSString stringWithFormat:@"%ld.plist", (unsigned long)[url hash]];
        NSString *path_doc = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // 反归档
        id result = [NSKeyedUnarchiver unarchiveObjectWithFile:[path_doc stringByAppendingPathComponent:path]];
        
        if (result) {
            success(task, result);
            //            failure(task, error);
            //            NSLog(@"%@", error);
        } else {
            failure(task, error);
        }
    }];
}



+ (void)PostNetWithURL:(NSString *)url
                  body:(id)body
             bodyStyle:(JKrequestStyle)requestStyle
              headFile:(NSDictionary *)headFile
         responseStyle:(JKresponseStyle)responseStyle
               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    //1, 创建网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    //2 .body的类型
    switch (requestStyle) {
        case JKrequestJSON:
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case JKrequestString:
            [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable * _Nullable error) {
                
                return parameters;
            }];
            break;

            
        default:
            break;
    }
    
    
    
    //3, 请求头的添加
    if (headFile) {
        for (NSString *key in headFile.allKeys) {
            [manager.requestSerializer setValue:headFile[key] forHTTPHeaderField:key];
              }
    }
    //4, 返回数据的类型
    switch (responseStyle) {
        case JKJSON:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        case JKXMl:
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        case JkDATA:
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        default:
            break;
    }
    
    
    
    //5. 响应返回数据类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", @"application/javascript",@"application/x-javascript",@"image/jpeg", nil]];
//    6. 转码
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    7. 发送请求
    
   
    [manager POST:url parameters:body success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (responseObject) {
            success(task,responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        if (error) {
            failure (task,error);
            NSLog(@"%@",error);
        }
    }];
  
 }
+ (void)postWithUrl:(NSString *)url  parameters:(id)parameters
{
    AFHTTPSessionManager *managers = [AFHTTPSessionManager manager];
    
    //进行POST请求
  
    [managers POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
      NSLog(@"请求成功，服务器返回的信息%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       NSLog(@"请求失败,服务器返回的信息%@",error);
     
    }];
   
}

// 上传图片
+(void)uploadImageName:(NSString *)name
{
    //1 创建会话管理者
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://120.26.204.222:8881/ycwebservice/text.php"]];
    UIImage *image = [UIImage imageNamed:name]; //图片名
    
    NSData *imageData = UIImageJPEGRepresentation(image,0.5);//压缩比例
    [[manage uploadTaskWithRequest:request fromData:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"1");
        NSLog(@"%lld",uploadProgress.completedUnitCount);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@",responseObject);
          NSLog(@"2");
    }] resume];
}



+(void)uploadImage
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPResponseSerializer *responseSer = [AFHTTPResponseSerializer serializer];
    responseSer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    manager.responseSerializer = responseSer;
    NSMutableURLRequest  *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://120.26.204.222:8881/ycwebservice/text.php" ]];
    UIImage *image = [UIImage imageNamed:@"1.jpg"]; //图片名
       NSData *imageData = UIImageJPEGRepresentation(image,0.5);//压缩比例
    [[manager uploadTaskWithRequest:request fromData:imageData progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
         NSString *returnString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"3-测试输出：%@",returnString);

        
    }] resume];

}

+ (void)uploadimageWithName:(NSString *)name URL:(NSString *)urlStr
{
    UIImage *image = [UIImage imageNamed:name]; //图片名
    
    NSData *imageData = UIImageJPEGRepresentation(image,0.5);//压缩比例

    NSURL *url = [NSURL URLWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        /**************************post新增********************/
        //先设置为Post模式
        request.HTTPMethod = @"POST";
    //    NSString *bodyStr = @"date=20131129&startRecord=1&len=30&udid=1234567890&terminalType=Iphone&cid=213";
    //    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
        //再添加Body
        request.HTTPBody = imageData;
        /**************************post新增********************/
        NSURLSession *senssion = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] ];
    
    
        NSURLSessionDataTask * PostT =  [senssion dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            id result = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", result);
    
    
            
            
        }];
        
        [PostT resume];
}




@end
