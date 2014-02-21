//
//  ViewController.m
//  ono1
//
//  Created by JO ARIMA on 2012/12/29.
//  Copyright (c) 2012年 JO ARIMA. All rights reserved.
//

#import "ViewController.h"
#import "testView.h"
#import "paletteView.h"
#import "AppDelegate.h"
#import "onoImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "handleView.h"


@interface ViewController ()

@end


@implementation ViewController

const NSUInteger ononum =40/*83*/;//7;//音数


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)layoutScrollImages
{
	handleView *view = nil;
	NSArray *subviews = [pscrollview subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curYLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[/*handleView*/UIImageView class]] && view.tag > 0)
		{
			CGRect frame = view.frame;
			frame.origin = CGPointMake(50, curYLoc);
			view.frame = frame;
			
            
			curYLoc += (128);
		}
	}
	
	// set the content size so it can be scrollable
	//[pscrollview setContentSize:CGSizeMake((kNumImages * kScrollObjWidth), [scrollView1 bounds].size.height)];
}
#pragma mark -
//TODO: ドラッグ時にタップされたオブジェクトを前面に持ってくるようにする
//TODO: ドラッグ時にタップ開始から少し遅延があってからドラッグ開始できるようにした方がいいかも
//TODO: オブジェクト以外の場所を素早くスワイプしないとスクロールされない(長く触っちゃうとスクロールできない)のを直す
#pragma mark -
-(void)loadView{
    
    
    [super loadView];
    
    
    _projectName = [[NSMutableArray alloc] initWithCapacity:1];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *dir = [paths objectAtIndex:0];
//    NSLog(@"%@", dir);
//    
//    NSString *dirB = [dir stringByAppendingPathComponent:@"Documents"];
//    NSString *pathB = [dirB stringByAppendingPathComponent:@"project.plist"];
//    NSLog(@"%@", pathB);
    //プロジェクトネームをplistから読み出してる
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"project.plist"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO){
        //ファイルが存在しなければファイルを作成する
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }else{
        //_projectName = [NSMutableArray array];
        _projectName = [NSMutableArray arrayWithContentsOfFile:filePath];
        if ([_projectName count] == 0) {
            //printf("project.plist is empty!\n");
            _projectName = [[NSMutableArray alloc] initWithCapacity:1];
            
        }
    }
    
    
    
    
    //    UINavigationController *navigationController = [[ UINavigationController alloc ] initWithRootViewController: self ];
//    //navigationController.view.frame = CGRectMake(0, 0, 1024, 200);
//    [self.view addSubview: navigationController.view ];
//    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    
//        NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"basket-full.png", @"bin-empty.png", @"clock.png", @"earth.png", @"hint.png", @"right.png", @"timer.png", nil];
    
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:
                           @"ウィ.png",@"カ.png",@"カコ.png",@"ガコ.png",@"ガサ.png",@"ガシ.png",@"カタ.png",@"カラカラ.png",@"カン.png",@"ギ.png",
                           @"キン.png",@"コ.png",@"シ.png",@"ジ.png",@"シャ.png",@"シャーン.png",@"シャキ.png",@"シャン.png",@"タン.png",@"ダン.png",
                           @"チ.png",@"チーン.png",@"チキ.png",@"チャリ.png",@"チン.png",@"ツ.png",@"トン.png",@"ドン.png",@"パ.png",
                           @"パチ.png",@"パン.png",@"ピ.png",@"ビリ.png",@"ビロ.png",@"プ.png",@"ペン.png",@"ポ.png",@"ポー.png",@"ボン.png",@"ポン.png",nil];
    
    NSMutableArray* draggableSubjects;
    draggableSubjects = [[NSMutableArray alloc]init];
    
    
    //AVAudioPlayerは再生ラグがでかいので使うのをやめた
//    NSArray *audiofilename = [[NSArray alloc]initWithObjects:@"BD",@"SD",@"FTom",@"MTom",@"HTom",@"HH",@"CCym",@"Ride",nil];
//    
//    NSArray *audiofilename = [[NSArray alloc]initWithObjects:@"カ",@"カサ",@"ガサ",@"カタ",@"ガタ",@"カチ",@"カチコチ",@"ガツ",@"カン",@"ギー",@"キュ",@"キン",@"コ",@"サー",@"ザー",@"ジー",@"タ",@"ダ",@"ダン",@"チ",@"ヂ",@"チャリ",@"チン",@"ツ",@"ヅ",@"ト",@"ド",@"バタ",@"パチ",@"バン",@"ビ",@"ピ",@"ピー",@"ブ",@"ブー",@"ブツ",@"ボ",@"ボガ",@"ボン",nil];
    
    //NSString * path = nil;
    //NSURL * url = nil;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 768, 750)];
    [self.view addSubview:scrollview];
    [scrollview setCanCancelContentTouches:NO];//この指定でscrollviewの中でドラッグできるようになってる．pscrollviewのも同様
    [scrollview setClipsToBounds:NO];
    //[scrollview setDelaysContentTouches:NO];
    //scrollview.exclusiveTouch=YES;
    
    
    pscrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(769, 0, 257, 768)];
    [self.view addSubview:pscrollview];
    [pscrollview setCanCancelContentTouches:NO];
    [pscrollview setClipsToBounds:NO];
    //pscrollview.delaysContentTouches = NO;
    //[pscrollview setDelaysContentTouches:NO];
    //pscrollview.exclusiveTouch=YES;
    pscrollview.bounces = NO;//バウンスさせない
    
    //NSLog(@"ViewController.view.tag : %d", self.view.tag);
    
    testview = [[testView alloc]initWithFrame:CGRectMake(0, 0, 9700, 768)];
    testview.backgroundColor = [UIColor whiteColor];
    
    
    paletteview = [[paletteView alloc]initWithFrame:CGRectMake(0, 0, 256, 5200)];
    paletteview.backgroundColor = [UIColor grayColor];

    
    [scrollview addSubview:testview];
    [pscrollview addSubview:paletteview];
    
    
    //再生ヘッドの描画
    UIImageView* fakePlayHead = [[handleView alloc]initWithImage:[UIImage imageNamed: @"playHeadsample.png"]];
    _playHead = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 768)];
//    _playHead.backgroundColor = [UIColor blackColor];
    _playHead.opaque = NO;
    _playHead.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    [fakePlayHead setFrame:CGRectMake(0, 0, 3, 768)];
    fakePlayHead.center = _playHead.center;
    [_playHead setFrame:CGRectMake(35, 0, 30, 768)];
    [testview addSubview:_playHead];
    
    
    [_playHead addSubview:fakePlayHead];
    
    
    
    testview.tag = 1;
    paletteview.tag = 2;
    
    NSMutableArray *droppableAreas = [[NSMutableArray alloc] initWithObjects:testview, paletteview, nil];//ドラッグ可能なビュー
    
    NSUInteger j;
	for (j = 0; j < ononum; j++)
	{
		//NSString *imageName = [NSString stringWithFormat:[mdic objectForKey:i], i];
		UIImage *image = [UIImage imageNamed:[arr objectAtIndex:j]];
		onoImageView *imageView = [[onoImageView alloc] initWithImage:image];
		imageView.imageName = arr[j];
        //imageView.userInteractionEnabled = YES;
        //imageView.exclusiveTouch=YES;
        
		// setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
		CGRect rect = imageView.frame;
		rect.size.height = 128;
		rect.size.width = 128;
		imageView.frame = rect;
		imageView.tag = j+1;// tag our images for later use when we place them in serial fashion
		
        //サウンド再生用の番号．OpenALで使ってる
        imageView.soundNumber = j;
        
        //AVAudioPlayerは再生ラグがでかいので使うのをやめた
//        path = [[NSBundle mainBundle] pathForResource:[audiofilename objectAtIndex:j] ofType:@"mp3"];
//        //path = [[NSBundle mainBundle] pathForResource:@"カ" ofType:@"caf"];
//        url = [NSURL fileURLWithPath:path];
//        imageView.audio = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        //[audio setDelegate:self];//もし再生終了時に再びprepareToPlayが必要なようなら
        //- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer*)audio とか使う
        //[imageView.audio prepareToPlay];//ここじゃなくてdrag'n'drop manager内でコピーされるときに準備
        
        [pscrollview addSubview:imageView];
        
        imageView.volume = 0.5;
        
        [self drawHandle:imageView];
        
        [draggableSubjects addObject:imageView];//ドラッグ用に追加
		//[imageView release];
	}
    [self layoutScrollImages];	// now place the photos in serial layout within the scrollview

    
    [scrollview setContentSize:CGSizeMake(4900, 768)];
    [pscrollview setContentSize:CGSizeMake(256, 5200)];
    
    
        
    
    
    _dragDropManager = [[DragDropManager alloc] initWithDragSubjects:draggableSubjects andDropAreas:droppableAreas andplayHead:_playHead andscrollview:scrollview];
    
    //ドラッグ検出用Recognizer
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:_dragDropManager action:@selector(dragging:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;

    [[self view] addGestureRecognizer:panGestureRecognizer];
    
    // シングルタップ検出用Rcognizer
    //    Tapping (any number of taps)
    //    UITapGestureRecognizer
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc]initWithTarget:_dragDropManager action:@selector(singleTap:)];
    singleFingerTap.delegate = self;
    
    [self.view addGestureRecognizer:singleFingerTap];
    
    //ダブルタップ検出用
    UITapGestureRecognizer* doubleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:_dragDropManager action:@selector(doubleTap:)];
    doubleFingerTap.numberOfTapsRequired = 2;
    doubleFingerTap.delegate = self;
    [self.view addGestureRecognizer:doubleFingerTap];
    
    // ロングプレスジェスチャーを作成
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:_dragDropManager
                                                                                                   action:@selector(handleLongPressGesture:)];

    // 15ピクセルまでは指が動いても許容する
    longPressGesture.allowableMovement = 15;
    // ジェスチャーを認識する秒数
    longPressGesture.minimumPressDuration = 1;
    // ジェスチャーを認識する指の数
    longPressGesture.numberOfTouchesRequired = 1;
    // ジェスチャーを認識するタップの数
    longPressGesture.numberOfTapsRequired = 0;
    // ビューにジェスチャーを追加
    [self.view addGestureRecognizer:longPressGesture];
    
    
    //実機で動かす時はスクロールは2本指の方がいい
    scrollview.panGestureRecognizer.minimumNumberOfTouches = 2;
    
    
    [scrollview setDelegate:self];
    [scrollview setMinimumZoomScale:0.5];
    [scrollview setMaximumZoomScale:10.0];
    
     
    
      //ナビゲーションバーにボタンを追加してる．ボタンの配置は後から考える
    
    
//    UIBarButtonItem *zoomScalebutton = [[UIBarButtonItem alloc] initWithTitle:@"x1" style:UIBarButtonItemStylePlain target:self action:@selector(zoomScaleButtonDidPushed)];
    
    
    UIImage *zoomscaleimage = [UIImage imageNamed:@"empty-circle.png"];
    UIButton *zoomscalebuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, zoomscaleimage.size.width + 1, zoomscaleimage.size.height + 1)];
    [zoomscalebuttonimage setBackgroundImage:zoomscaleimage forState:UIControlStateNormal];
    zoomscalebuttonimage.showsTouchWhenHighlighted = YES;
    [zoomscalebuttonimage addTarget:self action:@selector(zoomScaleButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, zoomscaleimage.size.width, zoomscaleimage.size.height -1)];
    label.text = @"x1";
    label.adjustsFontSizeToFitWidth = YES;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [zoomscalebuttonimage addSubview:label];
    _zoomScalebutton = [[UIBarButtonItem alloc] initWithCustomView:zoomscalebuttonimage];
    _zoomScalebutton.tag = 1;
    
    
    UIImage* settingimage = [UIImage imageNamed:@"gear.png"];
    UIButton *settingbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, settingimage.size.width, settingimage.size.height)];
    [settingbuttonimage setBackgroundImage:settingimage forState:UIControlStateNormal];
    settingbuttonimage.showsTouchWhenHighlighted = YES;
    [settingbuttonimage addTarget:_dragDropManager action:@selector(settingButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
   _settingbutton = [[UIBarButtonItem alloc] initWithCustomView:settingbuttonimage];
    
    UIImage* metroimage = [UIImage imageNamed:@"bell.png"];
    UIButton *metrobuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, metroimage.size.width, metroimage.size.height)];
    [metrobuttonimage setBackgroundImage:metroimage forState:UIControlStateNormal];
    metrobuttonimage.showsTouchWhenHighlighted = YES;
    [metrobuttonimage addTarget:self action:@selector(metroButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    _metrobutton = [[UIBarButtonItem alloc] initWithCustomView:metrobuttonimage];
    
    UIImage* saveimage = [UIImage imageNamed:@"froppy.png"];
    UIButton *savebuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, saveimage.size.width, saveimage.size.height)];
    [savebuttonimage setBackgroundImage:saveimage forState:UIControlStateNormal];
    savebuttonimage.showsTouchWhenHighlighted = YES;
    [savebuttonimage addTarget:self action:@selector(saveButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    _savebutton = [[UIBarButtonItem alloc] initWithCustomView:savebuttonimage];
    
    UIImage* loadimage = [UIImage imageNamed:@"diary.png"];
    UIButton *loadbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, loadimage.size.width, loadimage.size.height)];
    [loadbuttonimage setBackgroundImage:loadimage forState:UIControlStateNormal];
    loadbuttonimage.showsTouchWhenHighlighted = YES;
    [loadbuttonimage addTarget:self action:@selector(loadButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    _loadbutton = [[UIBarButtonItem alloc] initWithCustomView:loadbuttonimage];

    UIImage* eraseimage = [UIImage imageNamed:@"eraser.png"];
    UIButton *erasebuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, eraseimage.size.width, eraseimage.size.height)];
    [erasebuttonimage setBackgroundImage:eraseimage forState:UIControlStateNormal];
    erasebuttonimage.showsTouchWhenHighlighted = YES;
    [erasebuttonimage addTarget:self action:@selector(eraseButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    _erasebutton = [[UIBarButtonItem alloc] initWithCustomView:erasebuttonimage];

    UIImage* loopimage = [UIImage imageNamed:@"loop2.png"];
    UIButton *loopbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, loopimage.size.width, loopimage.size.height)];
    [loopbuttonimage setBackgroundImage:loopimage forState:UIControlStateNormal];
    loopbuttonimage.showsTouchWhenHighlighted = YES;
    [loopbuttonimage addTarget:self action:@selector(loopButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    _loopbutton = [[UIBarButtonItem alloc] initWithCustomView:loopbuttonimage];
    
    UIImage* scrollimage = [UIImage imageNamed:@"scroll1.png"];
    UIButton *scrollbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, scrollimage.size.width, scrollimage.size.height)];
    [scrollbuttonimage setBackgroundImage:scrollimage forState:UIControlStateNormal];
    scrollbuttonimage.showsTouchWhenHighlighted = YES;
    [scrollbuttonimage addTarget:self action:@selector(scrollButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    _scrollbutton = [[UIBarButtonItem alloc] initWithCustomView:scrollbuttonimage];
    
    //スペースを作ってとりあえずplaybuttonを中央に配置
    _space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    _space.tag=2;
    //再生用のメソッド呼んでる
    //_isPlayed = NO;
//    UIBarButtonItem *playbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:_dragDropManager action:@selector(playButtonDidPushed)];
//    self.navigationItem.titleView = playbutton;
    //playbutton.width = (CGFloat)150;
    
    
    UIButton *pausebuttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    [pausebuttonView setImage:[UIImage imageNamed:@"pauseButton1.png"]
                 forState:UIControlStateNormal];
    pausebuttonView.showsTouchWhenHighlighted = YES;
    [pausebuttonView addTarget:self action:@selector(pauseButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        pausebuttonView.tag=3;
    _pausebutton = [[UIBarButtonItem alloc] initWithCustomView:pausebuttonView];
    
    _playbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    _playbutton.showsTouchWhenHighlighted = YES;
    
    [_playbutton setImage:[UIImage imageNamed:@"playButton1.png"]
                           forState:UIControlStateNormal];
    //[_playbutton setImage:[UIImage imageNamed:@"stop.png"]
    //             forState:UIControlStateHighlighted];
    [_playbutton addTarget:self action:@selector(playButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _playbutton;
    _playbutton.tag=4;
    
    _dragDropManager.playbutton = _playbutton;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton,  _loopbutton,_scrollbutton, _space, _pausebutton, nil];
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:_loadbutton, _erasebutton, _space, _savebutton, nil];
    
    //これでnavigationbarのデリゲートを設定できる
//    self.navigationController.navigationBar.delegate = self;
//    self.navigationController.navigationBar.ite;
//    for (int i=0; i<self.navigationController.navigationBar.items.count; i++) {
//        printf("ボタンのタグ %d : %d\n", i, [self.navigationController.navigationBar.items objectAtIndex].tag);
//    }
    //self.navigationItem.rightBarButtonItem = item3;
    
    
    printf("end of viewcontroller\n");
//    printf("_playHeadの位置 %f", _playHead.frame.origin.x);
    
}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    // Do any additional setup after loading the view from its nib.
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    printf("Memory Worning!!!\n");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

/*
 この移譲メソッドでズーム対象のUIViewを返す事で、UIScrollViewはピンチジェスチャーに対応してくれる。
 ただし、setMinimumZoomScaleかsetMaximumZoomScaleで1.0以外を指定していないと意味が無い。
 */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    UIView *view = nil;
    if (scrollView == scrollview) {
        view = testview;
    }
    return view;
}

- (void)scrollViewDidEndZooming:(UIScrollView*)scrollView
                       withView:(UIView*)view atScale:(float)scale
{
    testview.zoomscale = [scrollView zoomScale];
    [_dragDropManager setZoomScale:testview.zoomscale];
    //printf("ズーム率 %f\n", testview.zoomscale);
    //[scrollView setZoomScale:1.0 animated:YES];//このメソッドここだと使える
}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

-(void)zoomScaleButtonDidPushed{
    //_zoomscale = 1.0;
    [self->scrollview setZoomScale:1.0 animated:YES];//ここだとこんな書き方になるようだ
}

-(void)metroButtonDidPushed{
    _dragDropManager.isMetroON = !_dragDropManager.isMetroON;
    if (_dragDropManager.isMetroON) {
        
        UIImage* metroimage = [UIImage imageNamed:@"bell2.png"];
        UIButton *metrobuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, metroimage.size.width, metroimage.size.height)];
        [metrobuttonimage setBackgroundImage:metroimage forState:UIControlStateNormal];
        metrobuttonimage.showsTouchWhenHighlighted = YES;
        [metrobuttonimage addTarget:self action:@selector(metroButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        _metrobutton = [[UIBarButtonItem alloc] initWithCustomView:metrobuttonimage];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
//        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:settingbutton, zoomScalebutton, metrobutton, space, pausebutton, nil];
        
    }else if (!_dragDropManager.isMetroON){
        UIImage* metroimage = [UIImage imageNamed:@"bell.png"];
        UIButton *metrobuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, metroimage.size.width, metroimage.size.height)];
        [metrobuttonimage setBackgroundImage:metroimage forState:UIControlStateNormal];
        metrobuttonimage.showsTouchWhenHighlighted = YES;
        [metrobuttonimage addTarget:self action:@selector(metroButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        _metrobutton = [[UIBarButtonItem alloc] initWithCustomView:metrobuttonimage];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
        
    }
}

-(void)loopButtonDidPushed{
    _dragDropManager.isLoopOn = !_dragDropManager.isLoopOn;
    if (_dragDropManager.isLoopOn) {
        
        UIImage* loopimage = [UIImage imageNamed:@"loop2.png"];
        UIButton *loopbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, loopimage.size.width, loopimage.size.height)];
        [loopbuttonimage setBackgroundImage:loopimage forState:UIControlStateNormal];
        loopbuttonimage.showsTouchWhenHighlighted = YES;
        [loopbuttonimage addTarget:self action:@selector(loopButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        _loopbutton = [[UIBarButtonItem alloc] initWithCustomView:loopbuttonimage];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
        //        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:settingbutton, zoomScalebutton, metrobutton, space, pausebutton, nil];
        
    }else if (!_dragDropManager.isLoopOn){
        UIImage* loopimage = [UIImage imageNamed:@"loop1.png"];
        UIButton *loopbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, loopimage.size.width, loopimage.size.height)];
        [loopbuttonimage setBackgroundImage:loopimage forState:UIControlStateNormal];
        loopbuttonimage.showsTouchWhenHighlighted = YES;
        [loopbuttonimage addTarget:self action:@selector(loopButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        _loopbutton = [[UIBarButtonItem alloc] initWithCustomView:loopbuttonimage];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
        
        
    }
}

-(void)scrollButtonDidPushed{
    _dragDropManager.isScrollOn = !_dragDropManager.isScrollOn;
    if (_dragDropManager.isScrollOn) {
        
        UIImage* scrollimage = [UIImage imageNamed:@"scroll1.png"];
        UIButton *scrollbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, scrollimage.size.width, scrollimage.size.height)];
        [scrollbuttonimage setBackgroundImage:scrollimage forState:UIControlStateNormal];
        scrollbuttonimage.showsTouchWhenHighlighted = YES;
        [scrollbuttonimage addTarget:self action:@selector(scrollButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        _scrollbutton = [[UIBarButtonItem alloc] initWithCustomView:scrollbuttonimage];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
        //        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:settingbutton, zoomScalebutton, metrobutton, space, pausebutton, nil];
        
    }else if (!_dragDropManager.isScrollOn){
        UIImage* scrollimage = [UIImage imageNamed:@"scroll2.png"];
        UIButton *scrollbuttonimage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, scrollimage.size.width, scrollimage.size.height)];
        [scrollbuttonimage setBackgroundImage:scrollimage forState:UIControlStateNormal];
        scrollbuttonimage.showsTouchWhenHighlighted = YES;
        [scrollbuttonimage addTarget:self action:@selector(scrollButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        _scrollbutton = [[UIBarButtonItem alloc] initWithCustomView:scrollbuttonimage];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
        
        
    }
}

-(void)pauseButtonDidPushed{
    
    _dragDropManager.isPaused = !_dragDropManager.isPaused;
    //_dragDropManager.pausebuttonPushed = !_dragDropManager.pausebuttonPushed;
    if (_dragDropManager.isPaused) {
        UIButton *pausebuttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
        [pausebuttonView setImage:[UIImage imageNamed:@"pauseButton2.png"]
                         forState:UIControlStateNormal];
        pausebuttonView.showsTouchWhenHighlighted = YES;
        [pausebuttonView addTarget:self action:@selector(pauseButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        pausebuttonView.tag=3;
        _pausebutton = [[UIBarButtonItem alloc] initWithCustomView:pausebuttonView];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
        [_dragDropManager pauseButtonPressed];
    }else{
        UIButton *pausebuttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
        [pausebuttonView setImage:[UIImage imageNamed:@"pauseButton1.png"]
                         forState:UIControlStateNormal];
        pausebuttonView.showsTouchWhenHighlighted = YES;
        [pausebuttonView addTarget:self action:@selector(pauseButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
        pausebuttonView.tag=3;
        _pausebutton = [[UIBarButtonItem alloc] initWithCustomView:pausebuttonView];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
        [_dragDropManager pauseButtonPressed];
    }
    
    
}


-(void)playButtonDidPushed{
    _dragDropManager.isPlayed = !_dragDropManager.isPlayed;
    UIButton *pausebuttonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    [pausebuttonView setImage:[UIImage imageNamed:@"pauseButton1.png"]
                     forState:UIControlStateNormal];
    pausebuttonView.showsTouchWhenHighlighted = YES;
    [pausebuttonView addTarget:self action:@selector(pauseButtonDidPushed) forControlEvents:UIControlEventTouchUpInside];
    pausebuttonView.tag=3;
    _pausebutton = [[UIBarButtonItem alloc] initWithCustomView:pausebuttonView];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_settingbutton, _zoomScalebutton, _metrobutton, _loopbutton,_scrollbutton, _space, _pausebutton, nil];
    [_dragDropManager playButtonPressed];
}

-(void)saveButtonDidPushed{
    
    //_projectView = [[ProjectViewController alloc] initWithNibName:nil bundle:nil];
    _projectView = [[ProjectViewController alloc] initWithNibName:nil bundle:nil];
    _projectView.projectName = _projectName;
    _projectView.dragSubjects = _dragDropManager.dragSubjects;
    
    //タイトル設定
    _projectView.title = @"プロジェクト";
        _projectView.transitionNumber = 1;
    [self.navigationController pushViewController:_projectView animated:YES];
}

-(void)loadButtonDidPushed{
    
    _projectView = [[ProjectViewController alloc] initWithNibName:nil bundle:nil];
    
    _projectView.projectName = _projectName;
    _projectView.dragSubjects = _dragDropManager.dragSubjects;
    _projectView.dragdropmanager = _dragDropManager;
    //タイトル設定
    _projectView.title = @"プロジェクト";
    //ボタン生成
//    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithTitle:@"次ページ" style:UIBarButtonItemStyleBordered target:self
//                               action:@selector(thirdView:)];
//    //バーにボタンを設定
////    viewController.navigationItem.rightBarButtonItem = button;
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration: 0.5];  //フリップする時間
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    //画面を遷移
    _projectView.transitionNumber = 2;
    [self.navigationController pushViewController:_projectView animated:YES];
//    [UIView commitAnimations];
}

-(void)eraseButtonDidPushed{
    [_dragDropManager eraseAll];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _dragDropManager.didScrolled = YES;
}

- (void)endScroll {
    // TODO: スクロール後の処理を書く
    
}

-(void)drawHandle:(onoImageView*)drawedImage{
    drawedImage.handle1 = [[handleView alloc]initWithFrame:CGRectMake(drawedImage.bounds.origin.x, drawedImage.center.y + 2.5, 5.0, 5.0)];
    drawedImage.handle1.backgroundColor = [UIColor blueColor];
    [drawedImage addSubview:drawedImage.handle1];
    drawedImage.handle1.hidden = YES;
    
    drawedImage.handle2 = [[handleView alloc]initWithFrame:CGRectMake(drawedImage.center.y, drawedImage.bounds.origin.x -2.5,  5.0, 5.0)];
    drawedImage.handle2.backgroundColor = [UIColor blueColor];
    [drawedImage addSubview:drawedImage.handle2];
    drawedImage.handle2.hidden = YES;
    
    drawedImage.handle3 = [[handleView alloc]initWithFrame:CGRectMake(drawedImage.bounds.origin.x + drawedImage.frame.size.width -5, drawedImage.center.y + 2.5, 5.0, 5.0)];
    drawedImage.handle3.backgroundColor = [UIColor blueColor];
    [drawedImage addSubview:drawedImage.handle3];
    drawedImage.handle3.hidden = YES;
    
    drawedImage.handle4 = [[handleView alloc]initWithFrame:CGRectMake(drawedImage.center.y, drawedImage.bounds.origin.x +drawedImage.frame.size.height -5,  5.0, 5.0)];
    drawedImage.handle4.backgroundColor = [UIColor blueColor];
    [drawedImage addSubview:drawedImage.handle4];
    drawedImage.handle4.hidden = YES;

}
@end
