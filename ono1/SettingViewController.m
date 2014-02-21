//
//  SettingViewController.m
//  ono1
//
//  Created by JO ARIMA on 2013/01/14.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // ピッカーを表示
    
    
    UILabel *BarLabel = [self makeLabel:CGPointMake(0, 50) text:@"小節数設定" font:[UIFont systemFontOfSize:25]];
    [self.view addSubview:BarLabel];
    
    UILabel *TempoLabel = [self makeLabel:CGPointMake(0, 350) text:@"BPM設定" font:[UIFont systemFontOfSize:25]];
    [self.view addSubview:TempoLabel];
    
    _BarPicker = [[UIPickerView alloc] init];
    _BarPicker.delegate = self;    // デリゲートを自分自身に設定
    _BarPicker.dataSource = self;  // データソースを自分自身に設定
    _BarPicker.showsSelectionIndicator = YES;  // 選択中の行に目印を付ける
    [_BarPicker setFrame:CGRectMake(0, 100, 300, 220)];
    _BarPicker.tag = 1;
    [_BarPicker selectRow:7 inComponent:0 animated:YES];
    [self.view addSubview:_BarPicker];
    
    _TempoPicker = [[UIPickerView alloc] init];
    _TempoPicker.delegate = self;    // デリゲートを自分自身に設定
    _TempoPicker.dataSource = self;  // データソースを自分自身に設定
    _TempoPicker.showsSelectionIndicator = YES;  // 選択中の行に目印を付ける
    [_TempoPicker setFrame:CGRectMake(0, 400, 300, 220)];
    _TempoPicker.tag = 2;
    [_TempoPicker selectRow:99 inComponent:0 animated:YES];
    [self.view addSubview:_TempoPicker];
    _BarNum = 2;
    _Tempo = 120;
    

}

// 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

// 行数
- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        return 16;
    }
    if (pickerView.tag == 2){
        return 250;
    }
    return 0;
}

// 行の内容
-(NSString*)pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // 行インデックス番号を返す
    return [NSString stringWithFormat:@"%d", row + 1];
}

// 選択された場合に呼ばれる
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1) {
        _BarNum = row + 1;
        
        //NSLog(@"小節数 = %d", _BarNum);
    }
    if (pickerView.tag == 2) {
        _Tempo = row + 1;
        
        //NSLog(@"テンポ = %d", _Tempo);
    }
    
    [self.delegate SettingViewControllerDelegateDidFinish:_BarNum andTempo:_Tempo];
    
}

-(UILabel*)makeLabel:(CGPoint)pos text:(NSString*)text font:(UIFont*)font{
    CGSize size = [text sizeWithFont:font];
    CGRect rect = CGRectMake(pos.x, pos.y, 300, size.height);
    
    UILabel* label = [[UILabel alloc]init];
    [label setFrame:rect];
    [label setText:text];
    [label setFont:font];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setBackgroundColor:[UIColor clearColor]];
    //[label setCenter:self.view.center];

    return label;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    printf("pickerviewDidApper!!\n");
    
    //_BarNum = appDelegate.BarNum;
    //_Tempo = appDelegate.Tempo;
    
    printf("小節数 : %d\n", _BarNum);
    printf("テンポ : %d\n", _Tempo);
    
    printf("pickerviewDidAppered!!\n");
    
    [_BarPicker selectRow:_BarNum-1 inComponent:0 animated:NO];
    [_TempoPicker selectRow:_Tempo-1 inComponent:0 animated:NO];
}
@end
