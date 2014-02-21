//
//  ProjectViewController.h
//  ono1
//
//  Created by JO ARIMA on 2013/01/22.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragDropManager.h"
#import "AppDelegate.h"

@class DragDropManager;
@interface ProjectViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>


@property(nonatomic,retain) UITableView* tableview;
@property(nonatomic,retain) UITextField *textField;

@property(nonatomic,retain) NSMutableArray *projectName;
@property(nonatomic,retain) NSMutableArray* dragSubjects;

@property(nonatomic,retain) DragDropManager *dragdropmanager;

@property NSUInteger transitionNumber;

@property BOOL isEqualName;


@property int BarNum;
@property int Tempo;



@end
