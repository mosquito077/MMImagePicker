//
//  NSObject+YHAssistant.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/10.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (YHAssistant)

- (BOOL)notNilOrEmpty;

@end

@interface NSString (YHAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters;
- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters;
// 长度是否在一个范围之内,包括范围值
- (BOOL)isLengthGreaterThanOrEqual:(NSInteger)minimum lessThanOrEqual:(NSInteger)maximum;

- (NSRange)firstRangeOfURLSubstring;
- (NSString *)firstURLSubstring;
- (NSArray *)URLSubstrings;
- (NSString *)firstMatchUsingRegularExpression:(NSRegularExpression *)regularExpression;
- (NSString *)firstMatchUsingRegularExpressionPattern:(NSString *)regularExpressionPattern;
// 注意这个是全文匹配
- (BOOL)matchesRegularExpressionPattern:(NSString *)regularExpressionPattern;
- (NSRange)rangeOfFirstMatchUsingRegularExpressionPattern:(NSString *)regularExpressionPattern;

- (NSString *)stringByReplacingMatchesUsingRegularExpressionPattern:(NSString *)regularExpressionPattern withTemplate:(NSString *)templ;

- (NSDictionary *)URLParameters;
+ (NSString *)stringWithDate:(NSDate *)date dateFormat:(NSString *)format;


@end


@interface NSDictionary (YHAssistant)

- (NSMutableDictionary *)mutableDeepCopy;
- (NSString *)stringRepresentationByURLEncoding;
- (NSString *)stringForKey:(id)key;
- (NSDate *)dateForKey:(id)key;
- (NSInteger)integerForKey:(id)key;

@end

@interface UIView (YHAssistant)

- (void)removeAllSubviews;
- (void)addSubviews:(NSArray *)sb;
- (void)addAlwaysFitSubview:(UIView *)subview;

- (CGFloat)height;
- (CGFloat)width;

- (void)setOrigin:(CGPoint)origin;
- (void)setSize:(CGSize)size;
- (void)setX:(CGFloat)x;
- (void)setY:(CGFloat)y;
- (void)setWidth:(CGFloat)width;
- (void)setHeight:(CGFloat)height;

@end


@interface UIImageView (YHAssistant)

+ (id)imageViewWithImageName:(NSString *)imageName;

@end


@interface UILabel (YHAssistant)

- (void)setFontSize:(NSInteger)size;
- (void)setTextWithDate:(NSDate *)date dateFormat:(NSString *)format;
- (CGFloat)adjustHeightWithText:(NSString *)text constrainedToLineCount:(NSUInteger)maxLineCount;
- (CGFloat)setText:(NSString *)text constrainedToLineCount:(NSUInteger)maxLineCount;

@end


@interface UITextField (YHAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters;

@end


@interface UITextView (YHAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters;

@end


@interface NSDateFormatter (YOHO)

+ (NSDateFormatter *)sharedFormatter;

@end

@interface NSDate (YHAssistant)

//若format为nil ,默认为 yyyy.MM.dd HH: mm: ss 格式
- (NSString *)stringRepresentationWithDateFormat:(NSString *)format;

@end

@interface NSData (YHAssistant)

- (NSString *)md5Data;

@end


