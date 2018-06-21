//
//  SendField.h
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/26.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendFieldDelegate <NSObject>

- (void)sendFieldDidSend:(NSString *)message;
- (void)filedChangeWithHeight:(CGFloat)height;

@end


@interface SendField : UIView

@property (nonatomic, assign) id<SendFieldDelegate>delegate;

@property (nonatomic, strong) UITextView *messageView; // 输入框
@end
