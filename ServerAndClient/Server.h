//
//  Server.h
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject

@property (nonatomic, strong) NSMutableData *messageData;

+ (Server *)shareManager;

- (void)start;

- (void)stop;

@end
