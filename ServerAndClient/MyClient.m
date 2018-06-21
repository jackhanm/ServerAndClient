//
//  MyClient.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/11/24.
//  Copyright © 2015年 蓝鸥科技. All rights reserved.
//

#import "MyClient.h"
#import "GCDAsyncSocket.h"

@interface MyClient ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation MyClient
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)startConnect
{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 1- 1024,
    [self.socket connectToHost:@"127.0.0.1" onPort:8080 error:nil];
    // 不停的获得信息
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)sendMessage:(NSString *)str
{
    [self.socket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.socket readDataWithTimeout:-1 tag:0];
}



@end






