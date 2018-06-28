//
//  CommenRequestModel.h
//  优汇圈商家
//
//  Created by yuhao on 2017/4/6.
//  Copyright © 2017年 uhqsh. All rights reserved.
//

#import "BaseRequestParmsModel.h"

@interface CommenRequestModel : BaseRequestParmsModel
//用户登录
+(NSMutableDictionary *)loginName:(NSString *)loginName password:(NSString *)password;
+(NSMutableDictionary *)flieName:(NSString *)flieName;
@end

