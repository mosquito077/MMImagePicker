//
//  UIView+MM.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YHAlertType) {
    YHAlertTypeFail,
    YHAlertTypeSuccess,
    YHAlertTypeNetwork,
    YHAlertTypeRectangle,
};

@interface UIView (MM)

- (instancetype)initWithSize:(CGSize)size;

/**
 @brief  移除所有子视图
 
 @since 3.1
 */
- (void)removeAllSubviews;

/**
 @brief  添加一组姿势图
 
 @param sb 子视图数组
 
 @since 3.1
 */
- (void)addSubviews:(NSArray *)sb;

/**
 @brief  获取视图高度
 
 @return 视图高度
 
 @since 3.1
 */
- (CGFloat)yh_height;

/**
 @brief  获取视图宽度
 
 @return 视图宽度
 
 @since 3.1
 */
- (CGFloat)yh_width;

/**
 @brief  获取视图左边缘位置
 
 @return 视图左侧位置
 
 @since 3.1
 */
- (CGFloat)yh_left;

/**
 @brief  获取视图右边缘位置
 
 @return 视图右边缘位置
 
 @since 3.1
 */
- (CGFloat)yh_right;

/**
 @brief  获取视图上边缘位置
 
 @return 视图上边缘位置
 
 @since 3.1
 */
- (CGFloat)yh_top;

/**
 @brief  获取视图下边缘位置
 
 @return 视图下边缘位置
 
 @since 3.1
 */
- (CGFloat)yh_bottom;

/**
 @brief  设置视图原点
 
 @param origin 原点位置
 
 @since 3.1
 */
- (void)yh_setOrigin:(CGPoint)origin;

/**
 @brief  设置视图左边缘位置
 
 @param x 左边缘位置
 
 @since 3.1
 */
- (void)yh_setX:(CGFloat)x;

/**
 @brief  设置视图上边缘位置
 
 @param y 上边缘位置
 
 @since 3.1
 */
- (void)yh_setY:(CGFloat)y;

/**
 @brief  设置视图宽度
 
 @param width 宽度
 
 @since 3.1
 */
- (void)yh_setWidth:(CGFloat)width;

/**
 @brief  设置视图高度
 
 @param height 高度
 
 @since 3.1
 */
- (void)yh_setHeight:(CGFloat)height;

/**
 @brief  添加子视图并使其和父视图大小一致
 
 @param subview 子视图
 
 @since 3.1
 */
- (void)addAlwaysFitSubview:(UIView *)subview;

/**
 @brief  弹出hud提示
 
 @param message 文字描述
 @param type    hud样式
 
 @since 3.1
 */
- (void)alert:(NSString *)message type:(YHAlertType)type;

/**
 @brief  弹出HUD提示
 
 @param message    文字描述
 @param type       hud样式
 @param completion 回调
 
 @since 3.1
 */
- (void)alert:(NSString *)message type:(YHAlertType)type completion:(dispatch_block_t)completion;

/**
 @brief  弹出网络提示HUD
 
 @since 3.1
 */
- (void)alertNetwork;

/**
 @brief  弹出数据错误HUD
 
 @since 3.1
 */
- (void)alertDataError;

/**
 @brief  弹出等待效果HUD
 
 @since 3.1
 */
- (void)showWait;

/**
 @brief 弹出操作等待HUD
 
 @param status 状态信息
 
 @since 1.1.0
 */
- (void)showWaitWithStatus:(NSString *)status;

/**
 @brief  隐藏HUD
 
 @since 3.1
 */
- (void)hideWait;

- (void)hideWithSuccess:(NSString *)message;

- (void)hideWithFailure:(NSString *)message;

- (NSLayoutConstraint *)constraintOfIdentifier:(NSString *)identifier;

@end
