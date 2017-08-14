//
//  UIView+MM.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "UIView+MM.h"
#import "MBProgressHUD.h"
#import <SVProgressHUD/SVProgressHUD.h>

@implementation UIView (MM)

- (instancetype)initWithSize:(CGSize)size
{
    return [self initWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)];
}

- (void)removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)addSubviews:(NSArray *)sb {
    if ([sb count] == 0) {
        return;
    }
    [sb enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addSubview:obj];
    }];
}

- (CGFloat)yh_height {
    return self.frame.size.height;
}

- (CGFloat)yh_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)yh_top {
    return self.frame.origin.y;
}

- (CGFloat)yh_left {
    return self.frame.origin.x;
}

- (CGFloat)yh_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)yh_width {
    return self.frame.size.width;
}

- (void)yh_setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)yh_setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)yh_setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)yh_setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)yh_setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


- (void)addAlwaysFitSubview:(UIView *)subview {
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

- (void)alert:(NSString *)message type:(YHAlertType)type {
    [self alert:message type:type completion:nil];
}


- (void)alert:(NSString *)message type:(YHAlertType)type completion:(dispatch_block_t)completion {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
    hud.detailsLabelFont = [UIFont systemFontOfSize:12.0f];
    hud.detailsLabelText = message;
    hud.yOffset = -80.0f;
    hud.removeFromSuperViewOnHide = YES;
    
    NSString *alertImageName = @"";
    if (type == YHAlertTypeFail) {
        alertImageName = @"shared_alert_fail";
    }
    else if (type == YHAlertTypeSuccess) {
        alertImageName = @"shared_alert_success";
    }
    else if (type == YHAlertTypeNetwork) {
        alertImageName = @"shared_alert_network";
    } else if (type == YHAlertTypeRectangle) {
        hud.detailsLabelFont = [UIFont systemFontOfSize:14.0f];
        hud.yOffset = -55.0f;
        hud.cornerRadius = 0.0f;
        hud.labelColor = [UIColor whiteColor];
    }
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:alertImageName]];
    hud.mode = MBProgressHUDModeCustomView;
    
    [self addSubview:hud];
    [hud show:YES];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
        if (completion) {
            completion();
        }
    });
}

- (void)alertNetwork {
    [self alert:NSLocalizedString(@"网络不通，请稍后再试。", nil) type:YHAlertTypeNetwork];;
}

- (void)alertDataError {
    [self alert:NSLocalizedString(@"数据错误", nil) type:YHAlertTypeNetwork];
}

- (void)showWait {
    [self showWaitWithStatus:nil];
}

- (void)showWaitWithStatus:(NSString *)status {
    [SVProgressHUD showWithStatus:status];
}

- (void)hideWait {
    [SVProgressHUD dismiss];
}

- (void)hideWithSuccess:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
}

- (void)hideWithFailure:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

- (NSLayoutConstraint *)constraintOfIdentifier:(NSString *)identifier
{
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraint.identifier isEqualToString:identifier]) {
            return constraint;
        }
    }
    return nil;
}

@end
