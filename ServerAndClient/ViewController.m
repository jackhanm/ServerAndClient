//
//  ViewController.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/5/25.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "ViewController.h"
#import "FromTableViewCell.h"
#import "ToTableViewCell.h"
#import "Server.h"
#import "Client.h"
#import "MessageModel.h"
#import "SendField.h"
#import "SocketHandle.h"
#import "AddViewController.h"
#import "GCDAsyncSocket.h"
#import "Person.pbobjc.h"  //模型
#import "Message.pbobjc.h"
#define tableHeight [UIScreen mainScreen].bounds.size.height - 104

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, SendFieldDelegate>

@property (nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) SendField *field;
@end

@implementation ViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ClientReceiveMessage object:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.tableArray = [NSMutableArray array];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"未链接";
    
    // 添加链接ip地址界面
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addViewController:)];
    
    self.navigationController.navigationBar.translucent = NO;
    
    // 接收消息消息中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:ClientReceiveMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess) name:SocketConnectState object:nil];
    
    // 创建表格
    [self createTable];
}


- (void)createTable
{
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [UIScreen mainScreen].bounds.size.height - 104) style:UITableViewStylePlain];
    [_table registerClass:[FromTableViewCell class] forCellReuseIdentifier:@"from"];
    [_table registerClass:[ToTableViewCell class] forCellReuseIdentifier:@"to"];
    [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_table setDelegate:self];
    [_table setDataSource:self];
    [self.view addSubview:_table];
    
    // 输入框
    self.field = [[SendField alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 104, self.view.frame.size.width, 40)];
    [_field setBackgroundColor:[UIColor grayColor]];
    [_field setDelegate:self];
    [self.view addSubview:_field];
    
}
// 进入链接界面
- (void)addViewController:(id)sender
{
    AddViewController *add = [[AddViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:add];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)connectSuccess
{
    self.title = @"链接成功";
    // 开始登陆操作
    [self sendLogin];
    // 心跳
     [self runHeartbeat]; //发送心跳包
    
}
/** 创建时钟器 发送心跳包 */
- (void)runHeartbeat
{
    //......
}
-(void)sendLogin{
    
    
    SocketHandle *c = [SocketHandle shareManager];
    Message *per = [[Message alloc] init];
    per.msgId = 2;
    per.msgSn = 1;
    per.sercet = false;
    per.sendId = 1;
    per.reciveid = 2;
    per.msg=@"";
    [c writeWithmodel:per];
}


/*
 *
 * 列表界面和输入框
 *
 */


#pragma mark -
#pragma mark fieldDelegate
// 发送按钮协议
- (void)sendFieldDidSend:(NSString *)message
{
    if ([message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"输入内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    

    MessageModel *model = [[MessageModel alloc] init];
    model.source = MessageSourceSelf;
    model.message = message;
//
    SocketHandle *c = [SocketHandle shareManager];
  //[c writeWith:message];
    
//     创建对象
    
    Message *per = [[Message alloc] init];
    per.msgId = 3;
    per.msgSn = 1;
    per.sercet = false;
    per.sendId = 1;
    per.reciveid = 2;
    per.msg=message;

       [c writeWithmodel:per];
   
    
    
    
    [self.tableArray addObject:model];
    [self.table reloadData];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self.field.messageView setText:@""];
}
// 输入框高度改变，计算tableview的高度
- (void)filedChangeWithHeight:(CGFloat)height
{
    if (height == 0) {
        [_table setFrame:CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width, [UIScreen mainScreen].bounds.size.height - 104)];
    } else {
        [_table setFrame:CGRectMake(_table.frame.origin.x, _table.frame.origin.y, _table.frame.size.width, tableHeight + height)];
    }
}

#pragma mark - 
#pragma mark Message receive
// 接收到信息的消息中心
- (void)receiveMessage:(NSNotification *)noti
{
    NSDictionary *dic = [noti userInfo];
    Message *per1  = [dic objectForKey:@"value"];
   //  GPBCodedInputStream *inputStream = [GPBCodedInputStream streamWithData:data];
    NSError *error;
  //  Person *per = [Person parseDelimitedFromCodedInputStream:inputStream extensionRegistry:nil error:&error];
//    NSLog(@"%@%@%@",per.name,per.name,per.name);
    MessageModel *model = [[MessageModel alloc] init];
  //  model.message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   model.message =per1.msg;
    model.source = MessageSourceOther;
    
    
    
    
    [self.tableArray addObject:model];
    [self.table reloadData];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - 
#pragma mark tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *model = [self.tableArray objectAtIndex:indexPath.row];
    if (model.source == MessageSourceSelf) {
        FromTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"from"];
        
        [cell setModel:model];
        
        return cell;
    } else {
        ToTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"to"];
        
        [cell setModel:model];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *model = [self.tableArray objectAtIndex:indexPath.row];
    CGRect rect = [UIScreen mainScreen].bounds;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]};
    CGSize size = [model.message boundingRectWithSize:CGSizeMake(rect.size.width / 3 * 2, 100000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return size.height;
}

// 拖拽tableview后让键盘回收

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.field.messageView resignFirstResponder];
}

@end



