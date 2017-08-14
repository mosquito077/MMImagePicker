//
//  MMTool.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "MMTool.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define kSignAlertDelayTime     2.0f
#define kAlertDelayTime         1.0f

@implementation MMTool

+ (void)alert:(NSString *)message type:(MMAlertType)type autoHide:(BOOL)isAutoHide afterDelay:(NSTimeInterval)delay inView:(UIView *)view {
    
    if (view == nil) {
        view = [[UIApplication sharedApplication] keyWindow];
    }
    
    if (type == MMAlertTypeWait) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:message];
        return;
    }
    
    NSString *msg = @"";
    if (IsNilOrNull(message) || [message isEqualToString:@""]) {
        return;
    }else{
        msg = message;
    }
    
    [self hideAlertInView:view];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.labelFont = [UIFont systemFontOfSize:12.0f];
    hud.detailsLabelText = msg;
    hud.yOffset = -60.0f;
    hud.removeFromSuperViewOnHide = YES;
    
    NSString *alertImageName = @"";
    MBProgressHUDMode mode = MBProgressHUDModeCustomView;
    if (type == MMAlertTypeFail) {
        alertImageName = @"shared_alert_fail";
    }
    else if (type == MMAlertTypeSuccess) {
        alertImageName = @"shared_alert_success";
    }
    else if (type == MMAlertTypeNetWork) {
        alertImageName = @"shared_alert_network";
    }
    else if (type == MMAlertTypeMessage) {
        alertImageName = @"";
    }
    else if (type == MMAlertTypeWait) {
        mode = MBProgressHUDModeIndeterminate;
    }
    else if (type == MMAlertTypeRectangle) {
        hud.detailsLabelFont = [UIFont systemFontOfSize:14.0f];
        hud.yOffset = -55.0f;
        hud.cornerRadius = 0.0f;
        hud.labelColor = [UIColor whiteColor];
    }
    if (mode == MBProgressHUDModeCustomView) {
        if (alertImageName.length) {
            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:alertImageName]];
        }
    }
    hud.mode = mode;
    
    [view addSubview:hud];
    [hud show:YES];
    if (isAutoHide) {
        [hud hide:YES afterDelay:delay];
    }
}

+ (void)hideAlertInView:(UIView *)view {
    [MBProgressHUD hideAllHUDsForView:view animated:NO];
    [SVProgressHUD dismiss];
//    [[YH_LoadingHUD sharedHud] dismissInView:view];
}

+ (void)alert:(NSString *)message type:(MMAlertType)type autoHide:(BOOL)isAutoHide inView:(UIView *)view {
    [self alert:message type:type autoHide:isAutoHide afterDelay:kAlertDelayTime inView:view];
}

+ (void)alert:(NSString *)message type:(MMAlertType)type autoHide:(BOOL)isAutoHide afterDelay:(NSTimeInterval)delay {
    if (IsStrEmpty(message)) {
        message = nil;
    }
    [self alert:message type:type autoHide:isAutoHide afterDelay:delay inView:[[UIApplication sharedApplication] keyWindow]];
}

+ (void)alert:(NSString *)message type:(MMAlertType)type autoHide:(BOOL)isAutoHide {
    [self alert:message type:type autoHide:isAutoHide afterDelay:kAlertDelayTime];
}

+ (void)alert:(NSString *)message type:(MMAlertType)type afterDelay:(NSTimeInterval)delay {
    [self alert:message type:type autoHide:YES afterDelay:delay];
}

+ (void)alert:(NSString *)message type:(MMAlertType)type {
    [self alert:message type:type afterDelay:kAlertDelayTime];
}

+ (void)alertMessage:(NSString *)message afterDelay:(NSTimeInterval)delay {
    [self alert:message type:MMAlertTypeMessage afterDelay:delay];
}

+ (void)alertMessage:(NSString *)message {
    [self alertMessage:message afterDelay:kAlertDelayTime];
}

+ (void)alertSuccess:(NSString *)message {
    [self alert:message type:MMAlertTypeSuccess];
}

+ (void)alertFail:(NSString *)message {
    if (IsStrEmpty(message)) {
        return;
    }
    [self alert:message type:MMAlertTypeFail];
}

+ (void)alertNetwork:(NSString *)message {
    [self alert:message type:MMAlertTypeNetWork];
}

+ (void)alertNetworkLess {
    [self alertNetwork:NSLocalizedString(@"您的网络不给力，请稍后再试", nil)];
}

+ (void)alertWait {
    [self alertWait:NSLocalizedString(@"加载中...", nil)];
}

+ (void)alertWait:(NSString *)message {
    [self alert:message type:MMAlertTypeWait autoHide:NO];
}

+ (void)hideAlert {
    [MBProgressHUD hideAllHUDsForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
    [SVProgressHUD dismiss];
}

@end
