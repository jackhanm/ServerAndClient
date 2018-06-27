//
//  Client.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "Client.h"
#import "GCDAsyncSocket.h"
#import "Client.h"
#import "SocketHandle.h"
#import "Message.pbobjc.h"
static Client *client = nil;

@interface Client ()<GCDAsyncSocketDelegate>
//接收服务器发过来的的data
@property (nonatomic, strong) NSMutableData *receiveData;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableData *messageData;
@end

@implementation Client
+ (instancetype)clientManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!client) {
            client = [[Client alloc] init];
            client.messageData = [NSMutableData data];
            
        }
    });
    return client;
}


//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.messageData = [NSMutableData data];
//    }
//    return self;
//}

#pragma mark - start & disConnect

- (void)startWithIp:(NSString *)connectIp port:(NSInteger)port
{
    self.socket = [[GCDAsyncSocket alloc] init];
    // 设置代理人
    [self.socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 客户端链接服务器
    [self.socket connectToHost:connectIp onPort:port error:nil];
    // 客户端连接服务器后，发送信息的就是客户端所创建的socket
    SocketHandle *send = [SocketHandle shareManager];
    send.realSocket = self.socket;
    send.type = SocketTypeClient;
}

- (void)stop
{
    self.socket.delegate = nil;
    [self.socket disconnect];
}



#pragma mark -

- (void)write:(NSString *)str
{
    str = [NSString stringWithFormat:@"%@\r\n", str];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    // 向服务器发送数据
    [self.socket writeData:data withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
}


#pragma mark - 
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
    
    
 //   [self.socket readDataWithTimeout:-1 tag:0];
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
    NSLog(@"%@", obj);
  
    
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
