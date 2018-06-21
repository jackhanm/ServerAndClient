//
//  SocketSend.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/29.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "SocketHandle.h"
#import "GCDAsyncSocket.h"
#import "Client.h"
#import "Server.h"
#import "Person.pbobjc.h"
static SocketHandle *single = nil;

NSString * const ClientReceiveMessage = @"ClientReceiveMessage";

NSString * const SocketConnectState =   @"SocketConnectState";

@implementation SocketHandle
+ (SocketHandle *)shareManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!single) {
            single = [[SocketHandle alloc] init];
        }
    });
    
    return single;
}

#pragma mark - server
- (void)startServer
{
    [self stopServer];
    Server *s = [Server shareManager];
    [s start];
    
}

- (void)stopServer
{
    Server *s = [Server shareManager];
    [s stop];
    if (self.type == SocketTypeServer) {
        self.realSocket = nil;
    }
}

#pragma mark - client
- (void)startClientConnect:(NSString *)connectIp port:(NSString *)port
{
    [self stopClient];
    
    Client *c = [Client clientManager];
    
    [c startWithIp:connectIp port:[port integerValue]];
}

- (void)stopClient
{
    Client *c = [Client clientManager];
    
    [c stop];
    
    if (self.type == SocketTypeClient) {
        
        self.realSocket = nil;
        
    }

}

- (void)writeWith:(NSString *)value
{
    if (!single.realSocket) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未连接其它手机，请先连接!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    value = [NSString stringWithFormat:@"%@\r\n", value];
    [single.realSocket writeData:[value dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [single.realSocket readDataWithTimeout:-1 tag:0];
}

- (void)writeWithmodel:(GPBMessage *)value
{
    if (!single.realSocket) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未连接其它手机，请先连接!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    NSData *data = [value delimitedData] ;
    [single.realSocket writeData:[value delimitedData] withTimeout:-1 tag:0];
    [single.realSocket readDataWithTimeout:-1 tag:0];
}


@end
