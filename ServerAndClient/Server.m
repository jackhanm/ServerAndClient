//
//  Server.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "Server.h"
#import "GCDAsyncSocket.h"
#import "SocketHandle.h"
#import "Person.pbobjc.h"
static Server *server = nil;

@interface Server ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) GCDAsyncSocket *currentSocket;
@end

@implementation Server

+ (Server *)shareManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!server) {
            server = [[Server alloc] init];
            server.messageData = [NSMutableData data];
            
        }
    });
    return server;
}

- (void)start
{
    self.socket = [[GCDAsyncSocket alloc] init];
    [self.socket setDelegate:self];
    [self.socket setDelegateQueue:dispatch_get_main_queue()];
    [self.socket acceptOnPort:8080 error:nil];
}

- (void)stop
{
    self.socket.delegate = nil;
    [self.socket disconnect];
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    self.currentSocket = newSocket;
    [self.currentSocket readDataWithTimeout:-1 tag:0];
    // 当有其它的客户端连接这个设备时，那么它就是服务器，服务器通过客户端所建立的通道发送信息，因此，在服务器端真正发送信息的是连接成功的时候接收到的socket来发送信息
    SocketHandle *sendSocket = [SocketHandle shareManager];
    sendSocket.realSocket = newSocket;
    sendSocket.type = SocketTypeServer;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SocketConnectState object:nil];
    
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // probuf 的数据处理(分包,粘包)
    
    
    
    
    
    
    
    //二进制数据反序列化为对象
//    GPBCodedInputStream *inputStream = [GPBCodedInputStream streamWithData:data];
//
//    NSError *error;
//    Person *per = [Person parseDelimitedFromCodedInputStream:inputStream extensionRegistry:nil error:&error];
//    NSLog(@"%@%@%@",per.name,per.name,per.name);
//    if (error){
//
//        return;
//    }else{
//
//        [[NSNotificationCenter defaultCenter] postNotificationName:ClientReceiveMessage object:nil userInfo:@{@"value" : data}];
//
//    }
    
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if ([value hasSuffix:@"\r\n"]) {
        
        [self.messageData appendData:data];
        
        NSString *str = [[NSString alloc] initWithData:self.messageData encoding:NSUTF8StringEncoding];
       
        str = [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ClientReceiveMessage object:nil userInfo:@{@"value" : data}];
        
        self.messageData = [NSMutableData data];
        
    } else {
        
        [self.messageData appendData:data];
        
    }

    [self.currentSocket readDataWithTimeout:-1 tag:0];
}





@end



