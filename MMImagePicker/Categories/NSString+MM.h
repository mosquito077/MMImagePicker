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
 @brief  去除字符串中包含的空白字符
 
 @return 不含空白字符的字符串
 
 @since 3.1
 */
//- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters;

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


#if TARGET_OS_IOS

extern NSUInteger yh_asciiLengthOfString(NSString *text);

/**
 @brief  获取属性字符串
 
 @param font        字体
 @param lineSpacing 行间距
 @param breakMode   换行模式
 @param alignment   对齐方式
 
 @return 属性字符串
 
 @since 3.1
 */
-(NSMutableAttributedString *)attributedStringFromStingWithFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing lineBreakMode:(NSLineBreakMode)breakMode alignment:(NSTextAlignment)alignment;


/**
 @brief  获取文字占据的尺寸
 
 @param size        文字显示区域大小
 @param font        字体
 @param lineSpacing 行间距
 @param breakMode   换行模式
 
 @return 字符区域大小
 
 @since 3.1
 */
-(CGSize)boundingRectWithSize:(CGSize)size textFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing lineBreakMode:(NSLineBreakMode)breakMode;


- (NSInteger)stringLinesWithFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)breakMode inSize:(CGSize)size;

- (NSString *)customeTimeStringFormat;

/**
 @brief 控制字符串长度，超出指定长度就...
 
 @param length 限制字数
 
 @return 处理后的字符串
 
 @since 1.6.0
 */
- (NSString *)getConstraintedStringWithLength:(NSInteger)length;

/**
 @brief 计算字符高度（使用AutoLayout计算）
 
 @param attributesDictionary 属性
 @param width 限制的宽度
 
 @return 计算结果
 
 @since 2.0.0
 */
- (CGFloat)calculateHeightWithAttributes:(NSDictionary *)attributesDictionary constraintWidth:(CGFloat)width;

/**
 @brief 计算字符高度（使用AutoLayout计算）
 
 @param attributesDictionary 属性
 @param width 限制的宽度
 @param rows 最大行数
 
 @return 计算结果
 
 @since 2.0.0
 */
- (CGFloat)calculateHeightWithAttributes:(NSDictionary *)attributesDictionary constraintWidth:(CGFloat)width maximumLineOfRows:(NSInteger)rows;

- (CGFloat)calculateHeightWithAttributes:(NSDictionary *)attributesDictionary constraintWidth:(CGFloat)width maximumLineOfRows:(NSInteger)rows lineBreakMode:(NSLineBreakMode)lineBreakMode;

#endif

@end
