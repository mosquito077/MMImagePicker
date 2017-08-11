//
//  NSObject+MMAssistant.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (MMAssistant)
- (BOOL)notNilOrEmpty;

@end

@interface NSString (MMAssistant)

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

@interface NSDictionary (MMAssistant)

- (NSMutableDictionary *)mutableDeepCopy;
- (NSString *)stringRepresentationByURLEncoding;
- (NSString *)stringForKey:(id)key;
- (NSDate *)dateForKey:(id)key;
- (NSInteger)integerForKey:(id)key;

@end

@interface UIView (MMAssistant)

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


@interface UIImageView (MMAssistant)

+ (id)imageViewWithImageName:(NSString *)imageName;

@end

@interface UIImage (MMAssistant)

// 如果参数比原image的size小，是截取原image相应的rect里的部分，如果参数比原image大，则是白底填充原image
- (UIImage *)imageInRect:(CGRect)aRect;

- (UIImage *)imageInRect:(CGRect)aRect scale:(CGFloat)scale;

- (UIImage *)centerSquareImage;
- (UIImage *) maskWithImage:(const UIImage *) maskImage;//使用maskImage遮罩原来图片
- (UIImage *)imageScaledToFitUploadSize;
- (UIImage *)scaledToFitSize:(CGSize)size;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile compress:(BOOL)compress;
- (BOOL)writeToFile:(NSString *)path quality:(CGFloat)quality atomically:(BOOL)useAuxiliaryFile compress:(BOOL)compress;
- (UIImage *)fixOrientation;
+ (UIImage *)retina4CompatibleImageNamed:(NSString *)imageName;
+ (UIImage *)patternImageWithColor:(UIColor *)color;
+ (UIImage *)blurredImageWithImage:(UIImage *)image blur:(CGFloat)blur;
+ (UIImage *)boxblurImageWithImage:(UIImage *)image Blur:(CGFloat)blur;
+ (UIImage *)circleImageWithImage:(UIImage *)originImage borderWidth:(CGFloat)bWidth borderColor:(UIColor *)bColor;
+ (UIImage *)rectangleImageWithImage:(UIImage *)originImage borderWidth:(CGFloat)bWidth borderColor:(UIColor *)bColor;
@end



@interface UILabel (MMAssistant)

- (void)setFontSize:(NSInteger)size;
- (void)setTextWithDate:(NSDate *)date dateFormat:(NSString *)format;
- (CGFloat)adjustHeightWithText:(NSString *)text constrainedToLineCount:(NSUInteger)maxLineCount;
- (CGFloat)setText:(NSString *)text constrainedToLineCount:(NSUInteger)maxLineCount;

@end


@interface UITextField (MMAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters;

@end


@interface UITextView (MMAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters;

@end


@interface NSDateFormatter (MMAssistant)

+ (NSDateFormatter *)sharedFormatter;

@end

@interface NSDate (MMAssistant)

//若format为nil ,默认为 yyyy.MM.dd HH: mm: ss 格式
- (NSString *)stringRepresentationWithDateFormat:(NSString *)format;

@end

@interface NSData (MMAssistant)

- (NSString *)md5Data;

@end

