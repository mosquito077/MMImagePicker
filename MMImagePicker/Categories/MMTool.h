//
//  MMTool.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

typedef NS_ENUM (NSInteger, MMAlertType) {
    MMAlertTypeMessage,
    MMAlertTypeSuccess,
    MMAlertTypeFail,
    MMAlertTypeNetWork,
    MMAlertTypeWait,
    MMAlertTypeRectangle
};

@interface MMTool : NSObject

/**
 @brief  显示一条弹出提示信息，父视图是keywindow
 
 @param message    提示信息
 @param type       消息类型
 @param isAutoHide 自动隐藏提示开关
 @param delay 自动隐藏时间，默认2s
 
 @since 3.0.0
 */
+ (void)alert:(NSString *)message type:(MMAlertType)type autoHide:(BOOL)isAutoHide afterDelay:(NSTimeInterval)delay;
+ (void)alert:(NSString *)message type:(MMAlertType)type autoHide:(BOOL)isAutoHide;
/**
 @brief  显示一条自动隐藏的提示信息，父视图是keywindow
 
 @param message 提示信息
 @param type    消息类型
 @param delay 自动隐藏时间
 @since 3.0.0
 */
+ (void)alert:(NSString *)message type:(MMAlertType)type afterDelay:(NSTimeInterval)delay;
+ (void)alert:(NSString *)message type:(MMAlertType)type;
/**
 @brief  显示一条自动隐藏的提示信息，父视图是keywindow
 
 @param message 提示信息，消息类型为YHBAlertTypeMessage
 @param delay 自动隐藏时间
 
 @since 3.0.0
 */
+ (void)alertMessage:(NSString *)message afterDelay:(NSTimeInterval)delay;
+ (void)alertMessage:(NSString *)message;
/**
 @brief  显示一条1s后自动隐藏的提示信息，父视图是keywindow
 
 @param message 成功的提示语
 
 @since 3.0.0
 */
+ (void)alertSuccess:(NSString *)message;
/**
 @brief  显示一条1s后自动隐藏的提示信息，父视图是keywindow
 
 @param message 失败的提示语
 
 @since 3.0.0
 */
+ (void)alertFail:(NSString *)message;
/**
 @brief  显示一条1s后自动隐藏的提示信息，父视图是keywindow
 
 @param message 带网络标识的提示语
 
 @since 3.0.0
 */
+ (void)alertNetwork:(NSString *)message;
/**
 @brief  显示一条1s后自动隐藏的提示信息，父视图是keywindow
  
 @since 3.0.0
 */
+ (void)alertNetworkLess;
/**
 @brief  显示一条YHBAlertTypeWait类型的提示语
 
 @since 3.0.0
 */
+ (void)alertWait;

+ (void)alertWait:(NSString *)message;

/**
 @brief  隐藏keywinow上的提示框
 
 @since 3.0.0
 */
+ (void)hideAlert;
/**
 @brief  隐藏指定视图上的提示框
 
 @since 3.0.0
 */
+ (void)hideAlertInView:(UIView *)view;

@end
