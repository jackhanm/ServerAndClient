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
#import "Message.pbobjc.h"
static Server *server = nil;

@interface Server ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) NSMutableData *receiveData;
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

#pragma mark 接收数据
/** 存储接收来自服务器的包 */
- (NSMutableData *)receiveData{
    if (_receiveData == nil){
        _receiveData = [[NSMutableData alloc] init];
    }
    return _receiveData;
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.receiveData appendData:data];
    
    //读取data的头部占用字节 和 从头部读取内容长度
    //验证结果：数据比较小时头部占用字节为1，数据比较大时头部占用字节为2
    int32_t headL = 0;
    int32_t contentL = [self getContentLength:self.receiveData withHeadLength:&headL];
    if (contentL < 1){
        [sock readDataWithTimeout:-1 tag:0];
        return;
    }
    //拆包情况下：继续接收下一条消息，直至接收完这条消息所有的拆包，再解析
    if (headL + contentL > self.receiveData.length){
        [sock readDataWithTimeout:-1 tag:0];
        return;
    }
    //当receiveData长度不小于第一条消息内容长度时，开始解析receiveData
    [self parseContentDataWithHeadLength:headL withContentLength:contentL];
    [sock readDataWithTimeout:-1 tag:tag];
    
    //    // 判断接收的数据是否是以\r\n结尾，如果是，则证明数据传输结束，如果不是，则继续拼接数据
    //
    //    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //
    //    if ([value hasSuffix:@"\r\n"]) {
    //
    //        [self.messageData appendData:data];
    //
    //        NSString *str = [[NSString alloc] initWithData:self.messageData encoding:NSUTF8StringEncoding];
    //
    //        str = [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    //        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:ClientReceiveMessage object:nil userInfo:@{@"value" : data}];
    //
    //        self.messageData = [NSMutableData data];
    //
    //    } else {
    //
    //        [self.messageData appendData:data];
    //
    //    }
    
    
    [self.socket readDataWithTimeout:-1 tag:0];
}
/** 解析二进制数据：NSData --> 自定义模型对象 */
- (void)parseContentDataWithHeadLength:(int32_t)headL withContentLength:(int32_t)contentL{
    
    NSRange range = NSMakeRange(0, headL + contentL);   //本次解析data的范围
    NSData *data = [self.receiveData subdataWithRange:range]; //本次解析的data
    
    GPBCodedInputStream *inputStream = [GPBCodedInputStream streamWithData:data];
    
    NSError *error;
    Message *obj = [Message parseDelimitedFromCodedInputStream:inputStream extensionRegistry:nil error:&error];
    
    if (!error){
        if (obj) [self saveReceiveInfo:obj];  //保存解析正确的模型对象
        [[NSNotificationCenter defaultCenter] postNotificationName:ClientReceiveMessage object:nil userInfo:@{@"value" : obj}];
        [self.receiveData replaceBytesInRange:range withBytes:NULL length:0];  //移除已经解析过的data
    }
    
    if (self.receiveData.length < 1) return;
    
    //对于粘包情况下被合并的多条消息，循环递归直至解析完所有消息
    headL = 0;
    contentL = [self getContentLength:self.receiveData withHeadLength:&headL];
    
    if (headL + contentL > self.receiveData.length) return; //实际包不足解析，继续接收下一个包
    
    [self parseContentDataWithHeadLength:headL withContentLength:contentL]; //继续解析下一条
}
/** 处理解析出来的信息 */
- (void)saveReceiveInfo:(Message *)obj{
    //...
   NSLog(@"%@",obj.msgContent);
//    NSLog(@"%@",[[NSString alloc] initWithData:obj.msgContent encoding:NSUTF8StringEncoding]);
    
}

/** 获取data数据的内容长度和头部长度: index --> 头部占用长度 (头部占用长度1-4个字节) */
- (int32_t)getContentLength:(NSData *)data withHeadLength:(int32_t *)index{
    
    int8_t tmp = [self readRawByte:data headIndex:index];
    
    if (tmp >= 0) return tmp;
    
    int32_t result = tmp & 0x7f;
    if ((tmp = [self readRawByte:data headIndex:index]) >= 0) {
        result |= tmp << 7;
    } else {
        result |= (tmp & 0x7f) << 7;
        if ((tmp = [self readRawByte:data headIndex:index]) >= 0) {
            result |= tmp << 14;
        } else {
            result |= (tmp & 0x7f) << 14;
            if ((tmp = [self readRawByte:data headIndex:index]) >= 0) {
                result |= tmp << 21;
            } else {
                result |= (tmp & 0x7f) << 21;
                result |= (tmp = [self readRawByte:data headIndex:index]) << 28;
                if (tmp < 0) {
                    for (int i = 0; i < 5; i++) {
                        if ([self readRawByte:data headIndex:index] >= 0) {
                            return result;
                        }
                    }
                    
                    result = -1;
                }
            }
        }
    }
    return result;
}

/** 读取字节 */
- (int8_t)readRawByte:(NSData *)data headIndex:(int32_t *)index{
    //是否有数据
    if (*index >= data.length) return -1;
    
    *index = *index + 1;
    
    return ((int8_t *)data.bytes)[*index - 1];
    
}

#pragma mark -
#pragma mark 写数据
// 数据发送给服务器后发送成功所走的协议
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // 保持开门状态
    [self.socket readDataWithTimeout:-1 tag:0];
}

#pragma mark -
#pragma mark 连接到服务器
// 链接到服务器成功后所走的协议
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SocketConnectState object:nil];
    // 保持开门状态
    [sock readDataWithTimeout:-1 tag:0];
}





@end



