//
//  MMPreviewImageCell.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "MMPreviewImageCell.h"

@interface MMPreviewImageCell ()

@property (assign, nonatomic) CGFloat lastScale;
@property (assign, nonatomic) CGFloat currentScale;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

@end

@implementation MMPreviewImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.currentScale = 1.0;
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.imageView];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self.imageView addGestureRecognizer:pinchRecognizer];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        self.lastScale = [recognizer scale];
    }
    
    CGFloat newScale = 1 -  (self.lastScale - [recognizer scale]);
    
    if ([recognizer state] == UIGestureRecognizerStateBegan ||
        [recognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat scale = [[[recognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 0.8;
        
        newScale = MIN(newScale, kMaxScale / scale);
        newScale = MAX(newScale, kMinScale / scale);
        
        recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, newScale, newScale);
        self.currentScale = newScale;
        self.lastScale = [recognizer scale];
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded ||
        [recognizer state] == UIGestureRecognizerStateCancelled) {
        if (self.currentScale < 1.0) {
            [self.imageView removeGestureRecognizer:self.panGesture];
            recognizer.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        } else if (self.currentScale == 1.0) {
            [self.imageView removeGestureRecognizer:self.panGesture];
        } else {
            [self.imageView addGestureRecognizer:self.panGesture];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer {
    CGPoint translation = [recognizer translationInView:[self superview]];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:[self superview]];
}


@end
