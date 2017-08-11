//
//  NSObject+MMAssistant.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "MMAssistant.h"
#import <Accelerate/Accelerate.h>

@implementation NSObject (MMAssistant)
- (BOOL)notNilOrEmpty {
    
    if ((NSNull *)self == [NSNull null]) {
        return NO;
    }
    
    if ([self respondsToSelector:@selector(count)]) {
        if ([(id)self count] == 0) {
            return NO;
        }
    }
    
    if ([self respondsToSelector:@selector(length)]) {
        if ([(id)self length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

@end


@implementation NSString (MMAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters
{
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0;
}


- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
    return  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding));
}


- (NSString *)URLEncodedString
{
    return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}


+ (NSString *)stringWithDate:(NSDate *)date dateFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = nil;
    if (format == nil) {
        dateFormat = @"y.MM.dd HH: mm: ss";
    } else {
        dateFormat = format;
    }
    formatter.dateFormat = dateFormat;
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

// 长度是否在一个范围之内
- (BOOL)isLengthGreaterThanOrEqual:(NSInteger)minimum lessThanOrEqual:(NSInteger)maximum
{
    return ([self length] >= minimum) && ([self length] <= maximum);
}


- (NSRange)firstRangeOfURLSubstring
{
    static NSDataDetector *dataDetector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypeLink | NSTextCheckingTypeLink)
                                                       error:nil];
    });
    
    NSRange range = [dataDetector rangeOfFirstMatchInString:self
                                                    options:0
                                                      range:NSMakeRange(0, [self length])];
    return range;
}


- (NSString *)firstURLSubstring
{
    NSRange range = [self firstRangeOfURLSubstring];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    return [self substringWithRange:range];
}


- (NSArray *)URLSubstrings
{
    static NSDataDetector *dataDetector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypeLink | NSTextCheckingTypeLink)
                                                       error:nil];
    });
    
    NSArray *matches = [dataDetector matchesInString:self
                                             options:0
                                               range:NSMakeRange(0, [self length])];
    NSMutableArray *substrings = [NSMutableArray arrayWithCapacity:[matches count]];
    for (NSTextCheckingResult *result in matches) {
        [substrings addObject:[result.URL absoluteString]];
    }
    return [NSArray arrayWithArray:substrings];
}


- (NSString *)firstMatchUsingRegularExpression:(NSRegularExpression *)regularExpression
{
    NSRange range = [regularExpression rangeOfFirstMatchInString:self
                                                         options:0
                                                           range:NSMakeRange(0, [self length])];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    return [self substringWithRange:range];
}


- (NSString *)firstMatchUsingRegularExpressionPattern:(NSString *)regularExpressionPattern
{
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regularExpressionPattern
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    return [self firstMatchUsingRegularExpression:regularExpression];
}


- (BOOL)matchesRegularExpressionPattern:(NSString *)regularExpressionPattern
{
    NSRange fullRange = NSMakeRange(0, [self length]);
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regularExpressionPattern
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    NSRange range = [regularExpression rangeOfFirstMatchInString:self
                                                         options:0
                                                           range:fullRange];
    if (NSEqualRanges(fullRange, range)) {
        return YES;
    }
    return NO;
}


- (NSRange)rangeOfFirstMatchUsingRegularExpressionPattern:(NSString *)regularExpressionPattern
{
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regularExpressionPattern
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    NSRange range = [regularExpression rangeOfFirstMatchInString:self
                                                         options:0
                                                           range:NSMakeRange(0, [self length])];
    return range;
}


- (NSString *)stringByReplacingMatchesUsingRegularExpressionPattern:(NSString *)regularExpressionPattern withTemplate:(NSString *)templ
{
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regularExpressionPattern
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    NSString *string = [regularExpression stringByReplacingMatchesInString:self
                                                                   options:0
                                                                     range:NSMakeRange(0, [self length])
                                                              withTemplate:templ];
    return string;
}


- (NSDictionary *)URLParameters
{
    NSString *urlString = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSRange rangeOfQuestionMark = [urlString rangeOfString:@"?" options:NSBackwardsSearch];
    if (rangeOfQuestionMark.location == NSNotFound) {
        return nil;
    }
    
    NSString *parametersString = [urlString substringFromIndex:(rangeOfQuestionMark.location + 1)];
    NSArray *pairs = [parametersString componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[pairs count]];
    for (NSString *aPair in pairs) {
        NSArray *keyAndValue = [aPair componentsSeparatedByString:@"="];
        if ([keyAndValue count] == 2) {
            [parameters setObject:keyAndValue[1] forKey:keyAndValue[0]];
        }
    }
    return parameters;
}

@end


@implementation NSDictionary (MMAssistant)


- (NSMutableDictionary *)mutableDeepCopy
{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    NSArray *keys = [self allKeys];
    for (id key in keys)
    {
        id oneValue = [self valueForKey:key];
        id oneCopy = nil;
        
        if ([oneValue respondsToSelector:@selector(mutableDeepCopy)])
            oneCopy = [oneValue mutableDeepCopy];
        else if ([oneValue respondsToSelector:@selector(mutableCopy)])
            oneCopy = [oneValue mutableCopy];
        if (oneCopy == nil)
            oneCopy = [oneValue copy];
        [ret setValue:oneCopy forKey:key];
    }
    return ret;
}


- (NSString *)stringRepresentationByURLEncoding
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [self allKeys])
    {
        id object = [self objectForKey:key];
        if (![object isKindOfClass:[NSString class]]) {
            continue;
        }
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [object URLEncodedString]]];
    }
    return [pairs componentsJoinedByString:@"&"];
}


- (NSString *)stringForKey:(id)key
{
    id object = [self objectForKey:key];
    if ([object isEqual:[NSNull null]]) {
        return @"";
    }
    if (![object isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@", object];
    }
    return object;
}


- (NSDate *)dateForKey:(id)key
{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSDate class]]) {
        return object;
    }
    
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        NSTimeInterval timeInterval = [number doubleValue];
        return [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    
    return nil;
}


- (NSInteger)integerForKey:(id)key
{
    id object = [self objectForKey:key];
    if ([object respondsToSelector:@selector(integerValue)]) {
        NSNumber *number = (NSNumber *)object;
        return [number integerValue];
    }
    
    return 0;
}

@end


@implementation UIImageView (MMAssistant)

+ (id)imageViewWithImageName:(NSString *)imageName
{
    return [[self alloc] initWithImage:[UIImage imageNamed:imageName]];
}

@end


@implementation UIView (MMAssistant)


- (void)removeAllSubviews
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}

- (void)addSubviews:(NSArray *)sb
{
    if ([sb count] == 0) {
        return;
    }
    
    [sb enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addSubview:obj];
    }];
}

- (void)addAlwaysFitSubview:(UIView *)subview
{
    subview.frame = self.bounds;
    if (NSClassFromString(@"NSLayoutConstraint")) {
        [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:subview];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:subview
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    }
    else {
        subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:subview];
    }
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height
{
    if (height< 0.0f) {
        height = 0.f;
    }
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end


@implementation UILabel (MMAssistant)


- (void)setFontSize:(NSInteger)size
{
    self.font = [UIFont systemFontOfSize:size];
}


- (void)setTextWithDate:(NSDate *)date dateFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = nil;
    if (format == nil) {
        dateFormat = @"yyyy.MM.dd HH: mm: ss";
    } else {
        dateFormat = format;
    }
    formatter.dateFormat = dateFormat;
    NSString *dateString = [formatter stringFromDate:date];
    self.text = dateString;
}


- (CGFloat)adjustHeightWithText:(NSString *)text constrainedToLineCount:(NSUInteger)maxLineCount
{
    CGFloat height = 0.0f;
    if (maxLineCount == 0) {
        CGSize size = [text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size;
        height = size.height;
    }
    else {
        NSMutableString *testString = [NSMutableString stringWithString:@"X"];
        for (NSInteger i = 0; i < maxLineCount - 1; i++) {
            [testString appendString:@"\nX"];
        }
        
        CGFloat maxHeight = [testString boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size.height;
        CGFloat textHeight = [text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size.height;
        height = MIN(maxHeight, textHeight);
    }
    
    height = ceilf(height);
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    self.numberOfLines = maxLineCount;
    return height;
}

- (CGFloat)setText:(NSString *)text constrainedToLineCount:(NSUInteger)maxLineCount
{
    CGFloat height = [self adjustHeightWithText:text constrainedToLineCount:maxLineCount];
    self.numberOfLines = maxLineCount;
    self.text = text;
    return height;
}

@end

@implementation UIImage (MMAssistant)

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile compress:(BOOL)compress
{
    //    CGFloat quality = 1.0f;
    if (compress) {
        NSString *photoQuality = [[NSUserDefaults standardUserDefaults] objectForKey:@"phtotQuality"];
        NSData *data = (photoQuality ? UIImageJPEGRepresentation(self, [photoQuality floatValue]) : UIImageJPEGRepresentation(self, 1.0f));
        
        NSString *parentDirPath = [path stringByDeletingLastPathComponent];
        BOOL isExistDir = [[NSFileManager defaultManager] fileExistsAtPath:parentDirPath];
        if (!isExistDir)
        {
            NSLog(@"\n\n错误:writeToFile:atomically:compress: 在存储图片%@时 发现父级目录不存在", path);
            return NO;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSLog(@"\n\n警告:writeToFile:atomically:compress: 在存储图片%@时 发现同名文件已经存在, 将有可能被覆盖", path);
        }
        
        return [data writeToFile:path atomically:useAuxiliaryFile];
    }
    else {
        NSString *parentDirPath = [path stringByDeletingLastPathComponent];
        BOOL isExistDir = [[NSFileManager defaultManager] fileExistsAtPath:parentDirPath];
        if (!isExistDir) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        NSData *imageData = UIImagePNGRepresentation(self);
        return [imageData writeToFile:path atomically:useAuxiliaryFile];
    }
}


- (BOOL)writeToFile:(NSString *)path  quality:(CGFloat)quality atomically:(BOOL)useAuxiliaryFile compress:(BOOL)compress
{
    if (compress) {
        NSString *photoQuality = [[NSUserDefaults standardUserDefaults] objectForKey:@"phtotQuality"];
        NSData *data = (photoQuality ? UIImageJPEGRepresentation(self, [photoQuality floatValue]) : UIImageJPEGRepresentation(self, quality));
        
        NSString *parentDirPath = [path stringByDeletingLastPathComponent];
        BOOL isExistDir = [[NSFileManager defaultManager] fileExistsAtPath:parentDirPath];
        if (!isExistDir)
        {
            NSLog(@"\n\n错误:writeToFile:atomically:compress: 在存储图片%@时 发现父级目录不存在", path);
            return NO;
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSLog(@"\n\n警告:writeToFile:atomically:compress: 在存储图片%@时 发现同名文件已经存在, 将有可能被覆盖", path);
        }
        
        return [data writeToFile:path atomically:useAuxiliaryFile];
    }
    else {
        NSData *imageData = UIImagePNGRepresentation(self);
        return [imageData writeToFile:path atomically:useAuxiliaryFile];
    }
}


- (UIImage *)imageInRect:(CGRect)aRect
{
    CGImageRef cg = self.CGImage;
    CGFloat scale = self.scale;
    CGRect rectInCGImage = CGRectMake(aRect.origin.x * scale, aRect.origin.y * scale, aRect.size.width * scale, aRect.size.height * scale);
    CGImageRef newCG = CGImageCreateWithImageInRect(cg, rectInCGImage);
    UIImage *image = [UIImage imageWithCGImage:newCG scale:scale orientation:self.imageOrientation];
    CGImageRelease(newCG);
    return image;
}

- (UIImage *)imageInRect:(CGRect)aRect scale:(CGFloat)scale
{
    CGImageRef cg = self.CGImage;
    CGRect rectInCGImage = CGRectMake(aRect.origin.x * scale, aRect.origin.y * scale, aRect.size.width * scale, aRect.size.height * scale);
    CGImageRef newCG = CGImageCreateWithImageInRect(cg, rectInCGImage);
    UIImage *image = [UIImage imageWithCGImage:newCG scale:scale orientation:self.imageOrientation];
    CGImageRelease(newCG);
    return image;
}


- (UIImage *)centerSquareImage
{
    CGImageRef cg = self.CGImage;
    size_t width = CGImageGetWidth(cg);
    size_t height = CGImageGetHeight(cg);
    size_t length = MIN(width, height);
    CGRect rect = CGRectMake(((width / 2.0f) - (length / 2.0f)), ((height / 2.0f) - (length / 2.0f)), length, length);
    CGImageRef newCG = CGImageCreateWithImageInRect(cg, rect);
    UIImage *image = [UIImage imageWithCGImage:newCG scale:kScreenScale orientation:self.imageOrientation];
    CGImageRelease(newCG);
    return image;
}


- (UIImage *)imageScaledToFitUploadSize
{
    UIImage *imageWithoutScale = [UIImage imageWithCGImage:self.CGImage scale:1.0f orientation:self.imageOrientation];
    CGSize size = imageWithoutScale.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return self;
    }
    
    if ((size.width * size.height) <= 320000.0f) {
        return self;
    }
    
    CGFloat scale = sqrtf(320000.0f / size.width / size.height);
    CGSize newSize = CGSizeMake(ceilf(size.width * scale), ceilf(size.height * scale));
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0f);
    [imageWithoutScale drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)]; // the actual scaling happens here, and orientation is taken care of automatically.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage *)scaledToFitSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *) maskWithImage:(const UIImage *) maskImage
{
    if(!maskImage)
    {
        NSLog(@"Error:maskWithImage is nil");
        return nil;
    }
    CGImageRef imageRef = maskImage.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef mainViewContentContext = CGBitmapContextCreate(NULL,
                                                                imageSize.width,
                                                                imageSize.height,
                                                                CGImageGetBitsPerComponent(imageRef),
                                                                0,
                                                                colorSpace,
                                                                bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextClipToMask(mainViewContentContext, imageRect, imageRef);
    CGContextDrawImage(mainViewContentContext, imageRect, self.CGImage);
    
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    return theImage;
    
}

+ (UIImage *)retina4CompatibleImageNamed:(NSString *)imageName
{
    if (kScreenIs4InchRetina) {
        NSString *retina4ImageName = [imageName stringByAppendingString:@"-568h"];
        return [UIImage imageNamed:retina4ImageName];
    }
    else {
        return [UIImage imageNamed:imageName];
    }
}


+ (UIImage *)patternImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color set];
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0.0f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0.0f, self.size.height);
            transform = CGAffineTransformRotate(transform, - M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0.0f);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0.0f);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0.0f,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0.0f, 0.0f, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// 设置图片模糊效果
+ (UIImage *)blurredImageWithImage:(UIImage *)image blur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    //create vImage_Buffer with data from CGImageRef
    if (img == NULL) {
        return image;
    }
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL){
        NSLog(@"No pixelbuffer");
        //如果申请内存失败返回原图
        CFRelease(inBitmapData);
        return image;
    }
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //    CGBitmapInfo
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    return returnImage;
}

+ (UIImage *)boxblurImageWithImage:(UIImage *)image Blur:(CGFloat)blur {
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(img);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    CGColorSpaceRef deviceRGB = CGColorSpaceCreateDeviceRGB();
    
    CGColorSpaceModel deviceModel = CGColorSpaceGetModel(deviceRGB);
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(colorSpace);
    Boolean isEqual = (deviceModel == colorModel);
    //    Boolean isEqual = CFEqual(deviceRGB, colorSpace);
    //perform convolution
    if(!isEqual) {
        error = vImageBoxConvolve_Planar8(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, 0, kvImageEdgeExtend);
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
        error = vImageBoxConvolve_Planar8(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, 0, kvImageEdgeExtend);
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
        error = vImageBoxConvolve_Planar8(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, 0, kvImageEdgeExtend);
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
    } else {
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
        error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
        error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        if (error) {
            NSLog(@"error from convolution %ld", error);
        }
    }
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             CGImageGetBitsPerComponent(img),
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(img));
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    //    CGColorSpaceRelease(colorSpace);
    CGColorSpaceRelease(deviceRGB);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

+ (UIImage *)circleImageWithImage:(UIImage *)originImage borderWidth:(CGFloat)bWidth borderColor:(UIColor *)bColor
{
    if (!originImage) {
        return nil;
    }
    
    CGFloat newSideLength = 35.f;
    
    CGFloat imageW = newSideLength + bWidth*2;
    CGFloat imageH = imageW;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [bColor set];
    
    CGFloat outerRingRadius = MIN(imageW, imageH) * 0.5f;
    CGFloat centerX = outerRingRadius;
    CGFloat centerY = imageH * .5f;
    
    CGContextAddArc(context, centerX, centerY, outerRingRadius, 0, M_PI*2, 0);
    CGContextFillPath(context);
    
    CGFloat innerRingRadius = outerRingRadius - bWidth;
    CGContextAddArc(context, centerX, centerY, innerRingRadius, 0, M_PI*2, 0);
    CGContextClip(context);
    CGFloat convertedImageW = originImage.size.width<originImage.size.height?newSideLength:(originImage.size.width/originImage.size.height*newSideLength);
    CGFloat convertedImageH = originImage.size.width<originImage.size.height?(originImage.size.height/originImage.size.width*newSideLength):newSideLength;
    [originImage drawInRect:CGRectMake((imageW-convertedImageW)/2,
                                       (imageH-convertedImageH)/2,
                                       convertedImageW,
                                       convertedImageH)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)rectangleImageWithImage:(UIImage *)originImage borderWidth:(CGFloat)bWidth borderColor:(UIColor *)bColor {
    
    CGFloat imageW = originImage.size.width + bWidth*2;
    CGFloat imageH = originImage.size.height + bWidth*2;
    
    CGFloat sizeWH = MIN(imageW, imageH);
    CGFloat sizeImage = MIN(originImage.size.width, originImage.size.height);
    
    CGSize imageSize = CGSizeMake(sizeWH, sizeWH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [bColor set];
    
    CGContextAddRect(context, CGRectMake(0, 0, sizeWH, sizeWH));
    CGContextFillPath(context);
    CGContextAddRect(context, CGRectMake(bWidth, bWidth, sizeImage, sizeImage));
    
    CGContextClip(context);
    
    if (originImage) {
        [originImage drawInRect:CGRectMake((sizeWH-originImage.size.width)/2,
                                           (sizeWH-originImage.size.height)/2,
                                           originImage.size.width,
                                           originImage.size.height)];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end


@implementation UITextField (MMAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters
{
    return self.text == nil || [self.text isEmptyAfterTrimmingWhitespaceAndNewlineCharacters];
}

@end


@implementation UITextView (MMAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters
{
    return self.text == nil || [self.text isEmptyAfterTrimmingWhitespaceAndNewlineCharacters];
}

@end

@implementation NSDateFormatter (MMAssistant)

static NSDateFormatter *formatter_ = nil;
+ (NSDateFormatter *)sharedFormatter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter_ = [[NSDateFormatter alloc] init];
        [formatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    
    return formatter_;
}

@end

@implementation NSDate (MMAssistant)

- (NSString *)stringRepresentationWithDateFormat:(NSString *)format
{
    formatter_ = [NSDateFormatter sharedFormatter];
    NSString *dateFormat = nil;
    if (format == nil) {
        dateFormat = @"yyyy-MM-dd HH-mm-ss";
    } else {
        dateFormat = format;
    }
    formatter_.dateFormat = dateFormat;
    NSString *dateString = [formatter_ stringFromDate:self];
    return dateString;
}

@end
