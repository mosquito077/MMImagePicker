//
//  NSString+MM.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

@interface NSString (MM)

/**
 @brief  对字符串MD5加密
 
 @return 加密结果
 
 @since 3.1
 */
- (NSString *)md5String;

/**
 @brief  判断字符串移除空白字符后是否为空
 
 @return 是否为空
 
 @since 3.1
 */
- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters;


/**
 @brief  将字符串进行urlencoding
 
 @return encoding之后的字符串
 
 @since 3.1
 */
- (NSString *)URLEncodedString;

/**
 @brief  判断字符串长度时候满足在最大值和最小值之间
 
 @param minimum 字符串长度限制最小值
 @param maximum 字符串长度限制最大值
 
 @return 是否满足长度显示
 
 @since 3.1
 */
- (BOOL)isLenghGreaterThanOrEqual:(NSInteger)minimum lessThanOrEqual:(NSInteger)maximum;

/**
 @brief  判断NSString是数值型
 
 @return 字符串是否是数值
 
 @since 3.1
 */
- (BOOL)isPureDigital;

/**
 @brief  图片链接处理，自定义宽高和切图模式
 
 @param width  期望图片宽度
 @param height 期望图片高度
 @param mode   切图模式
 
 @return 图片url
 
 @since 3.1
 */
- (NSString *)validImageURLWithWidth:(CGFloat)width height:(CGFloat)height mode:(NSInteger)mode;


/**
 @brief  图片链接处理，自定义宽高，切图模式固定
 
 @param width  期望图片宽度
 @param height 期望图片高度
 
 @return 图片url
 
 @since 3.1
 */
- (NSString *)validImageURLWithWidth:(CGFloat)width height:(CGFloat)height;


@end
