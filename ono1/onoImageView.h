//
//  onoImageView.h
//  ono1
//
//  Created by JO ARIMA on 2013/01/01.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "handleView.h"

@interface onoImageView : /*handleView*/UIImageView<NSCoding>{

}
-(onoImageView *)deepCopy:(onoImageView*)draggedimage;

//-(void)setCollision:(BOOL)colision;

@property(getter = getisInCanvas) BOOL isInCanvas;//キャンバス上に置かれているかどうか
@property (setter = setIsTapped:)BOOL isTapped;//タップされて編集オーケーの状態にあるかどうか
@property BOOL isDragged;//一度でもドラッグされたことがあるか
@property NSString* imageName;
@property NSUInteger dragCount;
@property onoImageView* lastImage;

@property float originalSize_width;
@property float originalSize_height;

@property(setter = setCollision:, getter = getCollision) BOOL collision;
@property(setter = setdidPlayed:, getter = getdidPlayed) BOOL didPlayed;

@property NSUInteger soundNumber;

@property handleView *handle1;//左
@property handleView *handle2;//上
@property handleView *handle3;//右
@property handleView *handle4;//下

@property UIImageView* imageselectedframe;//選択時のフレーム

//@property AVAudioPlayer* audio;
@property float pan;
@property float volume;

@end

