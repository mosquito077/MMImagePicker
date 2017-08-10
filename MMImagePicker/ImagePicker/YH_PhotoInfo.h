//
//  YH_PhotoInfo.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/10.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

@interface YH_PhotoInfo : NSObject

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) ALAsset *asset;

@end
