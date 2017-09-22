//
//  TakePhotoViewController.m
//  BusinessiOS
//
//  Created by cguo on 2017/9/22.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"
#import "TZLocationManager.h"
#import "PhotoModel.h"
#import "Confil.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface TakePhotoViewController ()<UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)CLLocation *location;
@property(nonatomic,strong)UIImagePickerController *imagePickerVc;
@property(nonatomic,strong)UIActivityIndicatorView *activityIndicatorView;

@end

@implementation TakePhotoViewController


- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    

    self.activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.activityIndicatorView.center=self.view.center;
    //设置样式
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicatorView setBackgroundColor:[[UIColor lightGrayColor]colorWithAlphaComponent:0.7]];
    [self.view addSubview:self.activityIndicatorView];
    //开始动画
    [self.activityIndicatorView startAnimating];
    
    UIView *view=[[UIView alloc]init];
    if ([[UIScreen mainScreen]currentMode].size.height==2346 ) {
       
        view.frame=CGRectMake(0, 0, ScreenWidth, 88);
    }else
    {
        view.frame=CGRectMake(0, 0, ScreenWidth, 64);

    }
 
    view.backgroundColor=[UIColor blackColor];
    [self.view addSubview:view];
    
    UIButton *returnBtn=[[UIButton alloc]init];
      if ([[UIScreen mainScreen]currentMode].size.height==2346 ) {
                             
       returnBtn.frame=CGRectMake(0, 44, 80, 44);
        }else
        {
            returnBtn.frame=CGRectMake(0, 20, 80, 44);
                             
        }

    
    [returnBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [returnBtn setTitle:@"取消" forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(returnClick) forControlEvents:UIControlEventTouchDown];
    [view addSubview:returnBtn];
    
    UIButton *settingBtn=[[UIButton alloc]init];
    if ([[UIScreen mainScreen]currentMode].size.height==2346 ) {
                             
    settingBtn.frame=CGRectMake(ScreenWidth-80, 44, 80, 44);

    }else
    {
    settingBtn.frame=CGRectMake(ScreenWidth-80, 20, 80, 44);
                             
    }

    [settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [settingBtn setTitle:@"去设置" forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(ToSetting) forControlEvents:UIControlEventTouchDown];
    [view addSubview:settingBtn];

    
    UILabel *settingLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 100, ScreenWidth, 30)];
    settingLabel.text=@"你授权拍照或相册的权限，请设置";
    
}

-(void)returnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [self takePhoto];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Method

/// 拍照按钮点击事件
- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) && iOS7Later) {
        // 无权限 做一个友好的提示
        NSString *appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"];
        if (!appName) appName = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleName"];
        NSString *message = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Please allow %@ to access your camera in \"Settings -> Privacy -> Camera\""],appName];
        if (iOS8Later) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle tz_localizedStringForKey:@"Can not use camera"] message:message delegate:self cancelButtonTitle:[NSBundle tz_localizedStringForKey:@"Cancel"] otherButtonTitles:[NSBundle tz_localizedStringForKey:@"Setting"], nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSBundle tz_localizedStringForKey:@"Can not use camera"] message:message delegate:self cancelButtonTitle:[NSBundle tz_localizedStringForKey:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self pushImagePickerController];
                    });
                }
            }];
        } else {
            [self pushImagePickerController];
        }
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    [self GetPhoto];
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
        weakSelf.location = location;
    } failureBlock:^(NSError *error) {
        weakSelf.location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        
        NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            NSString *errorStr = @"应用相机权限受限,请在设置中启用";
            
            NSLog(@"err --%@ ",errorStr);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"拍摄权限被禁止了，没法进行拍照。请授权!" delegate:self cancelButtonTitle:@"残忍拒绝" otherButtonTitles:@"确定", nil];
            [alertView show];
            
            return;
        }else
        {

        self.imagePickerVc.sourceType = sourceType;
        if(iOS8Later) {
             self.imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:self.imagePickerVc animated:YES completion:nil];
        }
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

-(void)GetPhoto
{

  
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author==kCLAuthorizationStatusNotDetermined) {
          [[TZImageManager manager]getCameraRollAlbum:NO allowPickingImage:NO completion:nil];
    }
    if (author ==kCLAuthorizationStatusDenied  )
    {
        //无权限
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"访问相册权限被禁止了，无法选择拍照的图片，请授权!" delegate:self cancelButtonTitle:@"残忍拒绝" otherButtonTitles:@"去开启", nil];
        [alertView show];
        
        return ;
        
    }
}
-(void)ToSetting
{
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
   

    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (IOS8Later) {
            [self ToSetting];
        }
    }if(buttonIndex==0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
 
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
        [imagePickerVc showProgressHUD];
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (photo) {
            [[TZImageManager manager] savePhotoWithImage:photo location:self.location completion:^(NSError *error){
                if (!error) {
                    [self reloadPhoto];
                    
                 
                }else
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"获取图片识别，没有访问相册的权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            }];
            self.location = nil;
        }
    }
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    NSLog(@"%@",picker);
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"取消了");
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)reloadPhoto
{
    [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
//        _model = model;
        [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {

            TZAssetModel *Assetmodel=models.firstObject;
            NSLog(@"%@",Assetmodel.asset);
           
             PhotoModel *photomodel=[PhotoModel GetPhotoModelByPHAsset:Assetmodel.asset imageSize:CGSizeMake(0, 0)];
            
            if (self.didFinishTakePhotosHandle) {
                self.didFinishTakePhotosHandle(photomodel.image, (PHAsset*)Assetmodel.asset);
            }

        }];
         }];
}
@end
