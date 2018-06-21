//
//  Client.h
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Client : NSObject

+ (instancetype)clientManager;

- (void)write:(NSString *)str;

- (void)startWithIp:(NSString *)connectIp port:(NSInteger)port;

- (void)stop;



@end






