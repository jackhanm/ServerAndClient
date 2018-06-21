//
//  ToTableViewCell.h
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/26.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageModel;
@interface ToTableViewCell : UITableViewCell
@property (nonatomic, strong) MessageModel *model;
@end
