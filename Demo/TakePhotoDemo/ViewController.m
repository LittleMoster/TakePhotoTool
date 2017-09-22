//
//  ViewController.m
//  TakePhotoDemo
//
//  Created by cguo on 2017/9/22.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import "ViewController.h"
#import "TakePhotoViewController.h"
#import "TZImagePickerController.h"
#import "PhotoModel.h"

@interface ViewController ()<UIActionSheetDelegate,TZImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择图片", nil];
    
    [action showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld",buttonIndex);
    
    if (buttonIndex==0) {
        
        TakePhotoViewController *imageController=[[TakePhotoViewController alloc]init];
        [imageController setDidFinishTakePhotosHandle:^(UIImage *image, PHAsset *asset) {
            
            
            PhotoModel *model=[PhotoModel GetPhotoModelByPHAsset:asset imageSize:CGSizeMake(0, 0)];
            
            
            
            
            NSLog(@"%@",model);
            
            
            
        }];
        
        [self presentViewController:imageController animated:YES completion:nil];
    }
    else if (buttonIndex==1) {
        
        
        TZImagePickerController *imageController=[[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
        imageController.allowPickingVideo=NO;
        
        
        [imageController setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photoArr, NSArray *PHAsset, BOOL scor) {
            
            NSLog(@"%@---%@",photoArr,PHAsset);
            
            
            NSMutableArray *modelArr=[PhotoModel GetPhotoModelArrByPHAssetArr:PHAsset imageSize:CGSizeMake(0, 0)];
            
            
            
            PhotoModel *model=modelArr.firstObject;
            //imageV.image=model.image;
            NSLog(@"%@",model);
            
            
        }];
        
        [self presentViewController:imageController animated:YES completion:nil];

    }
    else if (buttonIndex==2) {
        
     
        
    }
}
@end
