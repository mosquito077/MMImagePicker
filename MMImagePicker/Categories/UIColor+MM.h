//
//  UIColor+MM.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (MM)

/**
 @brief  通过RBG值获取颜色
 
 @param r R值
 @param g G值
 @param b B值
 
 @return 颜色对象
 
 @since 3.1
 */
+ (UIColor *)colorWithIntegerRed:(NSInteger)r green:(NSInteger)g blue:(NSInteger)b;

/**
 @brief  通过16进制字符串获取颜色
 
 @param string 颜色的16进制表示
 
 @return 颜色对象
 
 @since 3.1
 */
+ (UIColor *)colorWithHexString:(NSString *)string;

/**
 @brief  通过16进制字符串和透明度获取颜色
 
 @param string 颜色的16进制表示
 @param alpha  透明度
 
 @return 颜色对象
 
 @since 3.1
 */
+ (UIColor *)colorWithHexString:(NSString *)string Alpha:(float)alpha;

@end
