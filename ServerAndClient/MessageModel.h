//
//  MessageModel.h
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/26.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>

// 数据来源，是自己发送还是别人发送
typedef NS_ENUM(NSInteger, MessageSource) {
    MessageSourceSelf,
    MessageSourceOther
};

@interface MessageModel : NSObject
@property (nonatomic) MessageSource source;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSData *Data;
@property (nonatomic, assign) BOOL isPic;
@end
