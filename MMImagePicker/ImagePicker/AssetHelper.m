//
//  AssetHelper.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//
#import "AssetHelper.h"

@implementation AssetHelper

+ (AssetHelper *)sharedAssetHelper {
    static AssetHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AssetHelper alloc]init];
        [sharedInstance initAsset];
    });
    return sharedInstance;
}

- (BOOL)initAsset {
    if (self.assetLibrary == nil) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        switch (status) {
            case ALAuthorizationStatusNotDetermined:
            case ALAuthorizationStatusAuthorized: {
                self.assetLibrary = [[ALAssetsLibrary alloc] init];
                return YES;
            }
                
            default: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"请打开设置，开启相册访问权限。"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                return NO;
            }
        }
    }
    return YES;
}

- (void)setCameraRollAtFirst {
    for (ALAssetsGroup *group in self.assetGroups) {
        if ([[group valueForProperty:@"ALAssetsGroupPropertyType"] intValue] == ALAssetsGroupSavedPhotos) {
            //send to head
            [self.assetGroups removeObject:group];
            [self.assetGroups insertObject:group atIndex:0];
            
            return;
        }
    }
}

- (void)getGroupList:(void (^)(NSArray *))result {
    if (![self initAsset]) {
        result(nil);
        return;
    }
    
    WS(weakSelf);
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            if (weakSelf.bReverse)
                weakSelf.assetGroups = [[NSMutableArray alloc]initWithArray:[[weakSelf.assetGroups reverseObjectEnumerator] allObjects]];
                
                [weakSelf setCameraRollAtFirst];
                
                //end of enumeration
                result(weakSelf.assetGroups);
                return;
            }
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [weakSelf.assetGroups addObject:group];
    };
    
    void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
        NSLog(@"Error : %@", [error description]);
    };
    
    self.assetGroups = [[NSMutableArray alloc] init];
    [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock:assetGroupEnumberatorFailure];
    
}

- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result {
    if (![self initAsset]) {
        result(nil);
        return;
    }
    
    self.assetPhotos = [[NSMutableArray alloc] init];
    [alGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    WS(weakSelf);
    [alGroup enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
        
        if (alPhoto == nil) {
            if (weakSelf.bReverse)
                weakSelf.assetPhotos = [[NSMutableArray alloc] initWithArray:[[weakSelf.assetPhotos reverseObjectEnumerator] allObjects]];
                result(weakSelf.assetPhotos);
                return;
        }
        [weakSelf.assetPhotos addObject:alPhoto];
    }];
}

- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result {
    WS(weakSelf);
    [self getPhotoListOfGroup:self.assetGroups[nGroupIndex] result:^(NSArray *aResult) {
        result(weakSelf.assetPhotos);
    }];
}

- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *))error {
    if (![self initAsset]) {
        result(nil);
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        WS(weakSelf);
        void (^asserGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
                    if(alPhoto == nil) {
                        if (weakSelf.bReverse)
                            weakSelf.assetPhotos = [[NSMutableArray alloc] initWithArray:[[weakSelf.assetPhotos reverseObjectEnumerator] allObjects]];
                        result(weakSelf.assetPhotos);
                        return;
                    }
                    [weakSelf.assetPhotos addObject:alPhoto];
                }];
            }
        };
        
        void (^assetGroupEnumeratorFailure)(NSError *) = ^(NSError *err) {
            NSLog(@"Error : %@", [err description]);
            error(err);
        };
        
        self.assetPhotos = [[NSMutableArray alloc] init];
        [self.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                          usingBlock:asserGroupEnumerator
                                        failureBlock:assetGroupEnumeratorFailure];
    });
}

- (NSInteger)getGroupCount {
    return self.assetGroups.count;
}

- (NSInteger)getPhotoCountOfCurrentGroup {
    return self.assetPhotos.count;
}

- (NSDictionary *)getGroupInfo:(NSInteger)nIndex {
    return @{@"name" : [self.assetGroups[nIndex] valueForProperty:ALAssetsGroupPropertyName],
             @"count" : @([self.assetGroups[nIndex] numberOfAssets])};
}

- (void)clearData {
    self.assetPhotos = nil;
    self.assetGroups = nil;
}

#pragma mark - Utils

- (UIImage *)getCroppedImage:(NSURL *)urlImage {
    
    __block UIImage *iImage = nil;
    __block BOOL bBusy = YES;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        NSString *strXMP = rep.metadata[@"AdjustmentXMP"];
        if (strXMP == nil || [strXMP isKindOfClass:[NSNull class]]) {
            
            CGImageRef iref = [rep fullResolutionImage];
            if (iref) {
                iImage = [UIImage imageWithCGImage:iref
                                             scale:1.0
                                       orientation:(UIImageOrientation)rep.orientation];
            } else {
                iImage = nil;
            }
            
        } else {
            
            // to get edited photo by photo app
            NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
            CIImage *image = [CIImage imageWithCGImage:rep.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP
                                                         inputImageExtent:image.extent
                                                                    error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            
            iImage = [UIImage imageWithCIImage:image
                                         scale:1.0
                                   orientation:(UIImageOrientation)rep.orientation];
        }
        
        bBusy = NO;
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
        NSLog(@"booya, cant get image - %@",[myerror localizedDescription]);
    };
    
    [self.assetLibrary assetForURL:urlImage
                        resultBlock:resultblock
                       failureBlock:failureblock];
    
    while (bBusy)
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    return iImage;
}

- (void)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType completion:(void (^) (UIImage *,ALAsset *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self getImageFromAsset:asset type:nType];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image, asset);
            }
        });
    });
}

- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType {
    
    CGImageRef iRef = nil;
    
    if (nType == ASSET_PHOTO_THUMBNAIL) {
        iRef = [asset thumbnail];
    } else if (nType == ASSET_PHOTO_ASPECT_THUMBNAIL) {
        iRef = [asset aspectRatioThumbnail];
    } else if (nType == ASSET_PHOTO_SCREEN_SIZE) {
        iRef = [asset.defaultRepresentation fullScreenImage];
    } else if (nType == ASSET_PHOTO_FULL_RESOLUTION) {
        
        NSString *strXMP = asset.defaultRepresentation.metadata[@"AdjustmentXMP"];
        if (strXMP == nil || [strXMP isKindOfClass:[NSNull class]]) {
            iRef = [asset.defaultRepresentation fullResolutionImage];
            return [UIImage imageWithCGImage:iRef scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        } else {
            NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
            CIImage *image = [CIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP
                                                         inputImageExtent:image.extent
                                                                    error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            
            UIImage *iImage = [UIImage imageWithCIImage:image scale:1.0 orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            return iImage;
        }
    }
    
    return [UIImage imageWithCGImage:iRef];
}

- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType {
    return [self getImageFromAsset:(ALAsset *)self.assetPhotos[nIndex] type:nType];
}

- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex {
    if (nIndex >= self.assetPhotos.count) {
        return nil;
    }
    return self.assetPhotos[nIndex];
}

- (ALAssetsGroup *)getGroupAtIndex:(NSInteger)nIndex {
    return self.assetGroups[nIndex];
}

- (NSUInteger)indexOfAsset:(ALAsset *)asset {
    return [self.assetPhotos indexOfObject:asset];
}

#pragma mark - 等比缩放图片

- (UIImage *)getScaleOfImage:(UIImage *)image size:(CGSize)asize {
    
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    } else {
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        } else {
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));     //clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

#pragma mark - 获取图片部分位置
- (UIImage *)getPartOfImage:(UIImage *)img rect:(CGRect)partRect {
    CGImageRef imageRef = img.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, partRect);
    UIImage *rectImg = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    return rectImg;
}

#pragma mark - 视频第一帧图片
- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(2.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumbImg = [[UIImage alloc] initWithCGImage:image];
    return thumbImg;
}

@end
