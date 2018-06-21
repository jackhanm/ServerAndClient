//
//  AddViewController.m
//  ServerAndClient
//
//  Created by 蒋杏飞 on 15/6/2.
//  Copyright (c) 2015年 蓝鸥科技. All rights reserved.
//

#import "AddViewController.h"
#include <arpa/inet.h>
#include <netdb.h>

#include <net/if.h>

#include <ifaddrs.h>
#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "SocketHandle.h"

@interface AddViewController ()
@property (nonatomic, strong) UITextField *otherIp;
@property (nonatomic, strong) UITextField *portFiled;
@end

@implementation AddViewController

- (void)viewWillAppear:(BOOL)animated
{
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
        
    self.title = @"同一局域网";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(connectAction:)];
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSString *myIp = [NSString stringWithFormat:@"当前IP地址:%@", [self localWiFiIPAddress]];
    UILabel *currentIp = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 200, 30)];
    [currentIp setFont:[UIFont systemFontOfSize:14]];
    [currentIp setText:myIp];
    [self.view addSubview:currentIp];
    
    UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 140, 120, 30)];
    [otherLabel setText:@"请输入链接IP:"];
    [otherLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:otherLabel];
    
    self.otherIp = [[UITextField alloc] initWithFrame:CGRectMake(150, 140, 100, 30)];
    [self.otherIp setFont:[UIFont systemFontOfSize:14]];
    [self.otherIp setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:self.otherIp];
    
    
    UILabel *portLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 180, 120, 30)];
    [portLabel setText:@"请输入链接端口号:"];
    [portLabel setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:portLabel];
    
    self.portFiled = [[UITextField alloc] initWithFrame:CGRectMake(150, 180, 100, 30)];
    [self.portFiled setFont:[UIFont systemFontOfSize:14]];
    [self.portFiled setBackgroundColor:[UIColor grayColor]];
  //  [self.portFiled setText:@"8080"];
 //   [self.portFiled setEnabled:NO];
    [self.view addSubview:self.portFiled];
}

// 开始连接
- (void)connectAction:(id)sender
{
    SocketHandle *my = [SocketHandle shareManager];
    [my startClientConnect:self.otherIp.text port:self.portFiled.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


// 获得当前路由下的iP地址
- (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

@end





