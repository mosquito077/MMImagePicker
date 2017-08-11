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

#if TARGET_OS_IOS
- (NSString *)customeTimeStringFormat
{
    if (![self isPureDigital]) {
        return @"";
    }
    
    NSTimeInterval originTimeInterval = [self doubleValue];
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval deltaInterval = currentTimeInterval - originTimeInterval;
    if (deltaInterval <= 0) {
        return @"";
    }
    
    NSTimeInterval secondsPerMin = 60;
    NSTimeInterval secondsPerHour = 60*60;
    NSTimeInterval secondsPerDay = secondsPerHour * 24;
    NSTimeInterval secondsPerYear = secondsPerDay * 365;
    
    if (deltaInterval > 0 && deltaInterval < secondsPerMin) {
        return @"刚刚"; //xx秒前
    }
    if (deltaInterval >= secondsPerMin && deltaInterval < secondsPerHour) {
        
        return [NSString stringWithFormat:@"%.0f分钟前",floorf(deltaInterval/secondsPerMin)];
    }
    if (deltaInterval >= secondsPerHour && deltaInterval < secondsPerDay) {
        return [NSString stringWithFormat:@"%.0f小时前",floorf(deltaInterval/secondsPerHour)];
    }
    
    NSDate *originDate = [NSDate dateWithTimeIntervalSince1970:originTimeInterval];
    NSString *originDateString = [[NSDateFormatter sharedFormatter] stringFromDate:originDate];
    
    if (deltaInterval >= secondsPerDay && deltaInterval < secondsPerYear) {
        return [originDateString substringWithRange:NSMakeRange(5, 5)];
    }
    if (deltaInterval >= secondsPerYear) {
        return [originDateString substringToIndex:9];
    }
    
    return @"";
    
}

inline NSUInteger yh_asciiLengthOfString(NSString *text) {
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++) {
        
        unichar uc = [text characterAtIndex:i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    
    return asciiLength;
}

- (NSString *)getConstraintedStringWithLength:(NSInteger)length {
    __block NSInteger stringLength = 0;
    __block BOOL shouldTruncate = NO;
    NSString *outputString = self;
    NSMutableString *newSubString = [[NSMutableString alloc] initWithString:@""];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              stringLength += yh_asciiLengthOfString(substring);
                              if (stringLength >= (length*2)) {
                                  shouldTruncate = YES;
                                  *stop = YES;
                                  return;
                              }
                              
                              if (stringLength < (length*2-3)) {
                                  [newSubString appendFormat:@"%@", substring];
                              }
                          }];
    
    if (shouldTruncate) {
        outputString = [NSString stringWithFormat:@"%@...", newSubString];
    }
    
    return outputString;
}

- (CGFloat)calculateHeightWithAttributes:(NSDictionary *)attributesDictionary constraintWidth:(CGFloat)width {
    return [self calculateHeightWithAttributes:attributesDictionary constraintWidth:width maximumLineOfRows:0];
}

- (CGFloat)calculateHeightWithAttributes:(NSDictionary *)attributesDictionary constraintWidth:(CGFloat)width maximumLineOfRows:(NSInteger)rows {
    return [self calculateHeightWithAttributes:attributesDictionary constraintWidth:width maximumLineOfRows:rows lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGFloat)calculateHeightWithAttributes:(NSDictionary *)attributesDictionary constraintWidth:(CGFloat)width maximumLineOfRows:(NSInteger)rows lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGFloat height = 0.f;
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 300.f)];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 300.f)];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.lineBreakMode = lineBreakMode;
    label.attributedText = [[NSAttributedString alloc] initWithString:self
                                                           attributes:attributesDictionary];
    label.numberOfLines = rows;
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired
                                           forAxis:UILayoutConstraintAxisVertical];
    [label setContentHuggingPriority:UILayoutPriorityRequired
                             forAxis:UILayoutConstraintAxisVertical];
    [container addSubview:label];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:label
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:container
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:label
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:container
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:label
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:container
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:container
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    NSLayoutConstraint *widthC = [NSLayoutConstraint constraintWithItem:container
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:width];
    [container addConstraints:@[ leading, trailing, top, bottom, widthC ]];
    CGSize size = [container systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    height = size.height;
    return height;
}

#endif

@end
