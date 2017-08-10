//
//  MMImagePickerCell.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "MMImagePickerCell.h"

#define kImagePickerSelectedViewWidth    23.0f
#define kImagePickerSelectedViewMargin    2.0f

@implementation MMImagePickerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.imageView];
        
        self.maskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        self.maskView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
        self.maskView.alpha = 0.4;
        self.maskView.hidden = YES;
        self.maskView.userInteractionEnabled = NO;
        [self.imageView addSubview:self.maskView];
        
        UIImage *selectedImage = [UIImage imageNamed:@"route_yes"];
        UIImage *unselectImage = [UIImage imageNamed:@"route_no"];
        
        self.selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - kImagePickerSelectedViewWidth - kImagePickerSelectedViewMargin, kImagePickerSelectedViewMargin, kImagePickerSelectedViewWidth, kImagePickerSelectedViewWidth)];
        self.selectedView.backgroundColor = [UIColor clearColor];
        self.selectedView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.selectedView.image = unselectImage;
        self.selectedView.highlightedImage = selectedImage;
        [self.contentView addSubview:self.selectedView];
        self.selectedView.highlighted = NO;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self showSelected:NO animated:NO];
}

- (BOOL)isMarked {
    return self.selectedView.highlighted;
}

// Do not delete this method!!
// Override this method for manually set the `selectedView`'s highlighted property.
- (void)setHighlighted:(BOOL)highlighted {
    
}
// Do not delete this method!!
// Override this method for manually set the `selectedView`'s highlighted property.
- (void)setSelected:(BOOL)selected {
    
}

- (void)showSelected:(BOOL)selected animated:(BOOL)animated {
    
    [self.maskView setHidden:!selected];
    self.selectedView.hidden = NO;
    self.selectedView.highlighted = selected;
    
    if (animated && selected) {
        [NSObject pop_animate:^{
            self.imageView.pop_springSpeed = 40;
            self.imageView.pop_springBounciness = 5;
            self.imageView.pop_spring.pop_scaleXY = CGPointMake(0.96, 0.96);
        } completion:^(BOOL finished) {
            self.imageView.pop_springSpeed = 30;
            self.imageView.pop_springBounciness = 20;
            self.imageView.pop_spring.pop_scaleXY = CGPointMake(1.0, 1.0);
        }];
    }

}

@end

@implementation ALAssetsGroup (YOHO)

- (UIImage *)getFirstPhotoImage {
    
    [self setAssetsFilter:[ALAssetsFilter allPhotos]];
    if ([self numberOfAssets] == 0) {
        return nil;
    }
    
    __block UIImage *image = nil;
    [self enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]){
                image = [UIImage imageWithCGImage:[result thumbnail]];
                *stop = YES;
            }
        }
    }];
    
    return image;
}

- (UIImage *)getFirstVideoImage {
    
    [self setAssetsFilter:[ALAssetsFilter allVideos]];
    if ([self numberOfAssets] == 0) {
        return nil;
    }
    
    __block UIImage *image = nil;
    [self enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                image = [UIImage imageWithCGImage:[result thumbnail]];
                *stop = YES;
            }
        }
    }];
    
    return image;
}

@end

