//
//  CommenRequestModel.m
//  优汇圈商家
//
//  Created by yuhao on 2017/4/6.
//  Copyright © 2017年 uhqsh. All rights reserved.
//

#import "CommenRequestModel.h"

@implementation CommenRequestModel
/**
 *  用户登录
 loginName  用户名
 password 密码
 */
+(NSMutableDictionary *)loginName:(NSString *)loginName password:(NSString *)password
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:loginName forKey:@"loginName"];
    [params setObject:password forKey:@"password"];
    return [self baseGetInfoFacory:params];
}
/**
 *  商户入驻申请
 name  商户名称
 province 省
 city 市
 district 区
 phone  联系电话
 email 邮箱
 brandname 品牌名
 businessLicenseCode 营业执照注册号
 businessLicenseDate 营业执照有效期
 */
+(NSMutableDictionary *)name:(NSString *)name province:(NSString *)province city:(NSString *)city district:(NSString *)district phone:(NSString *)phone email:(NSString *)email brandname:(NSString *)brandname businessLicenseCode:(NSString *)businessLicenseCode businessLicenseDate:(NSString *)businessLicenseDate
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:name forKey:@"name"];
    [params setObject:province forKey:@"province"];
    [params setObject:city forKey:@"city"];
    [params setObject:district forKey:@"district"];
    [params setObject:phone forKey:@"phone"];
    [params setObject:email forKey:@"email"];
    [params setObject:brandname forKey:@"brandname"];
    [params setObject:businessLicenseCode forKey:@"businessLicenseCode"];
    [params setObject:businessLicenseDate forKey:@"businessLicenseDate"];
    return [self baseGetInfoFacory:params];
}
/**
 *  修改密码
 password  当前密码
 newPassword 新密码
 */
+(NSMutableDictionary *)password:(NSString *)password newPassword:(NSString *)newPassword
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:password forKey:@"password"];
    [params setObject:newPassword forKey:@"newPassword"];
    return [self baseGetInfoFacory:params];
}

/**
 * 校验券
 coupons  券列表，逗号分隔
 extra 是否查询订单下其他的券。0:否;1=是
 */
+(NSMutableDictionary *)coupons:(NSString *)coupons extra:(NSString *)extra storeId:(NSString *)storeId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:coupons forKey:@"coupons"];
    [params setObject:extra forKey:@"extra"];
    [params setObject:storeId forKey:@"storeId"];
    return [self baseGetInfoFacory:params];
}

/**
 * 核销券
 coupons  券列表，逗号分隔
 */
+(NSMutableDictionary *)coupons:(NSString *)coupons storeId:(NSString *)storeId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:coupons forKey:@"coupons"];
    [params setObject:storeId forKey:@"storeId"];
    return [self baseGetInfoFacory:params];
}
@end
