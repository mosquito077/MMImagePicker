//
//  MM_ImagePickerViewController.h
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#define YH_PICKER_RESULT_UIIMAGE    0
#define YH_PICKER_RESULT_ASSET      1

#import <UIKit/UIKit.h>
#import "AssetHelper.h"
#import "YH_PhotoInfo.h"

@interface YH_AlbumTableViewCell : UITableViewCell

- (NSString*)getAlbumNameText;

@end

@protocol MMImagePickerControllerDelegate;

@interface MM_ImagePickerViewController : UIViewController

@property (weak, nonatomic) id<MMImagePickerControllerDelegate> delegate;

@property (assign, nonatomic) NSInteger nMaxCount;

@property (assign, nonatomic) NSInteger nInitCount;

@property (assign, nonatomic) NSInteger nColumnCount;

@property (assign, nonatomic) NSInteger nResultType;

- (instancetype)initWithSelectAssets:(NSArray<ALAsset*> *)selectAssets;

- (instancetype)initWithSelectAssets:(NSArray<ALAsset*> *)selectAssets
                   selectedPhotoInfo:(NSArray<YH_PhotoInfo*>*)infoArray;

@end

@protocol MMImagePickerControllerDelegate <NSObject>

@optional

- (void)didSelectPhotosFromMMImagePickerController:(MM_ImagePickerViewController *)picker
                                            result:(NSArray<ALAsset*>*)indexArray
                                            finish:(BOOL)flag;

- (void)didSelectPhotosFromMMImagePickerController:(MM_ImagePickerViewController *)picker
                                            result:(NSArray<ALAsset*>*)indexArray
                                          metaData:(NSArray<YH_PhotoInfo*>*)metaData
                                            finish:(BOOL)flag;

- (void)didCancelMMImagePickerController:(MM_ImagePickerViewController *)picker;

@end
