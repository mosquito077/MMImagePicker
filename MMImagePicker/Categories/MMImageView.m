//
//  MMImageView.m
//  MMImagePicker
//
//  Created by mosquito on 2017/8/11.
//  Copyright © 2017年 mosquito. All rights reserved.
//

#import "MMImageView.h"

@interface MMImageView ()
@property (strong, nonatomic) UIImageView *imageViewAssistant;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation MMImageView

@synthesize enableTapAction = _enableTapAction;

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beenTapped:)];
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.numberOfTouchesRequired = 1;
    }
    return _tapGesture;
}

+ (YYWebImageManager *)circleImageManager {
    static YYWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[UIApplication sharedApplication].cachesPath stringByAppendingPathComponent:@"mars.avatar.circle"];
        YYImageCache *cache = [[YYImageCache alloc] initWithPath:path];
        manager = [[YYWebImageManager alloc] initWithCache:cache queue:[YYWebImageManager sharedManager].queue];
        manager.sharedTransformBlock = ^(UIImage *image, NSURL *url) {
            if (!image) return image;
            
            // 线路详情里的marsLogo描边不用全白
            BOOL isMarsLogo = ([url.absoluteString rangeOfString:@"3d753122be5781aa0653461bd841475e"].location != NSNotFound);
            return [UIImage circleImageWithImage:image
                                     borderWidth:CGFLOAT_FOR_DEVICE(2.f, 2.f, 2.f, 2.f)
                                     borderColor:isMarsLogo?[UIColor colorWithHexString:@"f6f6f6"]:[UIColor whiteColor]];
        };
    });
    return manager;
}

+ (YYWebImageManager *)rectangleImageManager {
    static YYWebImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[UIApplication sharedApplication].cachesPath stringByAppendingPathComponent:@"mars.avatar.rectangle"];
        YYImageCache *cache = [[YYImageCache alloc] initWithPath:path];
        manager = [[YYWebImageManager alloc] initWithCache:cache queue:[YYWebImageManager sharedManager].queue];
        manager.sharedTransformBlock = ^(UIImage *image, NSURL *url) {
            if (!image) return image;
            return [UIImage rectangleImageWithImage:image
                                        borderWidth:CGFLOAT_FOR_DEVICE(1.f, 1.f, 1.f, 1.f)
                                        borderColor:[UIColor colorWithWhite:0.773 alpha:1.000]];
        };
    });
    return manager;
}

- (UIImageView *)imageViewAssistant {
    if (!_imageViewAssistant) {
        _imageViewAssistant = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageViewAssistant;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.exclusiveTouch = YES;
        self.placeHolderImage = nil;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (BOOL)isEnableTapAction {
    return _enableTapAction;
}

- (void)setEnableTapAction:(BOOL)enableTapAction {
    self.userInteractionEnabled = enableTapAction;
    _enableTapAction = enableTapAction;
    if (enableTapAction) {
        [self addGestureRecognizer:self.tapGesture];
    } else{
        if ([self.gestureRecognizers containsObject:self.tapGesture]) {
            [self removeGestureRecognizer:self.tapGesture];
        }
    }
}


- (id)initWithFrame:(CGRect)frame placeHolderImageName:(NSString *)imageName {
    self = [self initWithFrame:frame];
    if (self) {
        self.placeHolderImageName = imageName;
    }
    return self;
}

- (void)setPlaceHolderImageName:(NSString *)placeHolderImageName {
    if (!_placeHolderImageName || ![_placeHolderImageName isEqualToString:placeHolderImageName]) {
        _placeHolderImageName = placeHolderImageName;
        if (placeHolderImageName.length && !self.placeHolderImage) {
            self.placeHolderImage = [UIImage imageNamed:placeHolderImageName];
        }
    }
}

+ (id)imageViewWithFrame:(CGRect)frame placeHolderImageName:(NSString *)imageName {
    return [[self alloc] initWithFrame:frame placeHolderImageName:imageName];
}

//响应点击事件
- (void)beenTapped:(UIGestureRecognizer *)gesture {
    if (self.imageTapBlock){
        self.imageTapBlock();
    }
}

//根据规则获取url
-(NSURL *)getImageURLWithMode:(NSString *)urlString {
    return [NSURL URLWithString:urlString];
}

- (void)setImage:(UIImage *)image {
    if (image == nil) {
        if ([self.placeHolderImageName length] > 0) {
            [super setImage:[UIImage imageNamed:self.placeHolderImageName]];
        } else {
            [super setImage:self.placeHolderImage];
        }
        
        if (!self.image) {
            self.backgroundColor = self.placeholderColor?:[UIColor colorWithWhite:0.898 alpha:1.000];
        }
        
        return;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    
    [super setImage:image];
}

-(NSString*)preprocessImageUrlByScale:(NSString*)url {
    if (IsStrEmpty(url)) {
        return @"";
    }
    return [url validImageURLWithWidth:self.frame.size.width height:self.frame.size.height mode:2];
}

-(void)setImageUrl:(NSString *)urlString {
    [self setImageUrl:urlString placeholderImage:nil];
}

- (void)setImageUrl:(NSString *)urlString completed:(ImageBlock)completedBlock {
    [self setImageUrl:urlString placeholderImage:nil loadWithAimation:YES completed:completedBlock];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholder {
    [self setImageUrl:urlString placeholderImage:placeholder loadWithAimation:YES];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholder loadWithAimation:(BOOL)animated {
    if (!placeholder) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
    }
    [self setImageUrl:urlString placeholderImage:placeholder loadWithAimation:animated completed:nil];
}

- (void)setImageUrl:(NSString *)urlString placeholderImage:(UIImage *)placeholder loadWithAimation:(BOOL)animated completed:(ImageBlock)completedBlock {
    if ([urlString length] == 0) {
        [self setImage:placeholder];
        return;
    }
    
    NSString *urlStr = [self transformImageURLToSupportWebp:urlString];
    
    __weak typeof(self) weakSelf = self;
    self.image = nil;
    
    [self.layer setImageWithURL:[NSURL URLWithString:urlStr]
                    placeholder:placeholder
                        options:YYWebImageOptionAvoidSetImage
                     completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                         __strong typeof(weakSelf) imageView = weakSelf;
                         if (!imageView) return;
                         if (image && stage == YYWebImageStageFinished) {
                             
                             if (completedBlock != nil) {
                                 completedBlock(image, url);
                             }
                             
                             imageView.image = image;
                             if (from != YYWebImageFromMemoryCacheFast) {
                                 CATransition *transition = [CATransition animation];
                                 transition.duration = 0.3f;
                                 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                                 transition.type = kCATransitionFade;
                                 [imageView.layer addAnimation:transition forKey:@"contents"];
                                 imageView.backgroundColor = [UIColor clearColor];
                             }
                         }
                     }];
}

- (void)setImageUrl:(NSString *)urlString placeholderImageName:(NSString *)placeholder borderType:(YH_ImageViewBorderType)borderType {
    [self setImageUrl:urlString placeholderImageName:placeholder borderType:borderType borderWidth:CGFLOAT_FOR_DEVICE(2.f, 2.f, 2.f, 3.f)];
}

- (void)setImageUrl:(NSString *)urlString placeholderImageName:(NSString *)placeholder borderType:(YH_ImageViewBorderType)borderType borderWidth:(CGFloat)width {
    [self setImageUrl:urlString placeholderImageName:placeholder borderType:borderType borderWidth:width borderColor:[UIColor whiteColor]];
}

- (void)setImageUrl:(NSString *)urlString placeholderImageName:(NSString *)placeholder borderType:(YH_ImageViewBorderType)borderType borderWidth:(CGFloat)width borderColor:(UIColor *)color {
    
    UIImage *placeholderImage = placeholder.length>0?[UIImage imageNamed:placeholder]:nil;
    if (borderType==YH_ImageViewBorderType_Circle && [placeholder isEqualToString:@"moren_head"])
    {
        static UIImage *defaultHeadPicImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            defaultHeadPicImage  = [UIImage circleImageWithImage:placeholderImage
                                                     borderWidth:CGFLOAT_FOR_DEVICE(2.f, 2.f, 2.f, 2.f)
                                                     borderColor:[UIColor whiteColor]];
        });
        
        placeholderImage = defaultHeadPicImage;
    }
    
    NSString *urlStr = [self transformImageURLToSupportWebp:urlString];
    
    [self setImageWithURL:[NSURL URLWithString:urlStr]
              placeholder:placeholderImage
                  options:kNilOptions
                  manager:(borderType==YH_ImageViewBorderType_Circle)?[MMImageView circleImageManager]:[MMImageView rectangleImageManager]
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)setImageScaleWithUrl:(NSString *)url placeholderImage:(UIImage *)placeholder {
    
    NSString *imageUrl = [self preprocessImageUrlByScale:url];
    if (IsStrEmpty(imageUrl)) {
        self.image = placeholder;
        return;
    }
    [self setImageUrl:imageUrl placeholderImage:placeholder];
}

- (void)addImageAnimation {
    self.alpha = 0.f;
    CABasicAnimation *animationOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationOpacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animationOpacity.fromValue = @0.f;
    animationOpacity.toValue = @1.f;
    animationOpacity.duration = 0.6f;
    [self.layer addAnimation:animationOpacity forKey:@"OpacityAnimation"];
    self.alpha = 1.f;
}

- (NSString *)transformImageURLToSupportWebp:(NSString *)imageURL {
    
    if (!imageURL || imageURL.length == 0) {
        return @"";
    }
    
    NSString *lowerString = imageURL.lowercaseString;
    
    if (![lowerString hasSuffix:@".jpg"]
        && ![lowerString hasSuffix:@".jpeg"]
        && ![lowerString hasSuffix:@".png"]
        && [lowerString rangeOfString:@"imageview"].location != NSNotFound)
    {
        if ([lowerString rangeOfString:@"/format/"].location == NSNotFound) {
            if ([lowerString rangeOfString:@".gif?imageview"].location == NSNotFound) {
                return [imageURL stringByAppendingString:@"/format/webp"];
            } else {
                // gif 要支持webp，需要先做好裁剪，然后用管道转换格式，七牛不支持对gif webp直接裁剪
                NSString *suffix = [@"|imageMogr2/format/webp" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                return [imageURL stringByAppendingString:suffix];
            }
        }
    }
    return imageURL;
}

@end
