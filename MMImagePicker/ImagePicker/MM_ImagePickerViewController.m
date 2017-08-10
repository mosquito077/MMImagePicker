//
//  MM_ImagePickerViewController.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/9.
//  Copyright © 2017年 mosquito. All rights reserved.
//


#import "MM_ImagePickerViewController.h"
#import "MMImagePickerCell.h"
#import "MMPreviewImageCell.h"

#define kTagAlbumCover             123121
#define kTagAlbumNameLabel         213211
#define kTagAlbumPhotoCountLabel   3234232

@interface YH_AlbumTableViewCell()

@property (strong, nonatomic) UILabel *albumName;
@property (strong, nonatomic) UILabel *albumPhotoCount;
@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) UIImageView *accessoryImageView;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation YH_AlbumTableViewCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.albumCover = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.albumCover.tag = kTagAlbumCover;
    [self.contentView addSubview:self.albumCover];
    
    self.albumName = [[UILabel alloc] initWithFrame:CGRectZero];
    self.albumName.font = [UIFont systemFontOfSize:14.0f];
    self.albumName.tag = kTagAlbumNameLabel;
    self.albumName.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.albumName];
    
    self.albumPhotoCount = [[UILabel alloc] initWithFrame:CGRectZero];
    self.albumPhotoCount.tag = kTagAlbumPhotoCountLabel;
    self.albumPhotoCount.backgroundColor = [UIColor clearColor];
    self.albumPhotoCount.font = [UIFont systemFontOfSize:12.0f];
    self.albumPhotoCount.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.albumPhotoCount];
    
    self.accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.accessoryImageView.image = [UIImage imageNamed:@"import_link_arrowl"];
    [self.contentView addSubview:self.accessoryImageView];
    
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.albumCover.frame = CGRectMake(10.0f, (CGRectGetHeight(self.contentView.frame) - 70.0f) /2, 70.0f, 70.0f);
    self.albumName.frame = CGRectMake(94.0f, 30.0f, kScreenWidth/2, 15.0f);
    self.albumPhotoCount.frame = CGRectMake(94.0f, CGRectGetMaxY(self.albumName.frame)+5, 85.0f, 10.0f);
    self.accessoryImageView.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 40.0f, (CGRectGetHeight(self.contentView.frame) - 25.0f)/2 - 1.0f, 25.0f, 25.0f);
}

- (void)updateCellContent:(UIImage*)albumCoverImage albumName:(NSString*)albumName albumPhotoCount:(NSInteger)albumPhotoCount {
    
    self.albumCover.image = albumCoverImage;
    self.albumName.text = albumName;
    self.albumPhotoCount.text = [NSString stringWithFormat:@"%ld",(long)albumPhotoCount];
}

- (NSString*)getAlbumNameText {
    return self.albumName.text;
}

@end

#define kImagePickerBottomViewHeight    45.0f
#define kImagePickerCellSpace           6.0f
#define kImagePickerLeftSpace           6.0f

static NSString *kPropertyToObserve = @"contentOffset";
static void *kObservingContentOffsetChangesContext = &kObservingContentOffsetChangesContext;

@interface MM_ImagePickerViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>

// picker view
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *selectAlbumButton;
@property (assign, nonatomic) BOOL isOpenAlbum;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *selectButton;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIImageView *routeImageView;
@property (strong, nonatomic) UILabel *countLabel;
@property (strong, nonatomic) UIButton *chooseButton;
@property (strong, nonatomic) UIToolbar *toolBarView;

// preview view
@property (strong, nonatomic) UICollectionView *previewCollectionView;
@property (assign, nonatomic) BOOL previewMode;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (assign, nonatomic) UIStatusBarStyle previousStatueBarStyle;
@property (assign, nonatomic) UIBarStyle previousNavigationBarStyle;
@property (assign, nonatomic) UIBarStyle previousToolBarStyle;

// select photos
@property (strong, nonatomic) NSMutableDictionary <NSString*, ALAsset*>*selectedAssets;

@property (strong, nonatomic) NSIndexPath *lastAccessed;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@property (assign, nonatomic) BOOL isSelected;
@property (strong, nonatomic) NSIndexPath *lastClicked;      //最后点击的图片的indexpath
@property (assign, nonatomic) NSInteger nowNum;
@property (assign, nonatomic) CGFloat cellWidth;

//albumtableview
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSIndexPath *selectAlbumIndex;    //选中相册的indexpath值
@property (strong, nonatomic) NSMutableArray<ALAsset*> *previewAssetsArray;
@property (strong, nonatomic) NSMutableArray <YH_PhotoInfo*> *photoInfoArray;

@end

@implementation MM_ImagePickerViewController

+ (BOOL)yh_designatedUsingXib {
    return NO;
}

- (NSMutableArray *)photoInfoArray {
    if (!_photoInfoArray) {
        _photoInfoArray = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _photoInfoArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.nMaxCount = YH_NO_LIMIT_SELECT;
        self.nInitCount = 0;
        self.nColumnCount = 3;
        self.nResultType = YH_PICKER_RESULT_UIIMAGE;
        self.previewMode = NO;
        self.nowNum = 0;
        self.selectAlbumIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}

- (instancetype)initWithSelectAssets:(NSArray<ALAsset*> *)selectAssets {
    self = [self init];
    if (self) {
        [selectAssets enumerateObjectsUsingBlock:^(ALAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURL *assetURL = [obj valueForProperty:ALAssetPropertyAssetURL];
            self.selectedAssets[assetURL.absoluteString] = obj;
            
            YH_PhotoInfo *photoInfo = [[YH_PhotoInfo alloc] init];
            photoInfo.location = [obj valueForProperty:ALAssetPropertyLocation];
            photoInfo.asset = obj;
            [self.photoInfoArray addObject:photoInfo];
        }];
    }
    return self;
}

- (instancetype)initWithSelectAssets:(NSArray<ALAsset*> *)selectAssets selectedPhotoInfo:(NSArray<YH_PhotoInfo*>*)infoArray {
    self = [self initWithSelectAssets:selectAssets];
    if (self) {
        self.photoInfoArray = infoArray.mutableCopy;
    }
    
    return self;
}

- (void)dealloc {
    [self removeObserer];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initViews];
    
    [self addObserver];
    
    // new photo is located at the first of array
    ASSETHELPER.bReverse = YES;
    
    WS(weakSelf);
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        
        [ASSETHELPER getGroupList:^(NSArray *groups) {
            if (groups.count == 0) {
                return;
            }
            
            [ASSETHELPER getPhotoListOfGroupByIndex:0 result:^(NSArray *photos) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf updateCountLabel];
                    [weakSelf.collectionView reloadData];
                    
                });
            }];
        }];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return self.navigationController.navigationBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - property get
- (UITableView *)tableView {
    if (! _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -kScreenHeight+64.f, kScreenWidth, kScreenHeight-64.f) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableDictionary*)selectedAssets {
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _selectedAssets;
}

- (NSMutableArray *)previewAssetsArray {
    if (!_previewAssetsArray) {
        _previewAssetsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _previewAssetsArray;
}

- (UILabel *)titleLabel {
    if (! _titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:18.0f];
        _titleLabel.font = font;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        CGSize size = [self calStringSize:@"相机胶卷" font:font];
        _titleLabel.frame = CGRectMake(12, 0, size.width, kNavigationBarHeight);
        _titleLabel.text = @"相机胶卷";
    }
    return _titleLabel;
}

- (UIButton *)selectAlbumButton {
    if (! _selectAlbumButton) {
        _selectAlbumButton = [[UIButton alloc] init];
        UIImage *image = [UIImage imageNamed:@"triangle_ic"];
        _selectAlbumButton.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame)+10, (kNavigationBarHeight-image.size.height)/2, image.size.width, image.size.height);
        _selectAlbumButton.backgroundColor = [UIColor clearColor];
        [_selectAlbumButton setExclusiveTouch:YES];
        [_selectAlbumButton setImage:image forState:UIControlStateNormal];
        [_selectAlbumButton setImage:[UIImage imageNamed:@"triangle_up"] forState:UIControlStateSelected];
    }
    return _selectAlbumButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        _backButton.frame = CGRectMake(0, 0, 44, 44);
        _backButton.backgroundColor = [UIColor clearColor];
        [_backButton setExclusiveTouch:YES];
        [_backButton setTitleColor:[UIColor colorWithRed:26/255 green:26/255 blue:26/255 alpha:1.f] forState:UIControlStateNormal];
        [_backButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_backButton setTitle:@"取消" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        _selectButton.frame = CGRectMake(0, 0, 44, 44);
        _selectButton.backgroundColor = [UIColor clearColor];
        [_selectButton setExclusiveTouch:YES];
        
        UIImage *selectedImage = [UIImage imageNamed:@"route_yes"];
        UIImage *unselectImage = [UIImage imageNamed:@"route_no"];
        
        [_selectButton setImage:unselectImage forState:UIControlStateNormal];
        [_selectButton setImage:selectedImage forState:UIControlStateHighlighted];
        [_selectButton setImage:selectedImage forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        CGRect frame = CGRectZero;
        frame = CGRectMake(3.0f, 0, kScreenWidth-6.0f, CGRectGetHeight(self.view.frame) - kImagePickerBottomViewHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[MMImagePickerCell class] forCellWithReuseIdentifier:@"MMImagePickerCell"];
        if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            _collectionView.prefetchingEnabled = NO;
        }
    }
    return _collectionView;
}

- (UICollectionView *)previewCollectionView {
    if (!_previewCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _previewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(kScreenWidth+15.f, 0, kScreenWidth+15.f*2, kScreenHeight) collectionViewLayout:flowLayout];
        _previewCollectionView.backgroundColor = [UIColor whiteColor];
        _previewCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _previewCollectionView.dataSource = self;
        _previewCollectionView.delegate = self;
        _previewCollectionView.alwaysBounceHorizontal = YES;
        _previewCollectionView.showsHorizontalScrollIndicator = NO;
        _previewCollectionView.pagingEnabled = YES;
        _previewCollectionView.scrollsToTop = NO;
        
        [_previewCollectionView registerClass:[MMPreviewImageCell class] forCellWithReuseIdentifier:@"MMPreviewImageCell"];
    }
    return _previewCollectionView;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.backgroundColor = [UIColor clearColor];
        _previewButton.frame = CGRectMake(0, 0, 60.0f, 44.0f);
        [_previewButton setExclusiveTouch:YES];
        [_previewButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_previewButton setTitleColor:[UIColor colorWithRed:26/255 green:26/255 blue:26/255 alpha:1.0f] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor colorWithRed:176/255 green:176/255 blue:176/255 alpha:0.4f] forState:UIControlStateDisabled];
        [_previewButton setTitle:NSLocalizedString(@"预览", nil) forState:UIControlStateNormal];
        [_previewButton addTarget:self action:@selector(handleTapPreviewButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}

- (UIImageView *)routeImageView {
    if (!_routeImageView) {
        _routeImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"route_num"];
        _routeImageView.image = image;
        _routeImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        _routeImageView.hidden = YES;
        [_routeImageView addSubview:self.countLabel];
    }
    return _routeImageView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 20.0f)];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.font = [UIFont systemFontOfSize:14.0f];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}

- (UIButton *)chooseButton {
    if (!_chooseButton) {
        _chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _chooseButton.backgroundColor = [UIColor clearColor];
        _chooseButton.frame = CGRectMake(0, 0, 60.0f, 44.0f);
        [_chooseButton setExclusiveTouch:YES];
        [_chooseButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [_chooseButton setTitleColor:[UIColor colorWithRed:148/255 green:185/255 blue:129/255 alpha:1.0f] forState:UIControlStateNormal];
        [_chooseButton setTitleColor:[UIColor colorWithRed:176/255 green:176/255 blue:176/255 alpha:0.4f] forState:UIControlStateDisabled];
        [_chooseButton setTitle:@"完成" forState:UIControlStateNormal];
        [_chooseButton addTarget:self action:@selector(handleTapChooseButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chooseButton;
}

- (UIToolbar *)toolBarView {
    if (!_toolBarView) {
        _toolBarView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kScreenHeight - kImagePickerBottomViewHeight, kScreenWidth, kImagePickerBottomViewHeight)];
        _toolBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _toolBarView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        _tapGesture.cancelsTouchesInView = NO;
    }
    return _tapGesture;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.allowsEditing = NO;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

#pragma mark - Setters
- (void)setPreviewMode:(BOOL)previewMode {
    _previewMode = previewMode;
    
    if (previewMode) {
        [self.backButton setTitle:nil forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"back"]
                         forState:UIControlStateNormal];
    } else {
        [self.backButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.backButton setImage:nil
                         forState:UIControlStateNormal];
    }
}

#pragma mark - Private Methods

- (void)initViews {
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.isOpenAlbum = NO;
    self.titleView = [[UIView alloc] init];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAllAlbum)];
    [self.titleView addGestureRecognizer:singleTap];
    
    [self.titleView addSubview:self.titleLabel];
    [self.titleView addSubview:self.selectAlbumButton];
    
    self.titleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.titleLabel.frame)+CGRectGetWidth(self.selectAlbumButton.frame)+10.f, kNavigationBarHeight);
    
    self.navigationItem.titleView = self.titleView;
    
    // left and right navigation item
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftItem.width = -7.0f;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItems = @[leftItem, backItem];
    
    // collectionview
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.previewCollectionView];
    self.previewCollectionView.alpha = 0.f;
    [self.previewCollectionView addGestureRecognizer:self.tapGesture];
    
    // preview button
    UIBarButtonItem *previewItem = [[UIBarButtonItem alloc] initWithCustomView:self.previewButton];
    
    // count label
    UIBarButtonItem *countItem = [[UIBarButtonItem alloc] initWithCustomView:self.routeImageView];
    
    // choose button
    UIBarButtonItem *chooseItem = [[UIBarButtonItem alloc] initWithCustomView:self.chooseButton];
    
    // space item
    UIBarButtonItem *spaceLeftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceLeftItem.width = -15.0f;
    UIBarButtonItem *spaceMiddleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spaceLabelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceLabelItem.width = -23.0f;
    UIBarButtonItem *spaceRightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceRightItem.width = -15.0f;
    
    // toolbar view
    self.toolBarView.items = @[spaceLeftItem, previewItem, spaceMiddleItem, countItem, spaceLabelItem, chooseItem, spaceRightItem];
    [self.view addSubview:self.toolBarView];
    
    [self updateCountLabel];
}

- (void)showAllAlbum {
    if (self.isOpenAlbum) {
        self.isOpenAlbum = NO;
        self.selectAlbumButton.selected = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.transform = CGAffineTransformMakeTranslation(0, -kScreenHeight);
        }];
    } else {
        self.isOpenAlbum = YES;
        self.selectAlbumButton.selected = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.transform = CGAffineTransformMakeTranslation(0, kScreenHeight);
        }];
    }
}

- (void)updateTitleLabel:(NSString *)text showButton:(BOOL)isShow {
    CGSize size = [self calStringSize:text font:[UIFont systemFontOfSize:18.0f]];
    self.titleLabel.text = text;
    self.titleLabel.frame = CGRectMake(12, 0, size.width, kNavigationBarHeight);
    UIImage *image = [UIImage imageNamed:@"triangle_up"];
    if (isShow) {
        self.selectAlbumButton.hidden = NO;
        self.selectAlbumButton.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame)+10, (kNavigationBarHeight-image.size.height)/2, image.size.width, image.size.height);
        self.titleView.width = CGRectGetWidth(self.titleLabel.frame)+CGRectGetWidth(self.selectAlbumButton.frame)+10.f;
        self.titleView.userInteractionEnabled = YES;
    }else {
        self.selectAlbumButton.hidden = YES;
        self.titleView.width = size.width;
        self.titleView.userInteractionEnabled = NO;
    }
    
    self.navigationItem.titleView = self.titleView;
}

- (void)updateCountLabel {
    NSString *countStr = [NSString stringWithFormat:@"%zd", [self.selectedAssets count]];
    [self.countLabel setText:countStr];
    
    // 当选取一个以上图片时，才可以进入预览模式
    if (self.previewButton.hidden == NO) {
        [self.previewButton setEnabled:self.selectedAssets.count > 0];
        [self.chooseButton setEnabled:self.selectedAssets.count > 0];
        [self.routeImageView setHidden:!(self.selectedAssets.count > 0)];
    }
}

- (void)updateCollectionViewLayout {
    if (self.previewMode) {
        if ([self.navigationController isKindOfClass:[UINavigationController class]] && [self.navigationController.viewControllers objectAtIndex:0] == self) {
            [self.backButton setHidden:NO];
        }
        
        self.previousToolBarStyle = self.toolBarView.barStyle;
        self.toolBarView.translucent = YES;
        self.toolBarView.barStyle = self.previousNavigationBarStyle;
        
        UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectButton];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        rightItem.width = -10.0f;
        self.navigationItem.rightBarButtonItems = @[rightItem, selectItem];
        self.selectButton.hidden = NO;
        
        [self.chooseButton setTitleColor:[UIColor colorWithRed:148/255 green:185/255 blue:129/255 alpha:1.0f] forState:UIControlStateNormal];
        
        [self.previewButton setHidden:self.previewMode];
        [self.routeImageView setHidden:!(self.selectedAssets.count > 0)];
        
        [self.previewAssetsArray removeAllObjects];
        [self.photoInfoArray enumerateObjectsUsingBlock:^(YH_PhotoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.previewAssetsArray addObject:obj.asset];
        }];
        
        [self.previewCollectionView reloadData];
        
        [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                           atScrollPosition:UICollectionViewScrollPositionRight
                                                   animated:NO];
        
        self.previewCollectionView.alpha = 1.f;
        
        [NSObject pop_animate:^{
            self.collectionView.pop_duration = 0.3f;
            self.collectionView.pop_easeInEaseOut.frame = CGRectOffset(self.collectionView.frame, -kScreenWidth/3, 0.f);
            self.previewCollectionView.pop_springBounciness = 1.f;
            self.previewCollectionView.pop_springSpeed = 13;
            CGRect frame = self.previewCollectionView.frame;
            self.previewCollectionView.pop_spring.frame = CGRectMake(-30.f,
                                                                 CGRectGetMinY(frame),
                                                                 CGRectGetWidth(frame),
                                                                 CGRectGetHeight(frame));
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        NSString *titleText = nil;
        if (self.selectAlbumIndex.row == 0) {
            titleText = NSLocalizedString(@"相机胶卷", nil);
        } else {
            YH_AlbumTableViewCell *cell = (YH_AlbumTableViewCell *)[self.tableView cellForRowAtIndexPath:self.selectAlbumIndex];
            titleText = [cell getAlbumNameText];
        }
        
        [self updateTitleLabel:titleText showButton:YES];
        self.selectButton.hidden = YES;
        
        self.toolBarView.translucent = NO;
        self.toolBarView.barStyle = self.previousToolBarStyle;
        
        [self.chooseButton setTitleColor:[UIColor colorWithRed:148/255 green:185/255 blue:129/255 alpha:1.0f] forState:UIControlStateNormal];
        [self.previewButton setHidden:self.previewMode];
        [self.routeImageView setHidden:!(self.selectedAssets.count > 0)];
        [self.collectionView reloadData];
        
        [NSObject pop_animate:^{
            self.collectionView.pop_springBounciness = 5;
            self.collectionView.pop_springSpeed = 18;
            self.collectionView.pop_spring.frame = CGRectOffset(self.collectionView.frame, kScreenWidth/3, 0.f);
            
            self.previewCollectionView.pop_springBounciness = 2.f;
            self.previewCollectionView.pop_springSpeed = 18;
            CGRect frame = self.previewCollectionView.frame;
            self.previewCollectionView.pop_spring.frame = CGRectMake(kScreenWidth+30.f,
                                                                 CGRectGetMinY(frame),
                                                                 CGRectGetWidth(frame),
                                                                 CGRectGetHeight(frame));
            
        } completion:^(BOOL finished) {}];
    }
}

- (void)hideNavigationAndToolBar {
    //Check the current state of the navigation bar...
    BOOL navBarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:!navBarHidden animated:YES];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    CGFloat offsetY = navBarHidden?-CGRectGetHeight(self.toolBarView.frame):CGRectGetHeight(self.toolBarView.frame);
    CGRect tooBarFrame = CGRectOffset(self.toolBarView.frame, 0, offsetY);
    [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
        self.toolBarView.frame = tooBarFrame;
    } completion:^(BOOL finished) {}];
}

#pragma mark - Action Methods

- (void)back:(BOOL)animated {
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        [self dismissViewControllerAnimated:animated completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

- (void)backAction:(id)sender {
    if (self.previewMode) {
        self.previewMode = NO;
        [self.previewButton setEnabled:self.selectedAssets.count > 0];
        [self.routeImageView setHidden:!(self.selectedAssets.count > 0)];
        [self updateCollectionViewLayout];
        [self updateCountLabel];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelYHImagePickerController:)]) {
            [self.delegate didCancelYHImagePickerController:self];
        }
        
        [self back:YES];
    }
}

- (void)selectAction:(id)sender {
    if (self.previewMode) {
        NSArray *indexArr = [self.previewCollectionView indexPathsForVisibleItems];
        if ([indexArr count]  == 1) {
            ALAsset *asset = [self.previewAssetsArray objectAtIndex:self.nowNum-1];
            NSString *key = [[asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
            
            if (!self.selectedAssets[key]) {
                self.selectedAssets[key] = asset;
                [self.selectButton setSelected:YES];
                
                YH_PhotoInfo *photoInfo = [[YH_PhotoInfo alloc] init];
                photoInfo.location = [asset valueForProperty:ALAssetPropertyLocation];
                photoInfo.asset = asset;
                [self.photoInfoArray addObject:photoInfo];
                
            } else {
                [self.selectedAssets removeObjectForKey:key];
                [self.selectButton setSelected:NO];
                
                for (NSInteger i=0; i<self.photoInfoArray.count; i++) {
                    YH_PhotoInfo *info = [self.photoInfoArray objectAtIndex:i];
                    if ([[[info.asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:key]) {
                        [self.photoInfoArray removeObjectAtIndex:i];
                        break;
                    }
                }
            }
            
            [self.chooseButton setEnabled:(self.selectedAssets.count>0)];
            [self.routeImageView setHidden:(self.selectedAssets.count==0)];
            
            [self updateCountLabel];
        }
    }
}

- (void)handleTapPreviewButton:(id)sender {
    // 打开图像预览，可编辑选中状态
    self.previewMode = YES;
    [self updateCollectionViewLayout];
    [self updateCountLabel];
}

- (void)handleTapChooseButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPhotosFromYHImagePickerController:result:finish:)]) {
        [self.delegate didSelectPhotosFromYHImagePickerController:self
                                                           result:[self.photoInfoArray valueForKeyPath:@"asset"]
                                                           finish:YES];
    } else if ([self.delegate respondsToSelector:@selector(didSelectPhotosFromYHImagePickerController:result:metaData:finish:)]) {
        [self.delegate didSelectPhotosFromYHImagePickerController:self
                                                           result:[self.photoInfoArray valueForKeyPath:@"asset"]
                                                         metaData:self.photoInfoArray
                                                           finish:YES];
    }
    
    // VC弹出规则可以由上一层VC控制
    [self back:YES];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gesture {
    if (self.previewMode) {
        [self hideNavigationAndToolBar];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.previewCollectionView]) {
        return [self.previewAssetsArray count];
    } else {
        return [ASSETHELPER getPhotoCountOfCurrentGroup] + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.previewCollectionView]) {
        MMPreviewImageCell *previewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMPreviewImageCell" forIndexPath:indexPath];
        previewCell.imageView.image = nil;
        
        __weak typeof(previewCell) weakCell = previewCell;
        ALAsset *asset = [self.previewAssetsArray objectAtIndex:indexPath.row];
        [ASSETHELPER getImageFromAsset:asset
                                  type:ASSET_PHOTO_SCREEN_SIZE
                            completion:^(UIImage *image, ALAsset *theAsset) {
                                if (theAsset == asset) {
                                    weakCell.imageView.image = image;
                                }
                            }];
        
        return previewCell;
    } else {
        MMImagePickerCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MMImagePickerCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            UIImage *image = [UIImage imageNamed:@"camera"];
            imageCell.imageView.image = image;
            imageCell.selectedView.hidden = YES;
        } else {
            ALAsset *asset = [ASSETHELPER getAssetAtIndex:indexPath.item-1];
            imageCell.imageView.image = [ASSETHELPER getImageFromAsset:asset type:ASSET_PHOTO_THUMBNAIL];
            
            WS(weakSelf);
            __weak typeof(imageCell) weakCell = imageCell;
            [ASSETHELPER getImageFromAsset:asset type:ASSET_PHOTO_ASPECT_THUMBNAIL completion:^(UIImage *image, ALAsset *theAsset) {
                NSIndexPath *realIndexPath = [weakSelf.collectionView indexPathForCell:weakCell];
                
                if (realIndexPath
                    && realIndexPath.item>0
                    && [ASSETHELPER getAssetAtIndex:realIndexPath.item-1] == theAsset) {
                    
                    weakCell.imageView.image = image;
                }
            }];
            
            dispatch_queue_t workerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(workerQueue, ^{
                NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
                BOOL contained = NO;
                if (self.selectedAssets[assetURL.absoluteString]) {
                    contained = YES;
                } else {
                    contained = NO;
                }
                
                dispatch_queue_t workerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(workerQueue, ^{
                    NSIndexPath *realIndexPath = [weakSelf.collectionView indexPathForCell:weakCell];
                    
                    // 异步后验证是否有效
                    if (realIndexPath
                        && realIndexPath.item>0
                        && [ASSETHELPER getAssetAtIndex:realIndexPath.item-1] == asset) {
                        
                        [weakCell showSelected:contained animated:NO];
                    }
                });

            });
        }
        imageCell.tag = indexPath.row+1200;
        
        return imageCell;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.previewCollectionView) {
        return;
    }
    
    if (indexPath.item == 0) {
        if (self.selectedAssets.count < self.nMaxCount) {
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        } else {
            NSLog(@"最多可选择%ld张图片", (long)self.nMaxCount);
//            [YH_Tool alertMessage:[NSString stringWithFormat:NSLocalizedString(@"最多可选择%ld张图片", nil), (long)self.nMaxCount]];
        }
    } else {
        MMImagePickerCell *cell = (MMImagePickerCell*)[collectionView cellForItemAtIndexPath:indexPath];
        BOOL selected = !cell.isMarked;
        [self didSelectPhotoAtIndexPath:indexPath isSelect:selected];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.previewCollectionView]) {
        return CGSizeMake(kScreenWidth, self.previewCollectionView.frame.size.height);
    } else {
        CGFloat width = floorf((kScreenWidth - kImagePickerCellSpace*(self.nColumnCount-1)-kImagePickerLeftSpace*2)/self.nColumnCount);
        self.cellWidth = width;
        return CGSizeMake(width, width);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([collectionView isEqual:self.collectionView]) {
        return UIEdgeInsetsMake(6.0f, 3.0f, 64.0f, 3.0f);
    } else {
        return UIEdgeInsetsMake(0.f, 30.f, 0.f, 30.f);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([collectionView isEqual:self.previewCollectionView]) {
        return 30.f*2;
    } else {
        return kImagePickerCellSpace;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([collectionView isEqual:self.previewCollectionView]) {
        return 0;
    } else {
        return kImagePickerCellSpace;
    }
}

#pragma mark - Private
- (void)didSelectPhotoAtIndexPath:(NSIndexPath *)indexPath isSelect:(BOOL)isSelect {
    MMImagePickerCell *cell = (MMImagePickerCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSInteger index = indexPath.item - 1;
    ALAsset *asset = [ASSETHELPER getAssetAtIndex:index];
    NSURL *assetUrl = [asset valueForProperty:ALAssetPropertyAssetURL];
    
    if (isSelect) {
        
        if (self.selectedAssets.count < self.nMaxCount) {
            [cell showSelected:YES animated:YES];
            self.isSelected = YES;
            if (!self.selectedAssets[assetUrl.absoluteString]) {
                YH_PhotoInfo *photoInfo = [[YH_PhotoInfo alloc] init];
                photoInfo.location = [asset valueForProperty:ALAssetPropertyLocation];
                photoInfo.asset = asset;
                [self.photoInfoArray addObject:photoInfo];
            }
            
            self.selectedAssets[assetUrl.absoluteString] = asset;
            self.lastAccessed = indexPath;
        } else {
            NSLog(@"最多可选择%ld张图片", (long)self.nMaxCount);
            return;
        }
    } else {
        [cell showSelected:NO animated:YES];
        self.isSelected = NO;
        
        for (NSInteger i=0; i<self.photoInfoArray.count; i++) {
            YH_PhotoInfo *info = [self.photoInfoArray objectAtIndex:i];
            if ([[[info.asset valueForProperty:ALAssetPropertyAssetURL] absoluteString] isEqualToString:assetUrl.absoluteString]) {
                [self.photoInfoArray removeObjectAtIndex:i];
                break;
            }
        }
        [self.selectedAssets removeObjectForKey:assetUrl.absoluteString];
    }
    self.lastClicked = indexPath;
    [self updateCountLabel];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"正在保存图片...");
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //元数据
    NSDictionary *dict = [info objectForKey:UIImagePickerControllerMediaMetadata];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:dict];
    //    //EXIF数据
    //    NSMutableDictionary *EXIFDictionary =[[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    //GPS数据
    NSMutableDictionary *gpsDictionary = [[metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary] mutableCopy];
    if (!gpsDictionary) {
        gpsDictionary = [[NSMutableDictionary alloc] init];
        CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        gpsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithFloat:fabs(location.coordinate.latitude)], kCGImagePropertyGPSLatitude,
                         ((location.coordinate.latitude >= 0) ? @"N" : @"S"), kCGImagePropertyGPSLatitudeRef,
                         [NSNumber numberWithFloat:fabs(location.coordinate.longitude)], kCGImagePropertyGPSLongitude,
                         ((location.coordinate.longitude >= 0) ? @"E" : @"W"), kCGImagePropertyGPSLongitudeRef,
                         nil];
        [metadata setValue:gpsDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    }
    [self writeCGImage:image metadata:metadata];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)writeCGImage:(UIImage*)image metadata:(NSDictionary *)metadata{
    WS(weakSelf);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
//        [YH_Tool hideAlert];
        if (error) {
            NSLog(@"图片保存失败!");
        } else {
            [weakSelf.imagePickerController dismissViewControllerAnimated:YES completion:^{}];
            
            CLLocationCoordinate2D coord = kCLLocationCoordinate2DInvalid;
            if ([CLLocationManager locationServicesEnabled] && CLLocationCoordinate2DIsValid(coord)) {
                
                YH_PhotoInfo *pInfo = [[YH_PhotoInfo alloc] init];
                pInfo.location = [[CLLocation alloc] initWithLatitude:coord.latitude
                                                            longitude:coord.longitude];
                [weakSelf.photoInfoArray addObject:pInfo];
            }
            
            [ASSETHELPER.assetLibrary assetForURL:newURL
                                       resultBlock:^(ALAsset *asset) {
                                           YH_PhotoInfo *pInfo = [weakSelf.photoInfoArray lastObject];
                                           pInfo.asset = asset;
                                           
                                           if ([weakSelf.delegate respondsToSelector:@selector(didSelectPhotosFromYHImagePickerController:result:finish:)]) {
                                               [self.delegate didSelectPhotosFromYHImagePickerController:weakSelf
                                                                                                  result:[weakSelf.photoInfoArray valueForKeyPath:@"asset"]
                                                                                                  finish:YES];
                                           } else if ([weakSelf.delegate respondsToSelector:@selector(didSelectPhotosFromYHImagePickerController:result:metaData:finish:)]) {
                                               [weakSelf.delegate didSelectPhotosFromYHImagePickerController:weakSelf
                                                                                                      result:[weakSelf.photoInfoArray valueForKeyPath:@"asset"]
                                                                                                    metaData:weakSelf.photoInfoArray
                                                                                                      finish:YES];
                                           }
                                           
                                           [self back:YES];
                                       } failureBlock:^(NSError *error) {
                                           [self back:YES];
                                       }];
        }
    };
    
    //保存相片到相册 注意:必须使用[image CGImage]不能使用强制转换: (__bridge CGImageRef)image,否则保存照片将会报错
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                                 metadata:metadata
                          completionBlock:imageWriteCompletionBlock];
}

#pragma mark - KVO
- (void)addObserver {
    [self.previewCollectionView addObserver:self
                                 forKeyPath:kPropertyToObserve
                                    options:NSKeyValueObservingOptionNew
                                    context:kObservingContentOffsetChangesContext];
}

- (void)removeObserer {
    [self.previewCollectionView removeObserver:self forKeyPath:kPropertyToObserve];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == &kObservingContentOffsetChangesContext) {
        if (self.previewMode) {
            CGFloat pageWidth = kScreenWidth+2*30.f;
            CGPoint newPoint = [change[NSKeyValueChangeNewKey] CGPointValue];
            int index = newPoint.x / pageWidth;
            self.nowNum = index+1;
            if (newPoint.x - index * pageWidth == 0) {
                NSString *indexString = [NSString stringWithFormat:@"  %d/%zd  ", index+1, self.previewAssetsArray.count];
                [self updateTitleLabel:indexString showButton:NO];
                
                NSString *key = nil;
                if (self.previewAssetsArray.count == 1) {
                    NSURL *assetURL = [[self.previewAssetsArray firstObject] valueForProperty:ALAssetPropertyAssetURL];
                    key = assetURL.absoluteString;
                } else {
                    if (index < self.previewAssetsArray.count) {
                        NSURL *assetURL = [[self.previewAssetsArray objectAtIndex:index] valueForProperty:ALAssetPropertyAssetURL];
                        key = assetURL.absoluteString;
                    } else {
                        NSURL *assetURL = [[self.previewAssetsArray firstObject] valueForProperty:ALAssetPropertyAssetURL];
                        key = assetURL.absoluteString;
                    }
                }
                
                if (self.selectedAssets[key]) {
                    [self.selectButton setSelected:YES];
                } else {
                    [self.selectButton setSelected:NO];
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ASSETHELPER getGroupCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    NSInteger row = indexPath.row;
    
    YH_AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[YH_AlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UIImage* image = nil;
    NSString* albumName = nil;
    NSInteger albumPhotoCount = 0;
    
    ALAssetsGroup *group = [ASSETHELPER.assetGroups objectAtIndex:row];
    image = [group getFirstPhotoImage];
    
    albumPhotoCount = [group numberOfAssets];
    albumName = [group valueForProperty:ALAssetsGroupPropertyName];
    
    [NSString stringWithFormat:@"%ld", (long)[group numberOfAssets]];
    
    [cell updateCellContent:image albumName:albumName albumPhotoCount:albumPhotoCount];
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.isOpenAlbum = NO;
    self.selectAlbumButton.selected = NO;
    self.selectAlbumIndex = indexPath;
    
    YH_AlbumTableViewCell *cell = (YH_AlbumTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self updateTitleLabel:[cell getAlbumNameText] showButton:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.transform = CGAffineTransformMakeTranslation(0, -kScreenHeight);
    }];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0
                                                                     inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:NO];
    
    WS(weakSelf);
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        [ASSETHELPER getGroupList:^(NSArray *groups) {
            if (groups.count == 0) {
                return;
            }
            [ASSETHELPER getPhotoListOfGroupByIndex:indexPath.row result:^(NSArray *photos) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.collectionView reloadData];
                });
            }];
        }];
    });
}

- (CGSize)calStringSize:(NSString *)string font:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (string != nil) {
        CGSize boundSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        NSDictionary *attributes = @{NSFontAttributeName : font};
        size = [string boundingRectWithSize:boundSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    if (size.width == 0 || size.height == 0) {
        size = CGSizeZero;
    }
    return size;
}

@end
