//
//  SettingViewController.h
//  ono1
//
//  Created by JO ARIMA on 2013/01/14.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import <UIKit/UIKit.h>
//======================================================================
//ここでDragDropManager.hをimportすると循環参照が起こり，DragDropManager.h側で
//SettingViewControllerDelegateの宣言してねえ！ってエラーが出る
//======================================================================
#import "AppDelegate.h"


@protocol SettingViewControllerDelegate;


@interface SettingViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    id <SettingViewControllerDelegate> delegate;
}


@property int BarNum;
@property int Tempo;

@property(nonatomic,retain) UIPickerView *BarPicker;
@property(nonatomic,retain) UIPickerView *TempoPicker;

@property (nonatomic, assign) id <SettingViewControllerDelegate> delegate;

@end


@protocol SettingViewControllerDelegate

- (void)SettingViewControllerDelegateDidFinish:(NSInteger)getBar andTempo:(NSInteger)getTempo;



@end
