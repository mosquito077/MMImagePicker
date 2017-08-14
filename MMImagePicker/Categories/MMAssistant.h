//
//  NSObject+MMAssistant.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern void mm_dispatch_execute_in_worker_queue(dispatch_block_t block);
extern void mm_dispatch_execute_in_main_queue(dispatch_block_t block);
extern void mm_dispatch_execute_in_main_queue_after(int64_t delay, dispatch_block_t block);


@interface NSObject (MMAssistant)

- (BOOL)notNilOrEmpty;

@end


@interface NSString (MMAssistant)

- (BOOL)isEmptyAfterTrimmingWhitespaceAndNewlineCharacters;
- (NSString *)stringByTrimmingWhitespaceAndNewlineCharacters;

@end


@interface UIImage (MMAssistant)

+ (UIImage *)circleImageWithImage:(UIImage *)originImage borderWidth:(CGFloat)bWidth borderColor:(UIColor *)bColor;
+ (UIImage *)rectangleImageWithImage:(UIImage *)originImage borderWidth:(CGFloat)bWidth borderColor:(UIColor *)bColor;

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

