//
//  NSString+MM.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "NSString+MM.h"

#define g_screenScale                       2.f

extern unsigned char *CC_MD5(const void *data, uint32_t len, unsigned char *md)
__OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_2_0);

@implementation NSString (MM)

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
#if TARGET_OS_IOS
    return  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding));
#else
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
#endif
}

- (NSString *)URLEncodedString
{
    return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)md5String
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (uint32_t)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

// 长度是否在一个范围之内
- (BOOL)isLenghGreaterThanOrEqual:(NSInteger)minimum lessThanOrEqual:(NSInteger)maximum
{
    return ([self length] >= minimum) && ([self length] <= maximum);
}

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters
{
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0;
}

#if TARGET_OS_IOS
-(NSMutableAttributedString *)attributedStringFromStingWithFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing lineBreakMode:(NSLineBreakMode)breakMode
{
    return [self attributedStringFromStingWithFont:font lineSpacing:lineSpacing lineBreakMode:breakMode alignment:NSTextAlignmentLeft];
}

-(NSMutableAttributedString *)attributedStringFromStingWithFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing lineBreakMode:(NSLineBreakMode)breakMode alignment:(NSTextAlignment)alignment
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName:font}];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setLineBreakMode:breakMode];
    [paragraphStyle setAlignment:alignment];
    
    [attributedStr addAttribute:NSParagraphStyleAttributeName
                          value:paragraphStyle
                          range:NSMakeRange(0, [self length])];
    return attributedStr;
}

-(CGSize)boundingRectWithSize:(CGSize)size textFont:(UIFont *)font lineSpacing:(CGFloat)lineSpacing lineBreakMode:(NSLineBreakMode)breakMode
{
    NSMutableAttributedString *attributedText = [self attributedStringFromStingWithFont:font
                                                                            lineSpacing:lineSpacing lineBreakMode:breakMode];
    CGSize textSize = [attributedText boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil].size;
    return textSize;
}

- (NSInteger)stringLinesWithFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)breakMode inSize:(CGSize)size
{
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:self attributes:@{NSFontAttributeName : font}];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    textContainer.lineBreakMode = breakMode;
    textContainer.maximumNumberOfLines = 0;
    textContainer.lineFragmentPadding = 0;
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    layoutManager.textStorage = textStorage;
    [layoutManager addTextContainer:textContainer];
    
    NSInteger numberOfLines = 0;
    NSInteger index = 0;
    NSRange lineRange = NSMakeRange(0, 0);
    
    for (; index < layoutManager.numberOfGlyphs; numberOfLines ++) {
        [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    
    return numberOfLines;
}
#endif

- (BOOL)isPureDigital
{
    NSScanner* scan = [NSScanner scannerWithString:self];
    long long val;
    return [scan scanLongLong:&val] && [scan isAtEnd];
}

- (NSString *)validImageURLWithWidth:(CGFloat)width height:(CGFloat)height mode:(NSInteger)mode
{
    NSString *string = nil;
#if TARGET_OS_IOS
    NSString *widthString =[NSString stringWithFormat:@"%.0f",width*g_screenScale];
    NSString *heightString = [NSString stringWithFormat:@"%.0f",height*g_screenScale];
    string = [[[[self stringByReplacingOccurrencesOfString:@"{width}" withString:widthString] stringByReplacingOccurrencesOfString:@"{height}" withString:heightString] stringByReplacingOccurrencesOfString:@"{mode}" withString:@(mode).stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#else
    NSString *widthString =[NSString stringWithFormat:@"%.0f",width*2];
    NSString *heightString = [NSString stringWithFormat:@"%.0f",height*2];
    string = [[[[self stringByReplacingOccurrencesOfString:@"{width}" withString:widthString] stringByReplacingOccurrencesOfString:@"{height}" withString:heightString] stringByReplacingOccurrencesOfString:@"{mode}" withString:@(mode).stringValue] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
#endif
    
    
    return string;
}

- (NSString *)validImageURLWithWidth:(CGFloat)width height:(CGFloat)height
{
    return [self validImageURLWithWidth:width height:height mode:2];
}

@end
