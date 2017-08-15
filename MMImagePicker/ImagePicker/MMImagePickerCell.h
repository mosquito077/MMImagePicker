//
//  MMImagePickerCell.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MMImagePickerCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIImageView *selectedView;

@property (readonly, nonatomic) BOOL isMarked;

- (void)showSelected:(BOOL)selected animated:(BOOL)animated;

@end

