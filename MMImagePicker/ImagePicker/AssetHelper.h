//
//  AssetHelper.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#define ASSETHELPER       [AssetHelper sharedAssetHelper]

#define ASSET_PHOTO_THUMBNAIL             0
#define ASSET_PHOTO_ASPECT_THUMBNAIL      1
#define ASSET_PHOTO_SCREEN_SIZE           2
#define ASSET_PHOTO_FULL_RESOLUTION       3

@interface AssetHelper : NSObject

- (BOOL)initAsset;

@property (strong, nonatomic) ALAssetsLibrary *assetLibrary;
@property (strong, nonatomic) NSMutableArray *assetPhotos;
@property (strong, nonatomic) NSMutableArray *assetGroups;

@property (assign, readwrite) BOOL bReverse;

+ (AssetHelper *)sharedAssetHelper;

//get album list from asset
- (void)getGroupList:(void (^)(NSArray *))result;

//get photos from special album with ALAssetGroup object
- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result;

//get photos from special album with index of album array
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(NSArray *))result;

//get photos from camera roll
- (void)getSavedPhotoList:(void (^)(NSArray *))result error:(void (^)(NSError *))error;

- (NSInteger)getGroupCount;
- (NSInteger)getPhotoCountOfCurrentGroup;
- (NSDictionary *)getGroupInfo:(NSInteger)nIndex;

- (void)clearData;

//utils
- (UIImage *)getCroppedImage:(NSURL *)urlImage;

- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType;

- (void)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType completion:(void (^) (UIImage *, ALAsset *))completion;

- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType;

- (ALAsset *)getAssetAtIndex:(NSInteger)nIndex;

- (ALAssetsGroup *)getGroupAtIndex:(NSInteger)nIndex;

- (NSUInteger)indexOfAsset:(ALAsset *)asset;

//等比缩放图片
- (UIImage *)getScaleOfImage:(UIImage *)image size:(CGSize)asize;

//获取图片部分位置
- (UIImage *)getPartOfImage:(UIImage *)image rect:(CGRect)partRect;

//获取视频的第一帧图片
- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL;

@end
