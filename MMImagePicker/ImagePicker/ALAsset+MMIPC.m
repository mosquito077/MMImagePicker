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
