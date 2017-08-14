//
//  MM_PictureCell.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "MM_PictureCell.h"
#import "YH_PhotoInfo.h"
#import "AssetHelper.h"

static CGFloat const kLeftSpace = 10.0f;
static CGFloat const kImageViewMiddleEdge = 13.0f;
static CGFloat const kImageButtonTag = 1200;

@interface MM_PictureCell()

@property (nonatomic, assign) CGFloat imageViewSize;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation MM_PictureCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:10.f];
        _infoLabel.textColor = [UIColor colorWithHexString:@"b0b0b0"];
        _infoLabel.text = NSLocalizedString(@"添加图片（非必选）", nil);
    }
    return _infoLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(10.f,
                                                             CGRectGetHeight(self.frame)-1.f,
                                                             kScreenWidth-10.f,
                                                             1.f)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"e0e0e0"];
    }
    return _lineView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageViewSize = (kScreenWidth - kLeftSpace*2 - kImageViewMiddleEdge*3)/4;
        self.maxSelectNum = 9;
        [self addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setHeight:CGRectGetHeight(self.frame)];     //确保contentView高度调整了
    self.lineView.frame = CGRectMake(10.f, CGRectGetHeight(self.frame)-1.f, kScreenWidth-10.f, 1.f);
}

- (void)updateWithPhotos:(NSArray<YH_PhotoInfo *> *)photos {
    NSMutableArray *imageArray = [[NSMutableArray alloc] initWithCapacity:photos.count];
    
    [photos enumerateObjectsUsingBlock:^(YH_PhotoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ALAsset *asset = obj.asset;
        UIImage *image = [ASSETHELPER getImageFromAsset:asset type:ASSET_PHOTO_ASPECT_THUMBNAIL];
        [imageArray addObject:image];
    }];
    
    [self updateImageView:imageArray];
}

- (void)updateImageView:(NSArray *)array {
    [self.contentView removeAllSubviews];
    NSInteger total = array.count;
    if (total < self.maxSelectNum) {
        total++;
    }
    
    UIButton *button = nil;
    MMImageView *deleteView = nil;
    for (int i=0; i<total; i++) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = kImageButtonTag+i;
        button.contentMode = UIViewContentModeScaleAspectFill;
        button.clipsToBounds = YES;
        
        //刪除icon
        deleteView = [[MMImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]];
        WS(weakSelf);
        deleteView.enableTapAction = YES;
        deleteView.imageTapBlock = ^(void) {
            NSInteger num = button.tag - kImageButtonTag;
            !weakSelf.tapDeletePictureBlock ?: weakSelf.tapDeletePictureBlock(num);
        };
        
        BOOL isShowDelete = YES;
        if (i == total-1 && array.count != self.maxSelectNum) {
            //添加icon
            UIImage *image = [UIImage imageNamed:@"add_image"];
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addPicturesAction) forControlEvents:UIControlEventTouchUpInside];
            
            isShowDelete = NO;
        } else {
            UIImage *image = [array objectAtIndex:i];
            [button setImage:image forState:UIControlStateNormal];
            [button.imageView setContentMode:UIViewContentModeScaleAspectFill];
            [button addTarget:self action:@selector(tapPictureAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        button.frame = CGRectMake(kLeftSpace+(self.imageViewSize+kImageViewMiddleEdge)*(i%4), kLeftSpace+(self.imageViewSize+kLeftSpace)*(i/4), self.imageViewSize, self.imageViewSize);
        deleteView.frame = CGRectMake((CGRectGetMinX(button.frame)+(self.imageViewSize-17.f)), CGRectGetMinY(button.frame)-5.f, 22.f, 22.f);
        
        [self.contentView addSubview:button];
        if (isShowDelete) {
            [self.contentView addSubview:deleteView];
        }
        
        if (array.count == 0) {
            self.infoLabel.frame = CGRectMake(CGRectGetMaxX(button.frame)+10.f, kLeftSpace, 200.f, self.imageViewSize);
            [self.contentView addSubview:self.infoLabel];
        } else {
            [self.infoLabel removeFromSuperview];
        }
    }
}

+ (CGFloat)heightForPictureCell:(NSArray *)array {
    NSInteger total = array.count;
    if (total < 9) {
        total++;
    }
    CGFloat flexibleHeight = 0.f;
    CGFloat imageViewSize = (kScreenWidth - kLeftSpace*2 - kImageViewMiddleEdge*3)/4;
    if (total % 4 == 0) {
        flexibleHeight = kLeftSpace+(total/4)*(imageViewSize+kLeftSpace);
    }else {
        flexibleHeight = kLeftSpace+((total/4)+1)*(imageViewSize+kLeftSpace);
    }
    return flexibleHeight;
}

- (void)addPicturesAction {
    !self.tapAddPictureBlock ?: self.tapAddPictureBlock();
}

- (void)tapPictureAction:(UIButton *)button {
    NSInteger num = button.tag - kImageButtonTag;
    !self.tapPictureInfoBlock ?: self.tapPictureInfoBlock(num);
}

@end
