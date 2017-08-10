//
//  MM_PictureCell.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MM_PictureCell : UITableViewCell

@property (copy, nonatomic) void (^tapAddPictureBlock)(void);
@property (copy, nonatomic) void (^tapPictureInfoBlock)(NSInteger);
@property (copy, nonatomic) void (^tapDeletePictureBlock)(NSInteger);
@property (strong, nonatomic) UILabel *infoLabel;

@property (nonatomic) NSInteger maxSelectNum;   // Default is 9

- (void)updateImageView:(NSArray *)array;

+ (CGFloat)heightForPictureCell:(NSArray *)array;

@end
