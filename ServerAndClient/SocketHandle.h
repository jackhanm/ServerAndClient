//
//  SocketSend.h
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/29.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Person.pbobjc.h"
@class GCDAsyncSocket;

// 接收信息用消息推送
extern NSString * const ClientReceiveMessage;

extern NSString * const SocketConnectState;


typedef NS_ENUM(NSInteger, SocketType) {
    SocketTypeServer = 10,
    SocketTypeClient
};

// 不管是服务器还是客户端，都通过realSocket来发送信息
@interface SocketHandle : NSObject

// realSocket：如果是A先链接服务器，那么A就是客户端，B是服务器，在B端就是接收的socket发送信息

// 真正发送信息的socket
@property (nonatomic, strong) GCDAsyncSocket *realSocket;

// 当前socket类型
@property (nonatomic) SocketType type;

+ (SocketHandle *)shareManager;

/*
 *
 *在工程开始的时候先把服务器打开，用于监听默认端口9000
 *
 */

// 开启服务器
- (void)startServer;

// 停止服务器
- (void)stopServer;

#pragma mark - client

// 开始连接服务器
- (void)startClientConnect:(NSString *)connectIp port:(NSString *)port;

// 停止连接服务器
- (void)stopClient;

// 发送信息
- (void)writeWith:(NSString *)value;


- (void)writeWithmodel:(GPBMessage *)value;


@end


