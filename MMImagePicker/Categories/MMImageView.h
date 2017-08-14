//
//  MMImageView.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <YYKit/YYKit.h>

// 边框类型
typedef NS_ENUM(NSInteger, MM_ImageViewBorderType) {
    MM_ImageViewBorderType_Rectangle = 0,
    MM_ImageViewBorderType_Circle,
    MM_ImageViewBorderType_Unknown = 99
};

typedef void (^ImageBlock)(UIImage *image, NSURL *imageUrl);
typedef void (^ImageTapBlock)(void);

@interface MMImageView : YYAnimatedImageView

@property (nonatomic, copy) ImageTapBlock imageTapBlock;
@property (copy, nonatomic) IBInspectable UIColor *placeholderColor;
@property (nonatomic, strong) IBInspectable NSString *placeHolderImageName;
@property (nonatomic, strong) IBInspectable UIImage *placeHolderImage;
@property (assign, nonatomic, getter=isEnableTapAction) IBInspectable BOOL enableTapAction;

/**
 @brief  初始化图片
 
 @param frame     图片尺寸
 @param imageName 文件名
 
 @return YH_Image对象
 
 @since 1.0
 */
- (id)initWithFrame:(CGRect)frame placeHolderImageName:(NSString *)imageName;

+ (id)imageViewWithFrame:(CGRect)frame placeHolderImageName:(NSString *)imageName;


- (void)setImage:(UIImage *)image;

- (void)setImageUrl:(NSString *)urlString;

- (void)setImageUrl:(NSString *)urlString completed:(ImageBlock)completedBlock;

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholder;

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholder loadWithAimation:(BOOL)animated;

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholder loadWithAimation:(BOOL)animated completed:(ImageBlock)completedBlock;

- (void)setImageUrl:(NSString *)urlString placeholderImageName:(NSString *)placeholder borderType:(MM_ImageViewBorderType)borderType;

- (void)setImageUrl:(NSString *)urlString placeholderImageName:(NSString *)placeholder borderType:(MM_ImageViewBorderType)borderType borderWidth:(CGFloat)width;

- (void)setImageUrl:(NSString *)urlString placeholderImageName:(NSString *)placeholder borderType:(MM_ImageViewBorderType)borderType borderWidth:(CGFloat)width borderColor:(UIColor *)color;

/**
 @brief  用URL加载图片
 
 @param url         URL字符串
 @param placeholder 默认图片
 
 @since 1.0
 */
- (void)setImageScaleWithUrl:(NSString *)url placeholderImage:(UIImage *)placeholder;

@end
