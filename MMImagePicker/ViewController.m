//
//  ViewController.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "ViewController.h"
#import "YH_PhotoInfo.h"
#import "MM_PictureCell.h"
#import "MM_ImagePickerViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, MMImagePickerControllerDelegate>

@property (strong, nonatomic) UITableView *mainTableView;
@property (strong, nonatomic) NSMutableArray *picsArray;        //选中的图片数组
@property (strong, nonatomic) NSMutableArray *originPicsArray;  //未加滤镜的数组
@property (strong, nonatomic) NSMutableDictionary *filterDicM;
@property (strong, nonatomic) NSMutableArray *indexArray;
@property (strong, nonatomic) NSMutableArray <YH_PhotoInfo*> *photoInfoArray;

@end

@implementation ViewController

- (NSMutableArray *)photoInfoArray {
    if (!_photoInfoArray) {
        _photoInfoArray = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _photoInfoArray;
}

- (NSMutableArray *)picsArray {
    if (! _picsArray) {
        _picsArray = [NSMutableArray array];
    }
    return _picsArray;
}

- (NSMutableArray *)originPicsArray {
    if (! _originPicsArray) {
        _originPicsArray = [NSMutableArray array];
    }
    return _originPicsArray;
}

- (NSMutableArray *)indexArray {
    if (! _indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = NSLocalizedString(@"图片选择器", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTableView];
}

- (void)createTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, kScreenWidth, kScreenHeight)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:tableView];
    self.mainTableView = tableView;
}

#pragma mark - Button action
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MM_PictureCell heightForPictureCell:self.picsArray];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MM_PictureCell *cell = (MM_PictureCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[MM_PictureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.tag = 10000;
    }
    [cell updateImageView:self.picsArray];
    
    WS(weakSelf);
    cell.tapAddPictureBlock = ^(void){
        MM_ImagePickerViewController *pickerCtrl = [[MM_ImagePickerViewController alloc] initWithSelectAssets:weakSelf.indexArray selectedPhotoInfo:weakSelf.photoInfoArray];
        
        pickerCtrl.delegate = weakSelf;
        pickerCtrl.nMaxCount = 9;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pickerCtrl];
        [weakSelf.navigationController presentViewController:nav animated:YES completion:nil];
    };
    
    cell.tapDeletePictureBlock = ^(NSInteger num){
        if (num < [weakSelf.indexArray count]) {
            [weakSelf.indexArray removeObjectAtIndex:num];
        }
        if (num < [weakSelf.picsArray count]) {
            [weakSelf.picsArray removeObjectAtIndex:num];
        }
        if (num < [weakSelf.photoInfoArray count]) {
            [weakSelf.photoInfoArray removeObjectAtIndex:num];
        }
        [weakSelf.mainTableView reloadData];
    };
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MMImagePickerControllerDelegate
- (void)didSelectPhotosFromMMImagePickerController:(MM_ImagePickerViewController *)picker
                                            result:(NSArray *)indexArray
                                          metaData:(NSArray<YH_PhotoInfo*> *)metaData
                                            finish:(BOOL)flag {
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:metaData.count];
    [metaData enumerateObjectsUsingBlock:^(YH_PhotoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:[ASSETHELPER getImageFromAsset:obj.asset type:ASSET_PHOTO_SCREEN_SIZE]];
    }];
    
    [self.indexArray removeAllObjects];
    [self.picsArray removeAllObjects];
    [self.originPicsArray removeAllObjects];
    [self.photoInfoArray removeAllObjects];
    
    [self.indexArray addObjectsFromArray:indexArray];
    [self.photoInfoArray addObjectsFromArray:metaData];
    
    [self.picsArray addObjectsFromArray:array];
    [self.originPicsArray addObjectsFromArray:array];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainTableView reloadData];
    });
}


@end
