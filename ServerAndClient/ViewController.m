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
#import <AVFoundation/AVFoundation.h>
# define COUNTDOWN 60
#define tableHeight [UIScreen mainScreen].bounds.size.height - 104

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, SendFieldDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

{
    
    NSTimer *_timer; //定时器
    NSInteger countDown;  //倒计时
    NSString *filePath;
    
    
}
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) SendField *field;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址
@property (nonatomic, strong) UILabel *noticeLabel;
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
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [UIScreen mainScreen].bounds.size.height - 144) style:UITableViewStylePlain];
    [_table registerClass:[FromTableViewCell class] forCellReuseIdentifier:@"from"];
    [_table registerClass:[ToTableViewCell class] forCellReuseIdentifier:@"to"];
    [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_table setDelegate:self];
    [_table setDataSource:self];
    [self.view addSubview:_table];
    
    self.noticeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 144, [UIScreen mainScreen].bounds.size.width, 30)];
    self.noticeLabel.backgroundColor =[UIColor redColor];
    [self.view addSubview:self.noticeLabel];
    
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
 //   [self sendLogin];
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
   
    per.sendId = 1;
   
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
    per.msgId = 4;
    per.msgSn = 1;
    per.sercte =false;
    per.sendId = 1;
    per.reciveId = 2;
    per.terminalType=1;
    per.msgType=@"txt";
    per.replyMsg=1;
    per.token = @"123456";
    per.timeStamp =11;
    NSString *str = message;
    NSData *Data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",Data);
    per.msgContent = Data;
   

       [c writeWithmodel:per];
   
    
    
    
    [self.tableArray addObject:model];
    [self.table reloadData];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [self.field.messageView setText:@""];
}
- (UIImagePickerController *)imagePicker
{
    if (nil == _imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.modalPresentationStyle = UIModalPresentationCustom;
        _imagePicker.view.backgroundColor = [UIColor whiteColor];
        [_imagePicker.navigationBar setBackgroundImage:[UIImage imageNamed:@"daohanglanbeijing"] forBarMetrics:UIBarMetricsDefault];
        _imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    }
    return _imagePicker;
}
//选择照片
-(void)choosePic{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    } else {
        NSLog(@"photLibrary is not available!");
    }
}
-(void)Sendvoice{
    if (![self hasPermissionToGetCamera]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许iCom访问你的手机麦克风。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        NSLog(@"开始录音");
        
         countDown = 60;
        [self addTimer];
        
        AVAudioSession *session =[AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        
        if (session == nil) {
            
            NSLog(@"Error creating session: %@",[sessionError description]);
            
        }else{
            [session setActive:YES error:nil];
            
        }
        
        self.session = session;
        
        
        //1.获取沙盒地址
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        filePath = [path stringByAppendingString:@"/RRecord.wav"];
        
        //2.获取文件路径
        self.recordFileUrl = [NSURL fileURLWithPath:filePath];
        NSLog(@"%@",filePath);
        //设置参数
        NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                       [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                       // 音频格式
                                       [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                       //采样位数  8、16、24、32 默认为16
                                       [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                       // 音频通道数 1 或 2
                                       [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                       //录音质量
                                       [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                       nil];
        
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];
        
        if (_recorder) {
            
            _recorder.meteringEnabled = YES;
            [_recorder prepareToRecord];
            [_recorder record];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self stopRecord];
            });
            
            
            
        }else{
            NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
            
        }
        
       
    }
}
/**
 *  添加定时器
 */
- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshLabelText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

/**
 *  移除定时器
 */
- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
    
}


-(void)refreshLabelText{
    
    countDown --;
    
     _noticeLabel.text = [NSString stringWithFormat:@"还剩 %ld 秒",(long)countDown];
    
}
-(void)stopRecord{
    [self removeTimer];
    NSLog(@"停止录音");
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        
        _noticeLabel.text = [NSString stringWithFormat:@"录了 %ld 秒,文件大小为 %.2fKb",COUNTDOWN - (long)countDown,[[manager attributesOfItemAtPath:filePath error:nil] fileSize]/1024.0];
        
        
        Message *per = [[Message alloc] init];
        per.msgId = 5;
        per.msgSn = 1;
        per.sercte =false;
        per.sendId = 1;
        per.reciveId = 1;
        per.terminalType=1;
        per.msgType=@"wav";
        per.replyMsg=1;
        per.token = @"123456";
        per.timeStamp =11;
        SocketHandle *c = [SocketHandle shareManager];
        per.msgContent = [NSData dataWithContentsOfFile:filePath];
        MessageModel *model = [[MessageModel alloc] init];
        model.source = MessageSourceSelf;
        model.message = @"" ;
        
        if (per.msgType ==@"pic") {
            model.isPic = YES;
            model.Data = per.msgContent;
        }
        [c writeWithmodel:per];
    }else{
        
        _noticeLabel.text = @"最多录60秒";
        
    }
    
    
    
    
    
}
-(BOOL)hasPermissionToGetCamera
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    
    NSLog(@"bCanRecord1 : %d",bCanRecord);
    return bCanRecord;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //    NSString *mediaType = info[UIImagePickerControllerMediaType];
    //    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
    //        ICLog(@"movie");
    //    } else {
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    NSData *data =UIImageJPEGRepresentation(orgImage, 1.0);
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 图片压缩后再上传服务器
    // 保存路径
    UIImage *simpleImg = [self simpleImage:orgImage];
    NSString *filePaht = [self saveImage:simpleImg];
    Message *per = [[Message alloc] init];
    per.msgId = 5;
    per.msgSn = 1;
    per.sercte =false;
    per.sendId = 1;
    per.reciveId = 1;
    per.terminalType=1;
    per.msgType=@"pic";
    per.replyMsg=1;
    per.token = @"123456";
    per.timeStamp =11;
    SocketHandle *c = [SocketHandle shareManager];
    per.msgContent = data;
    MessageModel *model = [[MessageModel alloc] init];
    model.source = MessageSourceSelf;
    model.message = @"" ;

    if (per.msgType ==@"pic") {
        model.isPic = YES;
        model.Data = per.msgContent;
    }
      [c writeWithmodel:per];
    
    
    [self.tableArray addObject:model];
    [self.table reloadData];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.tableArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
  
    //    }
}
/**
 *  保存图片到沙盒
 *
 *  @param image 图片
 *
 *  @return 图片路径
 */
- (NSString *)saveImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *chachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // 图片名称
    NSString *fileName = [NSString stringWithFormat:@"%@%@",[self currentName],@".png"];
    NSString *mainFilePath = [self createFolderPahtWithMainFolder:chachePath childFolder:@"Chat/MyPic"];
    NSString *filePath = [mainFilePath stringByAppendingPathComponent:fileName];
    [imageData writeToFile:filePath atomically:NO];
    return filePath;
}
// 路径cache/MyPic
- (NSString *)createFolderPahtWithMainFolder:(NSString *)mainFolder
                                 childFolder:(NSString *)childFolder
{
    NSString *path = [mainFolder stringByAppendingPathComponent:childFolder];
    [self fileManagerWithPath:path];
    return path;
}
- (void)fileManagerWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreateDir) {
            
            return ;
        }
    }
}
- (NSString *)currentName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHMMss"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    return currentDate;
}
// 压缩图片
- (UIImage *)simpleImage:(UIImage *)originImg
{
    CGSize imageSize = [self handleImage:originImg.size];
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    CGContextAddPath(contextRef, bezierPath.CGPath);
    CGContextClip(contextRef);
    [originImg drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *clipedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipedImage;
}
- (CGSize)handleImage:(CGSize)retSize {
    CGFloat width = 0;
    CGFloat height = 0;
    if (retSize.width > retSize.height) {
        width = [[UIScreen mainScreen] bounds].size.width;
        height = retSize.height / retSize.width * width;
    } else {
        height =[[UIScreen mainScreen] bounds].size.height;
        width = retSize.width / retSize.height * height;
    }
    return CGSizeMake(width, height);
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
   model.message = [[NSString alloc] initWithData:per1.msgContent encoding:NSUTF8StringEncoding]  ;
    model.source = MessageSourceOther;
    if ([per1.msgType isEqualToString: @"pic"] ||[per1.msgType isEqualToString: @"jpg"]  ||[per1.msgType isEqualToString: @"png"]) {
        model.isPic = YES;
        model.Data = per1.msgContent;
    }
    if ([per1.msgType isEqualToString: @"wav"]) {
     
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
      
        filePath = [path stringByAppendingString:@"/RRecord.wav"];
    
        NSLog(@"播放录音");
        [self.recorder stop];
        
        if ([self.player isPlaying])return;
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:nil];
        
        
        
        NSLog(@"%li",self.player.data.length/1024);
        
        
        
        [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.player play];
      
        
    }
    
    
    
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
    if ( model.isPic == YES) {
        size = CGSizeMake(200, 200);
    }
    return size.height;
}

// 拖拽tableview后让键盘回收

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.field.messageView resignFirstResponder];
}

@end



