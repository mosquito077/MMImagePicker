//
//  NSObject+MMAssistant.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "MMAssistant.h"
#import <Accelerate/Accelerate.h>

void mm_dispatch_execute_in_worker_queue(dispatch_block_t block)
{
    dispatch_queue_t workerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(workerQueue, block);
}


void mm_dispatch_execute_in_main_queue(dispatch_block_t block)
{
    dispatch_async(dispatch_get_main_queue(), block);
}


void mm_dispatch_execute_in_main_queue_after(int64_t delay, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}


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

@end


@implementation UIImage (MMAssistant)

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
