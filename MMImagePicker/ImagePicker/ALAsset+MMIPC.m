//
//  ALAsset+MMIPC.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "ALAsset+MMIPC.h"

@implementation ALAsset (MMIPC)

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    
    ALAsset *otherAsset = (ALAsset *)other;
    NSDictionary *selfUrls = [self valueForProperty:ALAssetPropertyURLs];
    NSDictionary *otherUrls = [otherAsset valueForProperty:ALAssetPropertyURLs];
    
    return [selfUrls isEqualToDictionary:otherUrls];
}

@end
