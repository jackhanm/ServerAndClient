//
//  SendField.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/26.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "SendField.h"

#define MESSAGEVIEWHEIGHT 30

#define FIELDMAXHEIGHT 100

@interface SendField ()<UITextViewDelegate>
{
    CGRect _sendFieldRect;
}


@end

@implementation SendField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _sendFieldRect = frame;
        [self createMessageFieldAndButton];
    }
    return self;
}

- (void)createMessageFieldAndButton
{
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 70, 5, 60, self.frame.size.height - 10)];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    
    self.messageView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, self.frame.size.width - sendButton.frame.size.width - 30, sendButton.frame.size.height)];
    [self.messageView setDelegate:self];
    [self addSubview:self.messageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - 
#pragma mark UITextFieldDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}



#pragma mark - 
#pragma mark 根据输入文本来改变输入框的高度

- (void)textViewDidChange:(UITextView *)textView
{
    //
    NSString *value = textView.text;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:textView.font, NSFontAttributeName, nil];
    CGSize size = [value boundingRectWithSize:CGSizeMake(textView.frame.size.width, FIELDMAXHEIGHT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    // 计算高度偏移量，textView输入内容上移，self 坐标上移
    CGFloat offY = 0;
    
    offY = size.height - textView.frame.size.height;
    // 如果偏移绝对值大于0，则自动扩展输入框的高度和底部视图的Y值、高度
    // 如果偏移不大于0，则还原为最初的高度
    if (ABS(size.height) <= MESSAGEVIEWHEIGHT) {
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, MESSAGEVIEWHEIGHT)];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 40, self.frame.size.width, MESSAGEVIEWHEIGHT + 10);
    } else {
        [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height + offY)];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - offY, self.frame.size.width, self.frame.size.height + offY);
    }
}

#pragma mark - 
#pragma mark 键盘上移
- (void)keyboardChange:(NSNotification *)noti
{
    NSLog(@"dic = %@", noti);
    NSDictionary *dic = [noti userInfo];
    NSValue *rectValue = [dic objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat offY = [rectValue CGRectValue].origin.y;
    
    [self setFrame:CGRectMake(self.frame.origin.x, offY - self.frame.size.height - 64, self.frame.size.width, self.frame.size.height)];
    
    [self.delegate filedChangeWithHeight:[rectValue CGRectValue].origin.y - [[UIScreen mainScreen] bounds].size.height];
}


#pragma mark - 
#pragma mark 发送事件

- (void)sendAction:(UIButton *)button
{
//    [self.messageView resignFirstResponder];
    [self.delegate sendFieldDidSend:self.messageView.text];
}


@end
