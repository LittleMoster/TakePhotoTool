//
//  TakePhotoViewController.h
//  BusinessiOS
//
//  Created by cguo on 2017/9/22.
//  Copyright © 2017年 zjq. All rights reserved.
//

#import <UIKit/UIKit.h>


@class  PHAsset;
@interface TakePhotoViewController : UIViewController

@property (nonatomic, copy) void (^didFinishTakePhotosHandle)(UIImage *photo,PHAsset *asset);

@end
