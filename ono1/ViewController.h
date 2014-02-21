//
//  ViewController.h
//  ono1
//
//  Created by JO ARIMA on 2012/12/29.
//  Copyright (c) 2012年 JO ARIMA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "testView.h"
#import "paletteView.h"
#import "DragDropManager.h"
#import "ProjectViewController.h"

@class DragDropManager;

@interface ViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    UIScrollView* scrollview;
    UIScrollView* pscrollview;
    
    testView* testview;
    paletteView* paletteview;
    
    //UIApplication* application;
    
    DragDropManager *_dragDropManager;
    
    
}

-(void)pauseButtonDidPushed;

@property (nonatomic, retain)UIImageView* playHead;

@property(nonatomic, retain)UIButton *playbutton;
@property(nonatomic, retain)UIBarButtonItem *metrobutton;
@property(nonatomic, retain)UIBarButtonItem *zoomScalebutton;
@property(nonatomic, retain)UIBarButtonItem *pausebutton;
@property(nonatomic, retain)UIBarButtonItem *settingbutton;
@property(nonatomic, retain)UIBarButtonItem *space;
@property(nonatomic, retain)UIBarButtonItem *savebutton;
@property(nonatomic, retain)UIBarButtonItem *loadbutton;
@property(nonatomic, retain)UIBarButtonItem *erasebutton;
@property(nonatomic, retain)UIBarButtonItem *loopbutton;
@property(nonatomic, retain)UIBarButtonItem *scrollbutton;

@property NSUInteger transitionNum;

@property ProjectViewController *projectView;

@property(nonatomic,retain) NSMutableArray *projectName;

//@property NSMutableArray* draggableSubjects;

@end
