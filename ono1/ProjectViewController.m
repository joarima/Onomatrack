//
//  ProjectViewController.m
//  ono1
//
//  Created by JO ARIMA on 2013/01/22.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import "ProjectViewController.h"
#import "ViewController.h"
#import "onoImageView.h"
@interface ProjectViewController ()

@end

@implementation ProjectViewController

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

    _isEqualName = NO;

    _tableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [_tableview setFrame:self.view.frame];
    [_tableview setDelegate:self];
    [_tableview setDataSource:self];
    [self.view addSubview:_tableview];
    //===========================================
#pragma mark: 最初の一個を作るのにこれがいる．なんかの理由でコメントアウトしてた．要調査 -> 毎回initしちゃうと消えるから
    //_projectName = [[NSMutableArray alloc] init];
    //===========================================

    //ビューのサイズの自動調整
    _tableview.autoresizingMask=
    UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|
    UIViewAutoresizingFlexibleLeftMargin|
    UIViewAutoresizingFlexibleBottomMargin|
    UIViewAutoresizingFlexibleWidth|
    UIViewAutoresizingFlexibleHeight;
    
    if (_transitionNumber == 1) {
        UIAlertView *alert = [[UIAlertView alloc]
                              
                              initWithTitle:@"プロジェクトを保存します\nプロジェクト名を入力してください"
                              
                              message:@" "
                              
                              delegate:self
                              
                              cancelButtonTitle:@"Cancel"
                              
                              otherButtonTitles:@"OK", nil];
        // UITextFieldの生成
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(12, 85, 260, 25)];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.font = [UIFont fontWithName:@"Arial-BoldMT" size:18];
        _textField.textColor = [UIColor grayColor];
        _textField.minimumFontSize = 8;
        _textField.adjustsFontSizeToFitWidth = YES;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.delegate = self;
        //_textField.text = button.titleLabel.text;
        
        // アラートビューにテキストフィールドを埋め込む
        [alert addSubview:_textField];
        // テキストフィールドをファーストレスポンダに
        [_textField becomeFirstResponder];
        
        // アラート表示
        [alert show];
    }else if(_transitionNumber == 2){
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"testdata.plist"];
        
        NSMutableArray* tmparr = [NSMutableArray arrayWithContentsOfFile:filePath];
        NSLog(@"%@", tmparr);
        
        NSMutableArray* namearr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* panarr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* soundnumarr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* tagarr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* volumearr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* xarr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* yarr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* widtharr = [[NSMutableArray alloc] initWithCapacity:1];
        NSMutableArray* heightarr = [[NSMutableArray alloc] initWithCapacity:1];
        
        for (int i=0; i<tmparr.count; i++) {
            //NSMutableDictionary* tmpdic = [NSMutableDictionary dictionary];
#pragma mark: Analyzeに言われて変更したとこ
            NSMutableDictionary* tmpdic = [tmparr objectAtIndex:i];
            NSString *name = [tmpdic objectForKey:@"name"];
            NSNumber *numpan = [tmpdic objectForKey:@"pan"];
            NSNumber *numsoundnum = [tmpdic objectForKey:@"soundnum"];
            NSNumber *numtag = [tmpdic objectForKey:@"tag"];
            NSNumber *numvolume = [tmpdic objectForKey:@"volume"];
            NSNumber *numx = [tmpdic objectForKey:@"x"];
            NSNumber *numy = [tmpdic objectForKey:@"y"];
            NSNumber *numwidth = [tmpdic objectForKey:@"width"];
            NSNumber *numheight = [tmpdic objectForKey:@"height"];
            //float pan = [numpan floatValue];
            [namearr addObject:name];
            [panarr addObject:numpan];
            [soundnumarr addObject:numsoundnum];
            [tagarr addObject:numtag];
            [volumearr addObject:numvolume];
            [xarr addObject:numx];
            [yarr addObject:numy];
            [widtharr addObject:numwidth];
            [heightarr addObject:numheight];
            //printf("%s\n",[name UTF8String]);
        }
//        for (int i=0; i<namearr.count; i++) {
//            printf("name : %s\n",[[namearr objectAtIndex:i] UTF8String]);
//            printf("pan : %f\n",[[panarr objectAtIndex:i] floatValue]);
//            printf("soundnum : %d\n",[[soundnumarr objectAtIndex:i] intValue]);
//            printf("tag : %d\n",[[tagarr objectAtIndex:i] intValue]);
//            printf("volume : %f\n",[[volumearr objectAtIndex:i] floatValue]);
//            printf("x : %f\n",[[xarr objectAtIndex:i] floatValue]);
//            printf("y : %f\n",[[yarr objectAtIndex:i] floatValue]);
//            printf("width : %f\n",[[widtharr objectAtIndex:i] floatValue]);
//            printf("height : %f\n",[[heightarr objectAtIndex:i] floatValue]);
//            
//            // [[namearr objectAtIndex:i] replaceOccurrencesOfString:@".png" withString:@"$%" options:0 range:NSMakeRange(0, [[namearr objectAtIndex:i] length])];
//        }
        
       
    }
    
//    UIScrollView *projectScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 1024, 768)];
//    UIImage *image = [UIImage imageNamed:@"earth.png"];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    CGRect rect = imageView.frame;
//    rect.size.height = 128;
//    rect.size.width = 128;
//    imageView.frame = rect;
//    imageView.center = self.view.center;
//    
//    [self.view addSubview:imageView];
//    
//    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
//    //singleFingerTap.delegate = self;
//    
//    [self.view addGestureRecognizer:singleFingerTap];
//    
//    CGPoint pointInImage = [singleFingerTap locationInView:imageView];
//    BOOL pointInSideImage = [imageView pointInside:pointInImage withEvent:nil];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Canselボタンが押されたとき
            printf("cancel button did pushed\n");
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        case 1:
            // OKボタンが押されたとき
            printf("OK button did pushed\n");
            if ([_textField.text length]) {
                NSString * name = [[NSString alloc]initWithString:_textField.text];
                printf("%s\n",[name UTF8String]);
                
                for (int i=0; i<_projectName.count; i++) {
                    _isEqualName = [name isEqualToString:[_projectName objectAtIndex:i]];
#pragma mark: この下のif文で同じ名前がリストに入るのを防いでる
                    if (_isEqualName && _projectName.count>0) {
                        break;
                    }
                }
                if (!_isEqualName) {
                    [_projectName addObject:_textField.text];
                    printf("%s\n",[[_projectName objectAtIndex:0] UTF8String]);
                    //[_projectName addObject:@"hoge"];
                }
                
                for (int i=0; i<_projectName.count; i++) {
                    printf("保存前 : %s\n",[[_projectName objectAtIndex:i] UTF8String]);
                    if (i == _projectName.count-1) {
                        printf("\n===========================\n");
                    }
                }
                
                NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"project.plist"];
                //NSDictionary *myDictionary = [NSDictionary dictionary];
                
                // 保存
                [_projectName/*myDictionary*/ writeToFile: filePath  // (NSString *) ファイルパス
                               atomically: YES];     // (BOOL) 予備ファイルを生成
                
                //dragsubjectsの保存
                if (_dragSubjects.count > 39) {
                    NSString* str1 =[[NSString alloc]initWithString:_textField.text];
                    NSString* str2 =@"data.plist";
                    NSString* dragsubjectsData = [str1 stringByAppendingString:str2];
                    NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                    NSString *filePathForDragSubjects = [directory stringByAppendingPathComponent:dragsubjectsData];
                    
                    NSMutableArray* tmparr = [[NSMutableArray alloc] initWithCapacity:1];
                    
                    //onoImageView* tmpimage = [[onoImageView alloc]init];
//                    [mdic writeToFile: filePathForDragSubjects  // (NSString *) ファイルパス
//                                                   atomically: YES];
#pragma mark: AppDelegateを経由してDragDropManagerから小節数とテンポを持ってきてる
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    
                    for (int i = 40; i<_dragSubjects.count; i++) {
                        #pragma mark: Analyzeに言われて変更したとこ
                        onoImageView* tmpimage = [_dragSubjects objectAtIndex:i];
                        NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
                        [mdic setObject:[NSNumber numberWithFloat:tmpimage.frame.origin.x] forKey:@"x"];
                        [mdic setObject:[NSNumber numberWithFloat:tmpimage.frame.origin.y] forKey:@"y"];
                        
                        [mdic setObject:tmpimage.imageName forKey:@"name"];
                        
                        [mdic setObject:[NSNumber numberWithInt:tmpimage.soundNumber] forKey:@"soundnum"];
                        
                        [mdic setObject:[NSNumber numberWithInt:tmpimage.tag]forKey:@"tag"];
                        
                        [mdic setObject:[NSNumber numberWithFloat:tmpimage.pan]forKey:@"pan"];
                        
                        [mdic setObject:[NSNumber numberWithFloat:tmpimage.volume]forKey:@"volume"];
                        
                        [mdic setObject:[NSNumber numberWithFloat:tmpimage.frame.size.width] forKey:@"width"];
                        
                        [mdic setObject:[NSNumber numberWithFloat:tmpimage.frame.size.height] forKey:@"height"];
                        #pragma mark: 小節数とテンポを追加
                        [mdic setObject:[NSNumber numberWithInt:appDelegate.BarNum] forKey:@"BarNum"];
                        
                        [mdic setObject:[NSNumber numberWithInt:appDelegate.Tempo] forKey:@"Tempo"];
                        
                        [tmparr addObject:mdic];

                    }
                    
                    
                    
                    [tmparr writeToFile: filePathForDragSubjects  // (NSString *) ファイルパス
                                                   atomically: YES];     // (BOOL) 予備ファイルを生成
//                    for (int i=0; i<tmparr.count; i++) {
//                        printf("保存後 : %d\n",i);
//                    }
                    
                    //[NSKeyedArchiver archiveRootObject:_dragSubjects toFile:filePathForDragSubjects];
                    
                    // 読み込み
                    //                NSMutableArray* tmparray = [NSMutableArray arrayWithContentsOfFile:filePath];//] initWithCapacity:1];
                    //                for (int i=0; i<tmparray.count; i++) {
                    //                    printf("保存後 : %s\n",[[tmparray objectAtIndex:i] UTF8String]);
                    //                    if (i == tmparray.count-1) {
                    //                        printf("\n===========================\n");
                    //                    }
                    //
                    //                }
                    
                    //myDictionary = [NSData dictionaryWithContentsOfFile:filePath];  // (NSString *) ファイルパス
                    
                    
                    //                for (int i=0; i<_dragDropManager.dragSubjects.count; i++) {
                    //                    printf("%s\n",[[_dragDropManager.dragSubjects objectAtIndex:i] UTF8String]);
                    //                }

                }
                                [self.tableview reloadData];
            }
            break;
        default:
            break;
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除をします。
    UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:indexPath];
    
    //_dragdropmanager.plistName = cell.textLabel.text;
    [_dragdropmanager loadProject:cell.textLabel.text];
    
    printf("%s\n",[cell.textLabel.text UTF8String]);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [_projectName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier];
    }
    
    
    NSString *cellValue = [_projectName objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"プロジェクト一覧";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"現在プロジェクトの削除はできないようになってます\n同じ名前のプロジェクトは上書きされます";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
