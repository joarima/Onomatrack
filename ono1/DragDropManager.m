//
//  Created by jve on 4/1/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DragDropManager.h"
#import "DragContext.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "handleView.h"


#define AUTOSCROLL_THRESHOLD 30

typedef ALvoid AL_APIENTRY (*alBufferDataStaticProcPtr) (const ALint bid, ALenum format, ALvoid* data, ALsizei size, ALsizei freq);
static alBufferDataStaticProcPtr alBufferDataStaticProc;

//OpenAL関連のコードはhttp://news.mynavi.jp/column/iphone/014/index.htmlより拝借
void* GetOpenALAudioData(
                         CFURLRef fileURL, ALsizei* dataSize, ALenum* dataFormat, ALsizei *sampleRate)
{
#pragma mark: Analyzeに文句言われたので70行目からここに移し，nilを代入．http://ameblo.jp/zuob/entry-11355177795.htmlより
    void*       data = nil;
    OSStatus    err;
    UInt32      size;
    
    // オーディオファイルを開く
    ExtAudioFileRef audioFile;
    err = ExtAudioFileOpenURL(fileURL, &audioFile);
    if (err) {
        goto Exit;
    }
    
    // オーディオデータフォーマットを取得する
    AudioStreamBasicDescription fileFormat;
    size = sizeof(fileFormat);
    err = ExtAudioFileGetProperty(
                                  audioFile, kExtAudioFileProperty_FileDataFormat, &size, &fileFormat);
    if (err) {
        goto Exit;
    }
    
    // アウトプットフォーマットを設定する
    AudioStreamBasicDescription outputFormat;
    outputFormat.mSampleRate = fileFormat.mSampleRate;
    outputFormat.mChannelsPerFrame = fileFormat.mChannelsPerFrame;
    outputFormat.mFormatID = kAudioFormatLinearPCM;
    outputFormat.mBytesPerPacket = 2 * outputFormat.mChannelsPerFrame;
    outputFormat.mFramesPerPacket = 1;
    outputFormat.mBytesPerFrame = 2 * outputFormat.mChannelsPerFrame;
    outputFormat.mBitsPerChannel = 16;
    outputFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
    err = ExtAudioFileSetProperty(
                                  audioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(outputFormat), &outputFormat);
    if (err) {
        goto Exit;
    }
    
    // フレーム数を取得する
    SInt64  fileLengthFrames = 0;
    size = sizeof(fileLengthFrames);
    err = ExtAudioFileGetProperty(
                                  audioFile, kExtAudioFileProperty_FileLengthFrames, &size, &fileLengthFrames);
    if (err) {
        goto Exit;
    }
    
    // バッファを用意する
    UInt32          bufferSize;
    //void*           data;
    AudioBufferList dataBuffer;
    bufferSize = fileLengthFrames * outputFormat.mBytesPerFrame;;
    data = malloc(bufferSize);
    dataBuffer.mNumberBuffers = 1;
    dataBuffer.mBuffers[0].mDataByteSize = bufferSize;
    dataBuffer.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
    dataBuffer.mBuffers[0].mData = data;
    
    // バッファにデータを読み込む
    err = ExtAudioFileRead(audioFile, (UInt32*)&fileLengthFrames, &dataBuffer);
    if (err) {
        free(data);
        goto Exit;
    }
    
    // 出力値を設定する
    *dataSize = (ALsizei)bufferSize;
    *dataFormat = (outputFormat.mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
    *sampleRate = (ALsizei)outputFormat.mSampleRate;
    
Exit:
    // オーディオファイルを破棄する
    if (audioFile) {
        ExtAudioFileDispose(audioFile);
    }
    
    return data;
    
}


@implementation DragDropManager{
    
    //NSMutableArray* _dragSubjects;
    NSMutableArray* _dropAreas;
    testView* testview;
//    CGPoint previousPoint;
//    CGPoint currentPoint;
    //    DragContext *_dragContext;
    
}

//@synthesize dragContext = _dragContext;
//@synthesize dropAreas = _dropAreas;


#pragma mark: 全体の初期化
- (id)initWithDragSubjects:(NSMutableArray *)dragSubjects andDropAreas:(NSMutableArray *)dropAreas andplayHead:(UIImageView *)playhead andscrollview:(UIScrollView *)scrollview{
    self = [super init];
    if (self) {
        _dropAreas = dropAreas;
        testview = dropAreas[0];
        _dragSubjects = dragSubjects;
        _dragContext = nil;
        _zoomscale = 1.0;
        _playHead = playhead;
        _isPlayed = NO;
        _isPaused = NO;
        //        timer = [NSTimer scheduledTimerWithTimeInterval:(1/60) target:self selector:@selector(tick:) userInfo:nil repeats:YES];
        //
        //        [timer invalidate];
        
        _iscollisioned = NO;
        _collisionedSubjects = [[NSMutableArray alloc]init];
        
        
        _addPlayHead = 35;
        _playHeadDragged = NO;
        _lastPlayed = nil;
        
        
        _tappedsubjecs = [[NSMutableArray alloc]init];
        
        _BarNum = 1;
        _Tempo = 120;
        
        //再生速度
        _playSpeed = 0.4/_Tempo;
        
        
        _scrollview = scrollview;
        
        //mainQueue = dispatch_get_main_queue();
        //globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        _playheadX = 49;
        
        //_scrollcontentoffset.x=0;
        //_scrollcontentoffset.y=0;
        //_addScroll = 0;
        
        //_playbutton = playbutton;
        //draggedViewWithHandle = nil;
        
        _isLongPressed = NO;
        _isCopyInReady = NO;
        _isPasteLabelAppear = NO;
        _playStartCount = 0;
        _isMetroON = NO;
        _isLoopOn = YES;
        _isScrollOn = YES;
        
        //_pausebuttonPushed = NO;
        
        
        //play開始時のクリック用
        NSString * path = [[NSBundle mainBundle] pathForResource:@"pi" ofType:@"caf"];
        NSURL * url = [NSURL fileURLWithPath:path];
        _click = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        //[_click prepareToPlay];
        _click.volume = 0.5;
        
        
        //OpenALの初期化もここでやっちゃう
        // OpneALデバイスを開く
        ALCdevice*  device;
        device = alcOpenDevice(NULL);
        
        // OpenALコンテキストを作成して、カレントにする
        ALCcontext* alContext;
        alContext = alcCreateContext(device, NULL);
        alcMakeContextCurrent(alContext);
        alBufferDataStaticProc = (alBufferDataStaticProcPtr)alcGetProcAddress(nil, (const ALCchar *)"alBufferDataStatic");
        
        
        // バッファとソースを作成する
        alGenBuffers(40/*83*/, _buffers);
        alGenSources(40/*83*/, _sources);
        
        int i;
        for (i = 0; i < 40/*83*/; i++) {
            // サウンドファイルパスを取得する
            NSString*   fileName = nil;
            NSString*   path;
            switch (i) {
                    
                case 0: fileName = @"ウィ"; break;
                case 1: fileName = @"カ"; break;
                case 2: fileName = @"カコ"; break;
                case 3: fileName = @"ガコ"; break;
                case 4: fileName = @"ガサ"; break;
                case 5: fileName = @"ガシ"; break;
                case 6: fileName = @"カタ"; break;
                case 7: fileName = @"カラカラ"; break;
                case 8: fileName = @"カン"; break;
                case 9: fileName = @"ギ"; break;
                case 10: fileName = @"キン"; break;
                case 11: fileName = @"コ"; break;
                case 12: fileName = @"シ"; break;
                case 13: fileName = @"ジ"; break;
                case 14: fileName = @"シャ"; break;
                case 15: fileName = @"シャーン"; break;
                case 16: fileName = @"シャキ"; break;
                case 17: fileName = @"シャン"; break;
                case 18: fileName = @"タン"; break;
                case 19: fileName = @"ダン"; break;
                case 20: fileName = @"チ"; break;
                case 21: fileName = @"チーン"; break;
                case 22: fileName = @"チキ"; break;
                case 23: fileName = @"チャリ"; break;
                case 24: fileName = @"チン"; break;
                case 25: fileName = @"ツ"; break;
                case 26: fileName = @"トン"; break;
                case 27: fileName = @"ドン"; break;
                case 28: fileName = @"パ"; break;
                case 29: fileName = @"パチ"; break;
                case 30: fileName = @"パン"; break;
                case 31: fileName = @"ピ"; break;
                case 32: fileName = @"ビリ"; break;
                case 33: fileName = @"ビロ"; break;
                case 34: fileName = @"プ"; break;
                case 35: fileName = @"ペン"; break;
                case 36: fileName = @"ポ"; break;
                case 37: fileName = @"ポー"; break;
                case 38: fileName = @"ボン"; break;
                case 39: fileName = @"ポン"; break;
                    
                    //                case 0: fileName = @"BDmono"; break;
                    //                case 1: fileName = @"SDmono"; break;
                    //                case 2: fileName = @"FTommono"; break;
                    //                case 3: fileName = @"MTommono"; break;
                    //                case 4: fileName = @"HTommono"; break;
                    //                case 5: fileName = @"HHmono"; break;
                    //                case 6: fileName = @"CCymmono"; break;
                    //                case 7: fileName = @"Ridemono"; break;
                    
            }
            path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"/*@"caf"*/];
            
            // オーディオデータを取得する
            void*   audioData;
            ALsizei dataSize = 0;
            ALenum  dataFormat = 0;
            ALsizei sampleRate = 0;
            audioData = GetOpenALAudioData(
                                           (__bridge CFURLRef)[NSURL fileURLWithPath:path], &dataSize, &dataFormat, &   sampleRate);
            
            // データをバッファに設定する
            //alBufferData(_buffers[i], dataFormat, audioData, dataSize, sampleRate);
            alBufferDataStaticProc(_buffers[i], dataFormat, audioData, dataSize, sampleRate);
            
            
            //free(audioData);
            
            // バッファをソースに設定する
            alSourcei(_sources[i], AL_BUFFER, _buffers[i]);
            
            float vec[6] = {0, 0, 1, 0, 1, 0};
            alListenerfv(AL_ORIENTATION, vec);
        }
        
    }
    
    return self;
}

#pragma mark:画面クリア用のアラート
-(void)eraseAll{
    UIAlertView *alert = [[UIAlertView alloc]
                          
                          initWithTitle:@"キャンバス上の全ての音を消去します!!!"
                          
                          message:@" "
                          
                          delegate:self
                          
                          cancelButtonTitle:@"Cancel"
                          
                          otherButtonTitles:@"OK", nil];
    
    
    // アラート表示
    [alert show];
    
}

#pragma mark:画面のクリア
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //  Cancelボタンが押されたとき
            //            printf("!!!erase!!! : Cancel button did pushed\n");
            //            printf("!!!erase!!! : OK button did pushed\n");
            //            for (int j=0; j<_dragSubjects.count; j++) {
            //                printf("%d:imageName : %s\n", j, [[[_dragSubjects objectAtIndex:j] imageName] UTF8String]);
            //                printf(" soundNumber : %d\n",[[_dragSubjects objectAtIndex:j] soundNumber]);
            //
            //            }
            
            break;
        case 1:
        {
            // OKボタンが押されたとき
            //            printf("!!!erase!!! : OK button did pushed\n");
            //            for (int j=0; j<_dragSubjects.count; j++) {
            //                printf("%d:imageName : %s\n", j, [[[_dragSubjects objectAtIndex:j] imageName] UTF8String]);
            //
            //            }
            
            for (int i=_dragSubjects.count-1; i>=40; i--) {
                [[[_dragSubjects objectAtIndex:i] handle1] removeFromSuperview];
                [[[_dragSubjects objectAtIndex:i] handle2] removeFromSuperview];
                [[[_dragSubjects objectAtIndex:i] handle3] removeFromSuperview];
                [[[_dragSubjects objectAtIndex:i] handle4] removeFromSuperview];
                [[_dragSubjects objectAtIndex: i] removeFromSuperview];
                
                [_dragSubjects removeLastObject];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark:プロジェクトのロード
-(void)loadProject:(NSString *)plistname{
    
    //    for (int j=0; j<_dragSubjects.count; j++) {
    //        printf("%d:imageName : %s\n", j, [[[_dragSubjects objectAtIndex:j] imageName] UTF8String]);
    //
    //    }
    
    //プロジェクトのロード時にも画面をクリアする
    for (int i=_dragSubjects.count-1; i>=40; i--) {
        [[[_dragSubjects objectAtIndex:i] handle1] removeFromSuperview];
        [[[_dragSubjects objectAtIndex:i] handle2] removeFromSuperview];
        [[[_dragSubjects objectAtIndex:i] handle3] removeFromSuperview];
        [[[_dragSubjects objectAtIndex:i] handle4] removeFromSuperview];
        [[_dragSubjects objectAtIndex: i] removeFromSuperview];
        
        [_dragSubjects removeLastObject];
    }
    
    NSString* str1 =[[NSString alloc]initWithString:plistname];
    NSString* str2 =@"data.plist";
    NSString* dragsubjectsData = [str1 stringByAppendingString:str2];
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:dragsubjectsData];
    
    NSMutableArray* tmparr = [NSMutableArray arrayWithContentsOfFile:filePath];
    //NSLog(@"%@", tmparr);
    
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
#pragma mark: Analyzeに言われて変更したとこ
        //NSMutableDictionary* tmpdic = [NSMutableDictionary dictionary];
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
        
        NSNumber *BarNum = [tmpdic objectForKey:@"BarNum"];
        _BarNum = [BarNum intValue];
        NSNumber *Tempo = [tmpdic objectForKey:@"Tempo"];
        _Tempo = [Tempo intValue];
        
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
    for (int i=0; i<namearr.count; i++) {
        //                printf("name : %s\n",[[namearr objectAtIndex:i] UTF8String]);
        //                printf("pan : %f\n",[[panarr objectAtIndex:i] floatValue]);
        //                printf("soundnum : %d\n",[[soundnumarr objectAtIndex:i] intValue]);
        //                printf("tag : %d\n",[[tagarr objectAtIndex:i] intValue]);
        //                printf("volume : %f\n",[[volumearr objectAtIndex:i] floatValue]);
        //                printf("x : %f\n",[[xarr objectAtIndex:i] floatValue]);
        //                printf("y : %f\n",[[yarr objectAtIndex:i] floatValue]);
        
        UIImage *image = [UIImage imageNamed:[namearr objectAtIndex:i]];
        onoImageView* newimage = [[onoImageView alloc]initWithImage:image];
        
        NSString* imagename =[namearr objectAtIndex:i];
        newimage.imageName = imagename;
        
        [newimage setFrame:CGRectMake([[xarr objectAtIndex:i] floatValue], [[yarr objectAtIndex:i] floatValue], [[widtharr objectAtIndex:i] floatValue], [[heightarr objectAtIndex:i] floatValue])];
        newimage.pan = [[panarr objectAtIndex:i] floatValue];
        newimage.soundNumber = [[soundnumarr objectAtIndex:i] intValue];
        newimage.tag = [[tagarr objectAtIndex:i] intValue];
        newimage.volume = [[volumearr objectAtIndex:i] floatValue];
        
        //        printf("name : %s\n",[newimage.imageName UTF8String]);
        //        printf("pan : %f\n",newimage.pan);
        //        printf("soundnum : %d\n",newimage.soundNumber);
        //        printf("tag : %d\n",newimage.tag);
        //        printf("volume : %f\n",newimage.volume);
        //        printf("x : %f\n",newimage.frame.origin.x);
        //        printf("y : %f\n",newimage.frame.origin.y);
        //        printf("width : %f\n",newimage.frame.size.width);
        //        printf("height : %f\n",newimage.frame.size.height);
        
        newimage.isInCanvas = YES;
        
        [_dragSubjects addObject:newimage];
        [_dropAreas[0] addSubview:newimage];
    }
    
    //    printf("BarNum : %d\n",_BarNum);
    //    printf("Tempo : %d\n",_Tempo);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.BarNum = _BarNum;
    appDelegate.Tempo = _Tempo;
    
}


- (void)setZoomScale:(float)scale{
    _zoomscale = scale;
    
    [_scrollview setContentSize:CGSizeMake(((_BarNum * 600) + 200)*_zoomscale, 768*_zoomscale)];
    //_scrollcontentoffset.x = (_scrollview.contentOffset.x / _zoomscale);
    //_scrollcontentoffset.y = (_scrollview.contentOffset.x / _zoomscale);
    
}

//- (void)dealloc {
//[_dragSubjects release];
//[_dragContext release];
//[_dropAreas release];
//[super dealloc];
//}

#pragma mark: ドラッグ中に呼ばれてるメソッド
- (void)dragObjectAccordingToGesture:(UIPanGestureRecognizer *)recognizer {
    if (self.dragContext) {
        
        //        CGPoint pointOnView = [recognizer locationInView:recognizer.view];
        //
        //                if(self.dragContext.draggedView.isInCanvas&&pointOnView.x < _scrollview.contentOffset.x + 750){
        //                    [self.dragContext.draggedView removeFromSuperview];
        //                    [recognizer.view addSubview:self.dragContext.draggedView];
        //
        //                    CGPoint movePoint;
        //                    movePoint.x =0;
        //                    movePoint.y =0;
        //
        //                    //CGPoint imagepoint = self.dragContext.draggedView.frame.origin;
        //
        ////                    CGPoint imagepoint = [recognizer.view convertPoint:self.dragContext.draggedView.frame.origin toView:recognizer.view.window];
        ////
        ////                    printf("%f\n",imagepoint.x);
        ////                    printf("%f\n\n",imagepoint.y);
        //
        //                    CGRect imageframe = [self.dragContext.draggedView frame];
        ////                    imageframe.origin = imagepoint;
        //                    if (_didScrolled) {
        //                        _didScrolled = NO;
        //                        imageframe.origin.x = imageframe.origin.x - _scrollview.contentOffset.x;
        //                        imageframe.origin.y = imageframe.origin.y - _scrollview.contentOffset.y;
        //                    }
        //
        //
        //        //            pointOnView.x = (int)pointOnView.x;
        //        //            pointOnView.y = (int)pointOnView.y;
        //                    if (self.dragContext.lastpoint.x != 0 && self.dragContext.lastpoint.y != 0) {
        //                        //[recognizer.view convertPoint:self.dragContext.lastpoint fromView:_dropAreas[0]];
        //                        movePoint.x = pointOnView.x - self.dragContext.lastpoint.x;
        //                        movePoint.y = pointOnView.y - self.dragContext.lastpoint.y;
        //                    }
        //
        //                    printf("pointOnView.x : %f\n",pointOnView.x);
        //                    printf("pointOnView.y : %f\n",pointOnView.y);
        //                    printf("self.dragContext.lastpoint.x : %f\n",self.dragContext.lastpoint.x);
        //                    printf("self.dragContext.lastpoint.y : %f\n",self.dragContext.lastpoint.y);
        //                    printf("movePoint.x : %f\n",movePoint.x);
        //                    printf("movePoint.y : %f\n",movePoint.y);
        //                    printf("imageframe.x : %f\n",imageframe.origin.x);
        //                    printf("imageframe.y : %f\n",imageframe.origin.y);
        //                    printf("self.dragContext.draggedView.x : %f\n",self.dragContext.draggedView.frame.origin.x);
        //                    printf("self.dragContext.draggedView.y : %f\n",self.dragContext.draggedView.frame.origin.y);
        //
        //                    self.dragContext.lastpoint = pointOnView;
        //
        //
        //                    if (movePoint.x != 0 || movePoint.y != 0) {
        //                        imageframe.origin.x += movePoint.x;
        //                        imageframe.origin.y += movePoint.y;
        //
        //                        //[recognizer.view convertPoint:imageframe.origin toView:_dropAreas[0]];
        //
        //                        printf("imageframe.x : %f\n",imageframe.origin.x);
        //                        printf("imageframe.y : %f\n\n",imageframe.origin.y);
        //
        //                        [self.dragContext.draggedView setFrame:imageframe];
        //
        //                    }
        //
        //
        //
        //                    //self.dragContext.draggedView.center = pointOnView;
        //            }else if(!self.dragContext.draggedView.isInCanvas&&pointOnView.x > _scrollview.contentOffset.x + 750){
        
        
        
        CGPoint pointOnView = [recognizer locationInView:recognizer.view];
        pointOnView.x = (int)pointOnView.x;
        pointOnView.y = (int)pointOnView.y;
        self.dragContext.draggedView.center = pointOnView;
        
#pragma mark: ドラッグ機能を改善しようとしたところ
//        CGPoint originalPoint = self.dragContext.draggedView.center;
//        CGPoint pointOnView = [recognizer translationInView:_scrollview.window];
////        CGPoint scrollviewOffset = _scrollview.contentOffset;
//        pointOnView.x = (int)pointOnView.x;
//        pointOnView.y = (int)pointOnView.y;
//        originalPoint.x = originalPoint.x - pointOnView.y;
//        originalPoint.y = originalPoint.y + pointOnView.x;
//        self.dragContext.draggedView.center = originalPoint;
        
        [recognizer setTranslation:CGPointZero inView:_scrollview.window];
        
        if (self.dragContext.draggedView.isInCanvas && self.dragContext.draggedView.isTapped) {
            [self.dragContext.draggedView.handle1 removeFromSuperview];
            [self.dragContext.draggedView.handle2 removeFromSuperview];
            [self.dragContext.draggedView.handle3 removeFromSuperview];
            [self.dragContext.draggedView.handle4 removeFromSuperview];
            
            self.dragContext.draggedView.handle1 = [[handleView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.frame.origin.x - 40, self.dragContext.draggedView.frame.origin.y + self.dragContext.draggedView.frame.size.height/2 - 50, 40.0, 100.0)];
            //    draggedview.handle1.backgroundColor = [UIColor blackColor];
            self.dragContext.draggedView.handle1.opaque = NO;
            self.dragContext.draggedView.handle1.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
            self.dragContext.draggedView.handle1.handlename = @"left";
            [recognizer.view addSubview:self.dragContext.draggedView.handle1];
            self.dragContext.draggedView.handle1.hidden = NO;
            UIImageView* fakehandle1 = [[UIImageView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.handle1.bounds.origin.x + 25, self.dragContext.draggedView.handle1.bounds.origin.y + 47.5, 5.0, 5.0)];
            fakehandle1.backgroundColor = [UIColor redColor];
            [self.dragContext.draggedView.handle1 addSubview:fakehandle1];
            
            self.dragContext.draggedView.handle2 = [[handleView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.frame.origin.x + self.dragContext.draggedView.frame.size.width/2 - 50, self.dragContext.draggedView.frame.origin.y - 40,  100.0, 40.0)];
            //    draggedview.handle2.backgroundColor = [UIColor blackColor];
            self.dragContext.draggedView.handle2.opaque = NO;
            self.dragContext.draggedView.handle2.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
            self.dragContext.draggedView.handle2.handlename = @"top";
            [recognizer.view addSubview:self.dragContext.draggedView.handle2];
            self.dragContext.draggedView.handle2.hidden = NO;
            UIImageView* fakehandle2 = [[UIImageView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.handle2.bounds.origin.x + 47.5, self.dragContext.draggedView.handle2.bounds.origin.y + 25, 5.0, 5.0)];
            fakehandle2.backgroundColor = [UIColor redColor];
            [self.dragContext.draggedView.handle2 addSubview:fakehandle2];
            
            self.dragContext.draggedView.handle3 = [[handleView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.frame.origin.x + self.dragContext.draggedView.frame.size.width, self.dragContext.draggedView.frame.origin.y + self.dragContext.draggedView.frame.size.height/2 - 50, 40.0, 100.0)];
            //    draggedview.handle3.backgroundColor = [UIColor blackColor];
            self.dragContext.draggedView.handle3.opaque = NO;
            self.dragContext.draggedView.handle3.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
            self.dragContext.draggedView.handle3.handlename = @"right";
            [recognizer.view addSubview:self.dragContext.draggedView.handle3];
            self.dragContext.draggedView.handle3.hidden = NO;
            UIImageView* fakehandle3 = [[UIImageView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.handle3.bounds.origin.x + 10, self.dragContext.draggedView.handle3.bounds.origin.y + 47.5, 5.0, 5.0)];
            fakehandle3.backgroundColor = [UIColor redColor];
            [self.dragContext.draggedView.handle3 addSubview:fakehandle3];
            
            self.dragContext.draggedView.handle4 = [[handleView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.frame.origin.x + self.dragContext.draggedView.frame.size.width/2 - 50, self.dragContext.draggedView.frame.origin.y + self.dragContext.draggedView.frame.size.height,  100.0, 40.0)];
            //    draggedview.handle4.backgroundColor = [UIColor blackColor];
            self.dragContext.draggedView.handle4.opaque = NO;
            self.dragContext.draggedView.handle4.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
            self.dragContext.draggedView.handle4.handlename = @"bottom";
            [recognizer.view addSubview:self.dragContext.draggedView.handle4];
            self.dragContext.draggedView.handle4.hidden = NO;
            UIImageView* fakehandle4 = [[UIImageView alloc]initWithFrame:CGRectMake(self.dragContext.draggedView.handle4.bounds.origin.x + 47.5, self.dragContext.draggedView.handle4.bounds.origin.y + 10, 5.0, 5.0)];
            fakehandle4.backgroundColor = [UIColor redColor];
            [self.dragContext.draggedView.handle4 addSubview:fakehandle4];
            //}
            
            
        }
        
        
        //printf("timerの状態：%d\n",timerForAutoScroll.isValid);
        //printf("%f\n",_scrollview.contentOffset.x);
        
        if (self.dragContext.draggedView.isInCanvas) {
            [self maybeAutoscroll:self.dragContext.draggedView];
        }
        //        if (_zoomscale > 1.0) {
        //            [self maybeAutoscrollVirtical:self.dragContext.draggedView];
        //        }
        
        
        
    }
//    [recognizer.view setNeedsDisplay];

}

- (float)autoscrollDistanceForProximityToEdge:(float)proximity {
    return ceilf((AUTOSCROLL_THRESHOLD - proximity) / 5.0);
}
- (void)maybeAutoscroll:(onoImageView *)image{
    _autoscrollDistance = 0;
    
    
    CGPoint touchLocation = image.center;//[image convertPoint:image.center toView:_scrollview];	//thumbScrollView上でのthumbのドラッグ開始位置を計算
    //	thumbのドラッグ開始位置と両端との距離をそれぞれ求める。
    
    //printf("touchlocation : %f\n",touchLocation.x);
    float distanceFromLeftEdge  = touchLocation.x -  _scrollview.window.frame.origin.x;//CGRectGetMinX([_scrollview bounds]);
    float distanceFromRightEdge = /*CGRectGetMaxX([_scrollview bounds])*/ _scrollview.window.frame.origin.x + 768 - touchLocation.x;
    
    //printf("distanceFromLeftEdge : %f\n",distanceFromLeftEdge);
    //        printf("distanceFromRightEdge : %f\n",distanceFromRightEdge);
    
    if (distanceFromLeftEdge < AUTOSCROLL_THRESHOLD) {
        //	タッチ位置が左から右にスクロールを必要とする位置。
        //            printf("distanceFromLeftEdge : %f\n",distanceFromLeftEdge);
        _autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromLeftEdge] * -1;	//	負の方向なので -1 をかける。
    } else if (distanceFromRightEdge < AUTOSCROLL_THRESHOLD) {
        //	タッチ位置が右から左にスクロールを必要とする位置。
        _autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromRightEdge];
    }
    
    //        printf("autoscrollDistance : %f\n",_autoscrollDistance);
    //        printf("ズーム率 : %f\n",_zoomscale);
    
    if (_autoscrollDistance == 0 ) {
		//	0ということはスクロールが必要ではない。
        [timerForAutoScroll invalidate];			//	タイマーを止める。
        timerForAutoScroll = nil;
    } else if (timerForAutoScroll == nil) {
		//	そうでなければオートスクロールさせる。ただし、autoscrollTimerがnilでないなら、すでにオートスクロール中なのでなにもしなくていい。
        timerForAutoScroll = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                              target:self
                                                            selector:@selector(autoScroll:)
                                                            userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerForAutoScroll forMode:NSRunLoopCommonModes];
        
    }
    if (image.center.x >= 768) {
        [timerForAutoScroll invalidate];			//	キャンバスの一番右が見えたらタイマーを止める。
        timerForAutoScroll = nil;
    }
}
-(void)autoScroll:(NSTimer *)timerforautoscroll{
    
    CGPoint scrollviewOffset = _scrollview.contentOffset;
    //    scrollviewOffset.x += _addScroll;
    
    //printf("%f\n",_scrollview.contentOffset.x);
    
    scrollviewOffset.x += _autoscrollDistance;
    //_scrollview.contentOffset = scrollviewOffset;
    
    if (_scrollview.contentOffset.x >= 0 && _scrollview.contentOffset.x <= ((600 * _BarNum) + 150 - 768)*_zoomscale) {
        _scrollview.contentOffset = scrollviewOffset;
        if (_scrollview.contentOffset.x <= -1) {
            scrollviewOffset.x = 0;
            _scrollview.contentOffset = scrollviewOffset;
        }
        if(_scrollview.contentOffset.x >= ((600 * _BarNum) - 568)*_zoomscale){
            scrollviewOffset.x = (600 * _BarNum) - 569;
            _scrollview.contentOffset = scrollviewOffset;
        }
        
    }
    
    
    
    
}
//- (void)maybeAutoscrollVirtical:(onoImageView *)image{
//    _autoscrollDistanceVirtical = 0;
//
//    //	thumbのframeはthumbScrollViewのboundsと接触（内部にある場合も含む）している。
//
//    CGPoint touchLocation = image.center;//[image convertPoint:image.center toView:_scrollview];	//thumbScrollView上でのthumbのドラッグ開始位置を計算
//    //	thumbのドラッグ開始位置と両端との距離をそれぞれ求める。
//
//    //printf("touchlocation : %f\n",touchLocation.x);
//    float distanceFromTopEdge  = touchLocation.y -  _scrollview.window.frame.origin.y;//CGRectGetMinX([_scrollview bounds]);
//    float distanceFromBottomEdge = /*CGRectGetMaxX([_scrollview bounds])*/ _scrollview.window.frame.origin.y + 768 - touchLocation.y;
//
//    printf("distanceFromTopEdge : %f\n",distanceFromTopEdge);
//    printf("distanceFromBottomEdge : %f\n",distanceFromBottomEdge);
//    printf("_scrollview.contentOffset : %f\n",_scrollview.contentOffset.y);
//    printf("ズーム率 : %f\n",_zoomscale);
//    if (distanceFromTopEdge < AUTOSCROLL_THRESHOLD) {
//        //	タッチ位置が左から右にスクロールを必要とする位置。
//        _autoscrollDistanceVirtical = [self autoscrollDistanceForProximityToEdge:distanceFromTopEdge] * -1;	//	負の方向なので -1 をかける。
//    } else if (distanceFromBottomEdge < AUTOSCROLL_THRESHOLD + 50) {
//        //	タッチ位置が右から左にスクロールを必要とする位置。
//        _autoscrollDistanceVirtical = [self autoscrollDistanceForProximityToEdgeMod:distanceFromBottomEdge];
//    }
//
//    printf("autoscrollDistanceVirtical : %f\n",_autoscrollDistanceVirtical);
//    printf("%f\n",(_scrollview.contentOffset.y / _zoomscale));
//    printf("timerForAutoScrollの状態 : %d\n",timerForAutoScroll.isValid);
//    if (_autoscrollDistanceVirtical == 0) {
//		//	0ということはスクロールが必要ではない。
//        [timerForAutoScrollVirtical invalidate];			//	タイマーを止める。
//        timerForAutoScrollVirtical = nil;
//    } else if (timerForAutoScroll == nil) {
//		//	そうでなければオートスクロールさせる。ただし、autoscrollTimerがnilでないなら、すでにオートスクロール中なのでなにもしなくていい。
//        timerForAutoScrollVirtical = [NSTimer scheduledTimerWithTimeInterval:1/60
//                                                              target:self
//                                                            selector:@selector(autoScrollVirtical:)
//                                                            userInfo:nil repeats:YES];
//    }
//}
//
//- (float)autoscrollDistanceForProximityToEdgeMod:(float)proximity {
//    return ceilf((AUTOSCROLL_THRESHOLD + 50 - proximity) / 5.0);
//}
//
//-(void)autoScrollVirtical:(NSTimer *)timerforautoscroll{
//
//    CGPoint scrollviewOffset = _scrollview.contentOffset;
//    //    scrollviewOffset.x += _addScroll;
//
//    //printf("%f\n",_scrollview.contentOffset.x);
//
//    scrollviewOffset.y += _autoscrollDistanceVirtical;
//    //_scrollview.contentOffset = scrollviewOffset;
//
//    if (_scrollview.contentOffset.y >= 0 && (_scrollview.contentOffset.y / _zoomscale) <= 593) {
//        _scrollview.contentOffset = scrollviewOffset;
//        if (_scrollview.contentOffset.y <= -1) {
//            scrollviewOffset.y = 0;
//            _scrollview.contentOffset = scrollviewOffset;
//        }
////        if((_scrollview.contentOffset.y / _zoomscale) <= 693){
////            scrollviewOffset.y = (600 * _BarNum) - 569;
////            _scrollview.contentOffset = scrollviewOffset;
////        }
//
//    }
//
//
//
//
//}

//ハンドル動かしたときに呼ばれるメソッド

- (void)dragHandleAccordingToGesture:(UIPanGestureRecognizer *)recognizer{
    if (self.dragContext) {
        if (self.dragContext.isHandleDragged && [self.dragContext.draggedhandle.handlename isEqual: @"left"]) {
            int moveDistance = 0;
            CGPoint pointOnView = [recognizer locationInView:_dropAreas[0]];
            CGRect frame = [self.dragContext.draggedhandle frame];
            CGRect imageframe = [self.dragContext.imageWithHandle frame];
            //printf("x : %f, y : %f\n", self.dragContext.draggedhandle.frame.origin.x, self.dragContext.draggedhandle.frame.origin.y);
            frame.origin.x = pointOnView.x;
            frame.origin.y = self.dragContext.draggedhandle.frame.origin.y;
            
            //printf("dragContext.lastHandleFrameX : %d\n", self.dragContext.lastHandleFrameX);
            
            if (self.dragContext.lastHandleFrameX != 0) {
                int last = self.dragContext.lastHandleFrameX;
                moveDistance = self.dragContext.draggedhandle.frame.origin.x - last;
                //printf("movedistance : %d\n", moveDistance);
            }
            self.dragContext.lastHandleFrameX = self.dragContext.draggedhandle.frame.origin.x;
            
            [self.dragContext.draggedhandle setFrame:frame];
            
            imageframe.size.width -= moveDistance;
            imageframe.origin.x = self.dragContext.draggedhandle.frame.origin.x + 40;
            imageframe.origin.x = (int)imageframe.origin.x;
            [self.dragContext.imageWithHandle setFrame:imageframe];
            //topとbottomのハンドルの位置も変更
            CGPoint tophandlecenter = CGPointMake(self.dragContext.imageWithHandle.center.x, self.dragContext.imageWithHandle.handle2.center.y);
            CGPoint bottomhandlecenter = CGPointMake(self.dragContext.imageWithHandle.center.x, self.dragContext.imageWithHandle.handle4.center.y);
            //rightのハンドルも位置を固定してやる
            CGPoint righthandlecenter = CGPointMake(self.dragContext.imageWithHandle.frame.origin.x + self.dragContext.imageWithHandle.frame.size.width + 25, self.dragContext.imageWithHandle.handle3.center.y);
            
            //CGPoint lefthandlecenter = CGPointMake(self.dragContext.imageWithHandle.frame.origin.x - 25, self.dragContext.imageWithHandle.handle1.center.y);
            
            
            self.dragContext.imageWithHandle.handle2.center = tophandlecenter;
            self.dragContext.imageWithHandle.handle4.center = bottomhandlecenter;
            
            self.dragContext.imageWithHandle.handle3.center = righthandlecenter;
            //self.dragContext.imageWithHandle.handle1.center = lefthandlecenter;
        }if (self.dragContext.isHandleDragged && [self.dragContext.draggedhandle.handlename isEqual: @"right"]) {
            int moveDistance = 0;
            CGPoint pointOnView = [recognizer locationInView:_dropAreas[0]];
            CGRect frame = [self.dragContext.draggedhandle frame];
            CGRect imageframe = [self.dragContext.imageWithHandle frame];
            //printf("x : %f, y : %f\n", self.dragContext.draggedhandle.frame.origin.x, self.dragContext.draggedhandle.frame.origin.y);
            frame.origin.x = pointOnView.x;
            frame.origin.y = self.dragContext.draggedhandle.frame.origin.y;
            
            //printf("dragContext.lastHandleFrameX : %d\n", self.dragContext.lastHandleFrameX);
            
            if (self.dragContext.lastHandleFrameX != 0) {
                int last = self.dragContext.lastHandleFrameX;
                moveDistance = self.dragContext.draggedhandle.frame.origin.x - last;
                //printf("movedistance : %d\n", moveDistance);
            }
            self.dragContext.lastHandleFrameX = self.dragContext.draggedhandle.frame.origin.x;
            
            [self.dragContext.draggedhandle setFrame:frame];
            
            imageframe.size.width += moveDistance;
            imageframe.origin.x = (int)imageframe.origin.x;
            [self.dragContext.imageWithHandle setFrame:imageframe];
            //topとbottomのハンドルの位置も変更
            CGPoint tophandlecenter = CGPointMake(self.dragContext.imageWithHandle.center.x, self.dragContext.imageWithHandle.handle2.center.y);
            CGPoint bottomhandlecenter = CGPointMake(self.dragContext.imageWithHandle.center.x, self.dragContext.imageWithHandle.handle4.center.y);
            
            CGPoint lefthandlecenter = CGPointMake(self.dragContext.imageWithHandle.frame.origin.x - 25, self.dragContext.imageWithHandle.handle1.center.y);
            //CGPoint righthandlecenter = CGPointMake(self.dragContext.imageWithHandle.frame.origin.x + self.dragContext.imageWithHandle.frame.size.width /*+ 25*/, self.dragContext.imageWithHandle.handle3.center.y);
            
            self.dragContext.imageWithHandle.handle2.center = tophandlecenter;
            self.dragContext.imageWithHandle.handle4.center = bottomhandlecenter;
            
            self.dragContext.imageWithHandle.handle1.center = lefthandlecenter;
            
            //            if (self.dragContext.imageWithHandle.frame.size.width <= 1.0) {
            //                CGPoint righthandlecenter = CGPointMake(self.dragContext.imageWithHandle.frame.origin.x + self.dragContext.imageWithHandle.frame.size.width + 25, self.dragContext.imageWithHandle.handle3.center.y);
            //                self.dragContext.imageWithHandle.handle3.center = righthandlecenter;
            //            }
            //self.dragContext.imageWithHandle.handle3.center = righthandlecenter;
            
            //printf("framewidth : %f\n", self.dragContext.imageWithHandle.frame.size.width);
            //TODO: 上下のハンドルを動かした場合，オブジェクトの中心を固定してやった方がいい気がする．ここから
#pragma mark -
        }else if(self.dragContext.isHandleDragged && [self.dragContext.draggedhandle.handlename isEqual: @"top"]){
            int moveDistance = 0;
            CGPoint pointOnView = [recognizer locationInView:_dropAreas[0]];
            CGRect frame = [self.dragContext.draggedhandle frame];
            CGRect imageframe = [self.dragContext.imageWithHandle frame];
            //printf("x : %f, y : %f\n", self.dragContext.draggedhandle.frame.origin.x, self.dragContext.draggedhandle.frame.origin.y);
            frame.origin.y = pointOnView.y;
            frame.origin.x = self.dragContext.draggedhandle.frame.origin.x;
            
            if (self.dragContext.lastHandleFrameY != 0) {
                int last = self.dragContext.lastHandleFrameY;
                moveDistance = self.dragContext.draggedhandle.frame.origin.y - last;
                //printf("movedistance : %d\n", moveDistance);
            }
            self.dragContext.lastHandleFrameY = self.dragContext.draggedhandle.frame.origin.y;
            
            [self.dragContext.draggedhandle setFrame:frame];
            
            imageframe.size.height -= moveDistance;
            imageframe.origin.y = self.dragContext.draggedhandle.frame.origin.y + 40;
            [self.dragContext.imageWithHandle setFrame:imageframe];
            //leftとrightのハンドルの位置も変更
            CGPoint lefthandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle1.center.x, self.dragContext.imageWithHandle.center.y);
            CGPoint righthandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle3.center.x, self.dragContext.imageWithHandle.center.y);
            
            CGPoint bottomhandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle4.center.x, self.dragContext.imageWithHandle.frame.origin.y + self.dragContext.imageWithHandle.frame.size.height +25);
            //CGPoint tophandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle2.center.x, self.dragContext.imageWithHandle.frame.origin.y - 25);
            
            self.dragContext.imageWithHandle.handle1.center = lefthandlecenter;
            self.dragContext.imageWithHandle.handle3.center = righthandlecenter;
            
            self.dragContext.imageWithHandle.handle4.center = bottomhandlecenter;
            //self.dragContext.imageWithHandle.handle2.center = tophandlecenter;
        }else if(self.dragContext.isHandleDragged && [self.dragContext.draggedhandle.handlename isEqual: @"bottom"]){
            int moveDistance = 0;
            CGPoint pointOnView = [recognizer locationInView:_dropAreas[0]];
            CGRect frame = [self.dragContext.draggedhandle frame];
            CGRect imageframe = [self.dragContext.imageWithHandle frame];
            //printf("x : %f, y : %f\n", self.dragContext.draggedhandle.frame.origin.x, self.dragContext.draggedhandle.frame.origin.y);
            frame.origin.y = pointOnView.y;
            frame.origin.x = self.dragContext.draggedhandle.frame.origin.x;
            
            if (self.dragContext.lastHandleFrameY != 0) {
                int last = self.dragContext.lastHandleFrameY;
                moveDistance = self.dragContext.draggedhandle.frame.origin.y - last;
                //printf("movedistance : %d\n", moveDistance);
            }
            self.dragContext.lastHandleFrameY = self.dragContext.draggedhandle.frame.origin.y;
            
            [self.dragContext.draggedhandle setFrame:frame];
            
            imageframe.size.height += moveDistance;
            //imageframe.origin.y = self.dragContext.draggedhandle.frame.origin.y + 40;
            [self.dragContext.imageWithHandle setFrame:imageframe];
            //leftとrightのハンドルの位置も変更
            CGPoint lefthandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle1.center.x, self.dragContext.imageWithHandle.center.y);
            CGPoint righthandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle3.center.x, self.dragContext.imageWithHandle.center.y);
            
            CGPoint tophandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle2.center.x, self.dragContext.imageWithHandle.frame.origin.y - 25);
            //CGPoint bottomhandlecenter = CGPointMake(self.dragContext.imageWithHandle.handle4.center.x, self.dragContext.imageWithHandle.frame.origin.y + self.dragContext.imageWithHandle.frame.size.height +25);
            
            self.dragContext.imageWithHandle.handle1.center = lefthandlecenter;
            self.dragContext.imageWithHandle.handle3.center = righthandlecenter;
            
            self.dragContext.imageWithHandle.handle2.center = tophandlecenter;
            //self.dragContext.imageWithHandle.handle4.center = bottomhandlecenter;
#pragma mark -
            //TODO: ここまで
        }
    }
}
//playHead動かしたときに呼ばれるメソッド
- (void)playHeadAccordingToGesture:(UIPanGestureRecognizer *)recognizer {
    if (self.dragContext) {
        
        CGPoint pointOnView = [recognizer locationInView:recognizer.view];
        CGRect playHeadFrame = [self.dragContext.playHead frame];
        playHeadFrame.origin.x = pointOnView.x - 15;
        playHeadFrame.origin.y = 0;
        
        if (pointOnView.x < 769) {
            [self.dragContext.playHead setFrame:playHeadFrame];
            [self maybeAutoscrollPlayhead:self.dragContext.playHead];
        }
        
        
        //printf("timerの状態：%d\n",timerForAutoScroll.isValid);
        
        
        
    }
}

- (void)maybeAutoscrollPlayhead:(UIImageView *)playhead{
    _autoscrollDistance = 0;
    
    
    CGPoint touchLocation = playhead.center;//[image convertPoint:image.center toView:_scrollview];	//thumbScrollView上でのthumbのドラッグ開始位置を計算
    //	thumbのドラッグ開始位置と両端との距離をそれぞれ求める。
    
    //[_dropAreas[0] convertPoint:touchLocation toView:_scrollview.superview.superview];
    //printf("touchLocation.x : %f\n",touchLocation.x);
    //printf("touchlocation : %f\n",touchLocation.x);
    float distanceFromLeftEdge  = touchLocation.x -  _scrollview.window.frame.origin.x;//CGRectGetMinX([_scrollview bounds]);
    float distanceFromRightEdge = /*CGRectGetMaxX([_scrollview bounds])*/ _scrollview.window.frame.origin.x + 768 - touchLocation.x;
    
    //printf("_scrollview.window.frame.origin.x : %f\n",_scrollview.window.frame.origin.x);
    //printf("distanceFromLeftEdge : %f\n",distanceFromLeftEdge);
    //printf("distanceFromRightEdge : %f\n",distanceFromRightEdge);
    
    if (distanceFromLeftEdge < AUTOSCROLL_THRESHOLD) {
        //	タッチ位置が左から右にスクロールを必要とする位置。
        //            printf("distanceFromLeftEdge : %f\n",distanceFromLeftEdge);
        _autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromLeftEdge] * -1;	//	負の方向なので -1 をかける。
    } else if (distanceFromRightEdge < AUTOSCROLL_THRESHOLD) {
        //	タッチ位置が右から左にスクロールを必要とする位置。
        _autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceFromRightEdge];
    }
    
    //printf("autoscrollDistance : %f\n",_autoscrollDistance);
    //        printf("ズーム率 : %f\n",_zoomscale);
    if (_autoscrollDistance == 0/* || distanceFromLeftEdge <= 0.0 || distanceFromRightEdge <= 0.0*/) {
		//	0ということはスクロールが必要ではない。
        [timerForAutoScroll invalidate];			//	タイマーを止める。
        timerForAutoScroll = nil;
    } else if (timerForAutoScroll == nil/*  && (distanceFromLeftEdge > 1.0 || distanceFromRightEdge > 1.0)*/) {
		//	そうでなければオートスクロールさせる。ただし、autoscrollTimerがnilでないなら、すでにオートスクロール中なのでなにもしなくていい。
        timerForAutoScroll = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                              target:self
                                                            selector:@selector(autoScroll:)
                                                            userInfo:nil repeats:YES];
    }
    
}


#pragma mark: ドラッグのメイン
//基本の動作はこのメソッドの中で行われる．最初のドラッグが行われるまではここには入らない
//TODO: オブジェクトを画面外にはみ出させた時，触れなくなるバグがある．→解決
- (void)dragging:(id)sender {
    
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *) sender;
    NSUInteger i = 0;
    //NSUInteger j;
#pragma mark: Analyzeに言われて変更したとこ
    //onoImageView* tmpImage = [[onoImageView alloc]init];
    //BOOL playheaddrag = NO;
    
    //下のswitch文で文句言われたので一応書き換えとく
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        i = 1;
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        i = 2;
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        i = 3;
    }
    
    
    
    //switch文のcaseを書き換えた．それぞれ上からUIGestureRecognizerStateBegan，UIGestureRecognizerStateChanged，UIGestureRecognizerStateEndedとなってた．
    switch (i/*recognizer.state*/) { //コメント内の書き方だと文句言われた．動作はしてた模様．
#pragma mark: ドラッグ開始
        case 1: {
#pragma mark: Analyzeに言われて変更したとこ
            //onoImageView *copysubject = [[onoImageView alloc]init];
            onoImageView *dragSubject = [[onoImageView alloc]init];
            
            
            
            for (dragSubject in _dragSubjects) {
                //TODO: pointInside seems to answer no even tough the point is actually inside the view?
                
                CGPoint pointInSubjectsView = [recognizer locationInView:dragSubject];
                BOOL pointInSideDraggableObject = [dragSubject pointInside:pointInSubjectsView withEvent:nil];
                
                
                //playHeadがドラッグされてるかどうかの判定
                _playHeadDragged = NO;
                CGPoint pointInPlayHead = [recognizer locationInView:_playHead];
                _playHeadDragged = [_playHead pointInside:pointInPlayHead withEvent:nil];
                
                if (_playHeadDragged) {
                    //_playHeadDragged = YES;
                    break;
                }
                
                BOOL handledragged = NO;
                if (_tappedsubjecs.count > 0) {
                    for (int i=0; i<_tappedsubjecs.count; i++) {
#pragma mark: Analyzeに言われて変更したとこ
                        //handleView* tmphandle = [[handleView alloc]init];
                        
                        handleView* tmphandle = [_tappedsubjecs[i] handle1];
                        CGPoint pointInHandle = [recognizer locationInView:tmphandle];
                        handledragged = [tmphandle pointInside:pointInHandle withEvent:nil];
                        if (handledragged) {
                            break;
                        }
                        tmphandle = [_tappedsubjecs[i] handle2];
                        pointInHandle = [recognizer locationInView:tmphandle];
                        handledragged = [tmphandle pointInside:pointInHandle withEvent:nil];
                        if (handledragged) {
                            break;
                        }
                        tmphandle = [_tappedsubjecs[i] handle3];
                        pointInHandle = [recognizer locationInView:tmphandle];
                        handledragged = [tmphandle pointInside:pointInHandle withEvent:nil];
                        if (handledragged) {
                            break;
                        }
                        tmphandle = [_tappedsubjecs[i] handle4];
                        pointInHandle = [recognizer locationInView:tmphandle];
                        handledragged = [tmphandle pointInside:pointInHandle withEvent:nil];
                        if (handledragged) {
                            break;
                        }
                    }
                }
                
                
                
                
                
                
                //NSLog(@"point%@ %@ subject%@", NSStringFromCGPoint(pointInSubjectsView), pointInSideDraggableObject ? @"inside" : @"outside", NSStringFromCGRect(dragSubject.frame));
                
                //handleまたはplayHeadがドラッグされてる時は入らない
                if (pointInSideDraggableObject && !handledragged && !_playHeadDragged) {
                    //NSLog(@"\n\nstarted dragging an object %s", [dragSubject.imageName UTF8String]);
                    
                    //NSLog(@"\n\nisInCanvasの状態 : %d\n\n", dragSubject.isInCanvas);
                    
                    
                    
                    
                    //
                    //
                    if (dragSubject.isTapped == YES) {
                        [dragSubject.handle1 removeFromSuperview];
                        [dragSubject.handle2 removeFromSuperview];
                        [dragSubject.handle3 removeFromSuperview];
                        [dragSubject.handle4 removeFromSuperview];
                        //dragSubject.isTapped = NO;
                        [_tappedsubjecs removeObject:dragSubject];
                        if(_isLongPressed){
                            [_copylabel removeFromSuperview];
                            _isLongPressed = NO;
                        }
                    }
                    
                    
                    //deepCopyメソッドはhttp://stackoverflow.com/questions/10188387/how-to-implement-deep-copy-for-the-class-in-uikit
                    //を参考にonoimageviewに実装した
                    onoImageView* copysubject = [dragSubject deepCopy:dragSubject];
                    
                    
                    //オブジェクトがキャンバス内にあったら，移動前のコピー元のオブジェクトを記憶しとく
                    //同時にコピー元をsuperviewから取り除く
                    if (copysubject.isInCanvas == 1) {
                        copysubject.lastImage = dragSubject;
                        [dragSubject removeFromSuperview];
                    }
                    
                    
                    //あってもなくても一緒っぽい
                    //[_dropAreas[0] bringSubviewToFront:copysubject];
                    
                    
                    
                    //NSLog(@"\n\nisDragged : %d\n\n", copysubject.isDragged);
                    
                    [copysubject removeFromSuperview];
                    
                    
                    //ズーム率が1.0じゃない時はドラッグ時の画像もズーム率にあわせてやる
                    if (_zoomscale != 1.0) {
                        float widthPer = _zoomscale;
                        float heightPer = _zoomscale;
                        
                        
                        
                        copysubject.originalSize_width = copysubject.frame.size.width;
                        copysubject.originalSize_height = copysubject.frame.size.height;
                        
                        CGRect rect = CGRectMake(copysubject.frame.origin.x, copysubject.frame.origin.y, copysubject.frame.size.width*widthPer, copysubject.frame.size.height*heightPer);
                        
                        copysubject.frame = rect;
                    }
                    
                    
                    //ユーザが操作している対象であることを明確にするために半透明ビューをaddする
                    if (copysubject.isInCanvas) {
                        copysubject.imageselectedframe = [[UIImageView alloc]initWithFrame:CGRectMake(copysubject.bounds.origin.x, copysubject.bounds.origin.y, copysubject.frame.size.width, copysubject.frame.size.height)];
                        copysubject.imageselectedframe.opaque = NO;
                        copysubject.imageselectedframe.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.5];
                        [copysubject addSubview:copysubject.imageselectedframe];
                    }
                    
                    
                    //これはドラッグ時のアニメーション用
                    [recognizer.view addSubview:copysubject];
                    
                    //ここ以下の処理にはcopysubjectではなくself.dragContext.draggedviewを使うといい？
                    self.dragContext = [[DragContext alloc] initWithDraggedView:copysubject andDroppableareas:_dropAreas andDragSubjects:_dragSubjects];
                    
                    //                    printf("ドラッグ開始時self.dragContext.draggedView.x : %f\n",self.dragContext.draggedView.frame.origin.x);
                    //                    printf("ドラッグ開始時self.dragContext.draggedView.y : %f\n",self.dragContext.draggedView.frame.origin.y);
                    
                    
                    [self dragObjectAccordingToGesture:recognizer];
                    
                    //ここでbreakしとかないとオブジェクトが重なってたときおかしな動作になる
                    break;
                } else {
                    //NSLog(@"started drag outside drag subjects");
                }
            }
#pragma mark: ハンドル動かしたときここに入る
            if (!_playHeadDragged && recognizer.numberOfTouches == 1) {
                if(_tappedsubjecs.count != 0){
                    for (onoImageView* draggedViewWithHandle in [_tappedsubjecs reverseObjectEnumerator]) {
                        CGPoint pointInHandleLeft = [recognizer locationInView:draggedViewWithHandle.handle1];
                        BOOL isLeftHandleDragged = [draggedViewWithHandle.handle1 pointInside:pointInHandleLeft withEvent:nil];
                        CGPoint pointInHandleTop = [recognizer locationInView:draggedViewWithHandle.handle2];
                        BOOL isTopHandleDragged = [draggedViewWithHandle.handle2 pointInside:pointInHandleTop withEvent:nil];
                        CGPoint pointInHandleRight = [recognizer locationInView:draggedViewWithHandle.handle3];
                        BOOL isRightHandleDragged = [draggedViewWithHandle.handle3 pointInside:pointInHandleRight withEvent:nil];
                        CGPoint pointInHandleBottom = [recognizer locationInView:draggedViewWithHandle.handle4];
                        BOOL isBottomHandleDragged = [draggedViewWithHandle.handle4 pointInside:pointInHandleBottom withEvent:nil];
                        
                        if (isLeftHandleDragged) {
#pragma mark: Analyzeに言われて変更したとこ
                            //isLeftHandleDragged = NO;
                            
                            [draggedViewWithHandle.handle1 removeFromSuperview];
                            [_dropAreas[0] addSubview:draggedViewWithHandle.handle1];
                            self.dragContext = [[DragContext alloc]initWithDraggedHandle:draggedViewWithHandle.handle1 andDroppableareas:_dropAreas andDragImage:draggedViewWithHandle];
                            [self dragHandleAccordingToGesture:recognizer];
                            break;
                        }else if (isTopHandleDragged){
#pragma mark: Analyzeに言われて変更したとこ
                            //isTopHandleDragged = NO;
                            [draggedViewWithHandle.handle2 removeFromSuperview];
                            [_dropAreas[0] addSubview:draggedViewWithHandle.handle2];
                            self.dragContext = [[DragContext alloc]initWithDraggedHandle:draggedViewWithHandle.handle2 andDroppableareas:_dropAreas andDragImage:draggedViewWithHandle];
                            [self dragHandleAccordingToGesture:recognizer];
                            break;
                        }else if (isRightHandleDragged){
#pragma mark: Analyzeに言われて変更したとこ
                            //isRightHandleDragged = NO;
                            [draggedViewWithHandle.handle3 removeFromSuperview];
                            [_dropAreas[0] addSubview:draggedViewWithHandle.handle3];
                            self.dragContext = [[DragContext alloc]initWithDraggedHandle:draggedViewWithHandle.handle3 andDroppableareas:_dropAreas andDragImage:draggedViewWithHandle];
                            [self dragHandleAccordingToGesture:recognizer];
                            break;
                        }else if (isBottomHandleDragged){
#pragma mark: Analyzeに言われて変更したとこ
                            //isBottomHandleDragged = NO;
                            [draggedViewWithHandle.handle4 removeFromSuperview];
                            [_dropAreas[0] addSubview:draggedViewWithHandle.handle4];
                            self.dragContext = [[DragContext alloc]initWithDraggedHandle:draggedViewWithHandle.handle4 andDroppableareas:_dropAreas andDragImage:draggedViewWithHandle];
                            [self dragHandleAccordingToGesture:recognizer];
                            break;
                        }
                        
                    }
                }//playHead動かしたときここに入る
            }else if (_playHeadDragged){
                [timerForPlayHead invalidate];
                _isPlayed = YES;
                _isPaused = YES;
                [_playHead removeFromSuperview];
                [recognizer.view addSubview:_playHead];
                self.dragContext = [[DragContext alloc]initWithPlayHead:_playHead andDroppableareas:_dropAreas];
                [self playHeadAccordingToGesture:recognizer];
                break;
            }
            
            
            break;
        }
#pragma mark: ドラッグ中
        case 2: {
            if (!_playHeadDragged) {
                if (!self.dragContext.isHandleDragged) {
                    [self dragObjectAccordingToGesture:recognizer];
                    break;
                }else{
                    [self dragHandleAccordingToGesture:recognizer];
                    break;
                }
            }else{
                [self playHeadAccordingToGesture:recognizer];
            }
            
            
            
            break;
        }
        case 3: {
#pragma mark: ドラッグ終了
            if (self.dragContext) {
                
                if (self.dragContext.draggedView) {
                    
                    [timerForAutoScroll invalidate];
                    //[timerForAutoScrollVirtical invalidate];
                    //_addScroll = 0;
                    onoImageView *viewBeingDragged = self.dragContext.draggedView;
                    //NSLog(@"ended drag event");
                    
                    CGPoint centerOfDraggedView = viewBeingDragged.center;
                    BOOL droppedViewInKnownArea = NO;
                    
                    
                    //   for(int i = 0; i < [self.dropAreas count]; i++) {
                    //     UIView *dropArea = [self.dropAreas objectAtIndex:i];}
                    
                    for (UIView *dropArea in self.dropAreas) {
                        CGPoint pointInDropView = [recognizer locationInView:dropArea];
                        //NSLog(@"tag %i pointInDropView %@ center of dragged view %@", dropArea.tag, NSStringFromCGPoint(pointInDropView), NSStringFromCGPoint(centerOfDraggedView));
                        if ([dropArea pointInside:pointInDropView withEvent:nil]) {
                            
                            droppedViewInKnownArea = YES;
                            
                            viewBeingDragged.dragCount++;
                            
                            
                            //拡大時のドラッグ中にオブジェクトを大きくしたのを元に戻してやる
                            if (_zoomscale != 1.0) {
                                CGRect rect = CGRectMake(viewBeingDragged.frame.origin.x, viewBeingDragged.frame.origin.y, viewBeingDragged.originalSize_width, viewBeingDragged.originalSize_height);
                                
                                viewBeingDragged.frame = rect;
                            }
                            
                            
                            
                            
                            //NSLog(@"dropped subject %@ on to view tag %i", NSStringFromCGRect(viewBeingDragged.frame), dropArea.tag);
                            [viewBeingDragged removeFromSuperview];
                            [dropArea addSubview:viewBeingDragged];
                            
                            //change origin to match offset on new super view
                            //                            if (viewBeingDragged.isInCanvas) {
                            //                                CGPoint pointOnView = [recognizer locationInView:recognizer.view];
                            //                                CGPoint movePoint;
                            //                                CGRect imageframe = [self.dragContext.draggedView frame];
                            //                                pointOnView.x = (int)pointOnView.x;
                            //                                pointOnView.y = (int)pointOnView.y;
                            //                                if (self.dragContext.lastpoint.x != 0 && self.dragContext.lastpoint.y != 0) {
                            //                                    movePoint.x = pointOnView.x - self.dragContext.lastpoint.x;
                            //                                    movePoint.y = pointOnView.y - self.dragContext.lastpoint.y;
                            //                                }
                            //                                //self.dragContext.lastpoint = pointOnView;
                            //
                            //                                if (movePoint.x != 0 || movePoint.y != 0) {
                            //                                    imageframe.origin.x += movePoint.x;
                            //                                    imageframe.origin.y += movePoint.y;
                            //                                    [self.dragContext.draggedView setFrame:imageframe];;
                            //                                }
                            //                            }else{
                            viewBeingDragged.frame = CGRectMake(pointInDropView.x - (viewBeingDragged.frame.size.width / 2), pointInDropView.y - (viewBeingDragged.frame.size.height / 2), viewBeingDragged.frame.size.width, viewBeingDragged.frame.size.height);
                            //                            }
                            
                            
                            //2回目のドラッグ以降描画されないのはここが原因だった．
                            if (!viewBeingDragged.isDragged) {
                                //[_dragSubjects addObject:viewBeingDragged];
                                
                                viewBeingDragged.isDragged = YES;
                                if (centerOfDraggedView.x < 768) {
                                    viewBeingDragged.isInCanvas = YES;
                                    //NSLog(@"Tag %i : biewBeingDraggedはキャンバスに追加されたよー : isInCanvas : %d", dropArea.tag, viewBeingDragged.isInCanvas);
                                }
                                
                            }
                            
                            //ここで移動後のオブジェクトを_dragsubjects配列に入れてやってる
                            [_dragSubjects addObject:viewBeingDragged];
                            
                            //                            if (viewBeingDragged.isTapped == YES) {
                            //                                [viewBeingDragged.handle1 removeFromSuperview];
                            //                                [viewBeingDragged.handle2 removeFromSuperview];
                            //                                [viewBeingDragged.handle3 removeFromSuperview];
                            //                                [viewBeingDragged.handle4 removeFromSuperview];
                            //                            }
                            
                            if (viewBeingDragged.isTapped) {
                                [viewBeingDragged.handle1 removeFromSuperview];
                                [viewBeingDragged.handle2 removeFromSuperview];
                                [viewBeingDragged.handle3 removeFromSuperview];
                                [viewBeingDragged.handle4 removeFromSuperview];
                                //[_tappedsubjecs removeObject:viewBeingDragged];
                                //viewBeingDragged.isTapped = YES;
                                [self drawHandle:viewBeingDragged];
                                [_tappedsubjecs addObject:viewBeingDragged];
                            }
                            
                            
                            _didScrolled = YES;
                            
                            [viewBeingDragged.imageselectedframe removeFromSuperview];
                            
                            //                            if (viewBeingDragged.isTapped == YES) {
                            //                                viewBeingDragged.isTapped = NO;
                            //                                [_tappedsubjecs removeObject:viewBeingDragged];
                            //                            }
                            
                            
                            //オブジェクトがキャンバス内にあったら移動前のものは消してやる
                            if (viewBeingDragged.isInCanvas == 1 && viewBeingDragged.lastImage != nil) {
                                [viewBeingDragged.lastImage removeFromSuperview];
                                [_dragSubjects removeObject:viewBeingDragged.lastImage];
                            }
                            
                            //置かれた場所によってpanの設定をしてる
                            if (viewBeingDragged.center.y < 180) {
                                viewBeingDragged.pan = -0.9;
                            }else if (viewBeingDragged.center.y >= 180 && viewBeingDragged.center.y < 310){
                                viewBeingDragged.pan = -0.5;
                            }else if (viewBeingDragged.center.y >= 310 && viewBeingDragged.center.y < 458){
                                viewBeingDragged.pan = 0.0;
                            }else if (viewBeingDragged.center.y >= 458 && viewBeingDragged.center.y < 588){
                                viewBeingDragged.pan = 0.5;
                            }else{
                                viewBeingDragged.pan = 0.9;
                            }
                        }else{
                            [viewBeingDragged.lastImage removeFromSuperview];
                            [_dragSubjects removeObject:viewBeingDragged.lastImage];
                        }
                    }
                    
                    //パレットにスナップする．後半の判定(|| (viewBeingDragged.isInCanvas == 1 && centerOfDraggedView.x > 768))を使ってオートスクロールしたい
                    if (!droppedViewInKnownArea || viewBeingDragged.isInCanvas == 0 || (viewBeingDragged.isInCanvas == 1 && centerOfDraggedView.x > 768)) {
                        //NSLog(@"release draggable object outside target views - snapping back to last known location");
                        
                        if (viewBeingDragged.isTapped) {
                            [viewBeingDragged.handle1 removeFromSuperview];
                            [viewBeingDragged.handle2 removeFromSuperview];
                            [viewBeingDragged.handle3 removeFromSuperview];
                            [viewBeingDragged.handle4 removeFromSuperview];
                            [_tappedsubjecs removeObject:viewBeingDragged];
                            //viewBeingDragged.isTapped = YES;
                            //[self drawHandle:viewBeingDragged];
                        }
                        
                        
                        [self.dragContext snapToOriginalPosition:droppedViewInKnownArea];
                        [_dragSubjects removeObject:viewBeingDragged];
                    }
                    //                else if(!droppedViewInKnownArea){
                    //                    [viewBeingDragged removeFromSuperview];
                    //                    [_dragSubjects removeObject:viewBeingDragged];
                    //
                    //                }
                    
                    self.dragContext = nil;
                    
                    //                    for (int n=0; n<_tappedsubjecs.count; n++) {
                    //                        printf("タップされてるオブジェクト : %d %s\n",n+1, [[[_tappedsubjecs objectAtIndex:n] imageName]UTF8String]);
                    //                    }
#pragma mark: ハンドル動かした時の後処理
                }else if(self.dragContext.draggedhandle){
                    
                    handleView* handleBeingDragged = self.dragContext.draggedhandle;
                    //CGPoint centerOfDraggedView = handleBeingDragged.center;
                    //BOOL droppedViewInKnownArea = NO;
                    for (UIView *dropArea in self.dropAreas) {
                        CGPoint pointInDropView = [recognizer locationInView:dropArea];
                        if ([dropArea pointInside:pointInDropView withEvent:nil]) {
                            //droppedViewInKnownArea = YES;
                            
                            [handleBeingDragged removeFromSuperview];
                            [dropArea addSubview:handleBeingDragged];
                            
                            if (self.dragContext.imageWithHandle.frame.size.height >= 240) {
                                self.dragContext.imageWithHandle.volume = 1.0;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 220 && self.dragContext.imageWithHandle.frame.size.height < 240){
                                self.dragContext.imageWithHandle.volume = 0.9;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 200 && self.dragContext.imageWithHandle.frame.size.height < 220){
                                self.dragContext.imageWithHandle.volume = 0.8;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 180 && self.dragContext.imageWithHandle.frame.size.height < 200){
                                self.dragContext.imageWithHandle.volume = 0.7;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 160 && self.dragContext.imageWithHandle.frame.size.height < 180){
                                self.dragContext.imageWithHandle.volume = 0.6;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 140 && self.dragContext.imageWithHandle.frame.size.height < 160){
                                self.dragContext.imageWithHandle.volume = 0.5;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 120 && self.dragContext.imageWithHandle.frame.size.height < 140){
                                self.dragContext.imageWithHandle.volume = 0.4;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 100 && self.dragContext.imageWithHandle.frame.size.height < 120){
                                self.dragContext.imageWithHandle.volume = 0.3;
                            }else if(self.dragContext.imageWithHandle.frame.size.height >= 80 && self.dragContext.imageWithHandle.frame.size.height < 100){
                                self.dragContext.imageWithHandle.volume = 0.2;
                            }else if(self.dragContext.imageWithHandle.frame.size.height < 80){
                                self.dragContext.imageWithHandle.volume = 0.1;
                            }
                            
                            handleBeingDragged.frame = self.dragContext.draggedhandle.frame;
                        }
                    }
                    //draggedViewWithHandle = nil;
                    self.dragContext = nil;
                    
                    //playHeadを動かした後処理
                }else if(self.dragContext.playHead){
                    //_playHeadDragged = NO;
                    CGPoint pointInDropView = [recognizer locationInView:_dropAreas[0]];
                    _playHeadDragged = YES;
                    [timerForAutoScroll invalidate];			//	タイマーを止める。
                    timerForAutoScroll = nil;
                    
                    
                    _lastPlayed = nil;
                    for (int i=0; i<_dragSubjects.count; i++) {
                        [[_dragSubjects objectAtIndex:i] setdidPlayed:NO];
                    }
                    [_playHead removeFromSuperview];
                    [_dropAreas[0] addSubview:_playHead];
                    _playHead.frame = CGRectMake(pointInDropView.x - (_playHead.frame.size.width / 2), 0, _playHead.frame.size.width, _playHead.frame.size.height);
                    [_dropAreas[0] bringSubviewToFront:_playHead];
                    _playheadX = _playHead.frame.origin.x + 15;
                    //                    printf("%f\n",_playheadX);
                    self.dragContext = nil;
                } else {
                    //NSLog(@"Nothing was being dragged");
                }
                //scrollview.userInteractionEnabled = YES;
                //pscrollview.userInteractionEnabled = YES;
                
                
                //デバッグ用．_dragSubjectsの中身を表示
                //for (int j=0; j<_dragSubjects.count; j++) {
                //onoImageView* tmpImage = _dragSubjects[j];
                //printf("%d:imageName : %s\n", j, [tmpImage.imageName UTF8String]);
                //printf("アドレス : %p\n", tmpImage);
                //printf("isDragged : %d\n",tmpImage.isDragged);
                //printf("isInCanvas : %d\n",tmpImage.isInCanvas);
                //printf("dragCount : %i\n",tmpImage.dragCount);
                //printf("コピー元のアドレス : %p\n", tmpImage.lastImage);
                //}
                //printf("draggableSubjectsの要素数 : %d\n", _dragSubjects.count);
                //printf("ズーム率 %f\n", _zoomscale);
                //printf("x : %f, y : %f\n",[_dragSubjects[_dragSubjects.count-1] frame].origin.x, [_dragSubjects[_dragSubjects.count-1] frame].origin.y);
                //printf("_playHeadDragged : %d\n", _playHeadDragged);
                break;
            }
            
            
            
        }
            [_dropAreas[0] bringSubviewToFront:_playHead];
            
            
    }
    
}

#pragma mark: ロングプレスで呼ばれるメソッド
-(void)handleLongPressGesture:sender{
    
    //printf("_isCopyInReady : %d\n",_isCopyInReady);
    for (int i=0;i<_tappedsubjecs.count;i++) {
        UILongPressGestureRecognizer* longPress = (UILongPressGestureRecognizer *) sender;
        //onoImageView *longPressSubject = [[onoImageView alloc]init];
#pragma mark: Analyzeに言われて変更したとこ
        onoImageView * longPressSubject = _tappedsubjecs[i];
        
        CGPoint pointInSubjectsView = [longPress locationInView:longPressSubject];
        BOOL pointInSideLongPressedObject = [longPressSubject pointInside:pointInSubjectsView withEvent:nil];
        
        if (pointInSideLongPressedObject && !_isLongPressed/* && !_isCopyInReady*/) {
            //            printf("!!!LongPressed!!!\n");
            _isLongPressed = YES;
            _copylabel = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"copynormal.png"]];
            [_copylabel setFrame:CGRectMake(longPressSubject.center.x - 44, longPressSubject.center.y - 89, 87, 89)];
            [_dropAreas[0] addSubview:_copylabel];
            //_copylabel.exclusiveTouch = YES;
            
            
            //            if(_pasteLabel != nil){
            //                [_pasteLabel removeFromSuperview];
            //                _isPasteLabelAppear = NO;
            //            }
            break;
        }else if(!pointInSideLongPressedObject && _isCopyInReady && !_isPasteLabelAppear){
            _isPasteLabelAppear = YES;
            
            CGPoint longPressPoint = [longPress locationInView:_dropAreas[0]];
            _copyPointInCanvas = longPressPoint;
            _pasteLabel = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pastenormal.png"]];
            [_pasteLabel setFrame:CGRectMake(longPressPoint.x - 44, longPressPoint.y - 80, 87, 89)];
            [_dropAreas[0] addSubview:_pasteLabel];
            break;
        }
    }
    
    
}

#pragma mark: ダブルタップで呼ばれるメソッド
//小節線にスナップする
-(void)doubleTap:(UIGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateEnded){
        for (int i=0; i<_dragSubjects.count; i++) {
            UITapGestureRecognizer* doubleFingerTap = (UITapGestureRecognizer *) sender;
#pragma mark: Analyzeに言われて変更したとこ
            //onoImageView *doubletapSubject = [[onoImageView alloc]init];
            onoImageView *doubletapSubject = _dragSubjects[i];
            
            
            CGPoint pointInSubjectsView = [doubleFingerTap locationInView:doubletapSubject];
            BOOL pointInSideTappedObject = [doubletapSubject pointInside:pointInSubjectsView withEvent:nil];
            if (pointInSideTappedObject && doubletapSubject.isInCanvas) {
                //printf("!!!doubleTapped!!!\n");
                
                //=====================================================================================
                //コピー準備ができてる段階でオブジェクトがダブルタップされるとシングルタップに反応しなくなることへの対策
                //=====================================================================================
                if (_isCopyInReady) {
                    _isCopyInReady = !_isCopyInReady;
                }
                
                float originX = doubletapSubject.frame.origin.x;
                //                printf("%f\n",originX);
                while ([self floatModulo:originX] != 0) {
                    if ([self floatModulo:originX] > 18.75) {
                        originX += [self floatModulo:originX] - 18.75;
                    }else if ([self floatModulo:originX] <= 18.75){
                        originX -= [self floatModulo:originX];
                    }
                    //                    printf("計算中... %f\n",originX);
                }
                
                //                printf("%f\n",originX);
                CGRect imageFrame = [doubletapSubject frame];
                imageFrame.origin.x = originX;
                
                [doubletapSubject.handle1 removeFromSuperview];
                [doubletapSubject.handle2 removeFromSuperview];
                [doubletapSubject.handle3 removeFromSuperview];
                [doubletapSubject.handle4 removeFromSuperview];
                
                
                if (doubletapSubject.isTapped == YES) {
                    doubletapSubject.isTapped = NO;
                    [_tappedsubjecs removeObject:doubletapSubject];
                }
                
                
                [doubletapSubject setFrame:imageFrame];
                
                //for (int n=0; n<_tappedsubjecs.count; n++) {
                //printf("タップされてるオブジェクト : %d %s\n",n+1, [[[_tappedsubjecs objectAtIndex:n] imageName]UTF8String]);
                //}
                
                break;
            }
        }
    }
}

//floatの剰余を求める関数
-(float)floatModulo:(float)left{
    float right = 37.5;
    
    left = left - 50;
    
    if(left>0){
        while(left-right>=0){
            left -= right;
        }
    }else if(left<0){
        do{
            left += right;
        }while(left<0);
    }
    return left;
}
#pragma mark: シングルタップで呼ばれるメソッド
//オブジェクトへのシングルタップを検出した時のメソッド．拡大/回転処理をやりたい
- (void)singleTap:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        UITapGestureRecognizer* singleFingerTap = (UITapGestureRecognizer *) sender;
        //CGPoint tapPoint = [sender locationInView:sender.view];
        
        
        
        if (_isLongPressed) {
            CGPoint pointInCopyLabel = [singleFingerTap locationInView:_copylabel];
            BOOL pointInSideCopyLabel = [_copylabel pointInside:pointInCopyLabel withEvent:nil];
            if (pointInSideCopyLabel) {
                //                printf("!!!copyLabel Tapped!!!\n");
                [_copylabel removeFromSuperview];
                _isLongPressed = NO;
                _isCopyInReady = YES;
                //                printf("_isCopyInReady : %d\n",_isCopyInReady);
            }else if(!pointInSideCopyLabel){
                //                printf("!!!OUTSIDE CopyLabel Tapped\n");
                [_copylabel removeFromSuperview];
                _isLongPressed = NO;
                //コピーボタンが押されなかったらコピー元をnilにしとく
                
            }
        }
        
        if (_isCopyInReady && _isPasteLabelAppear) {
            
            CGPoint pointInPasteLabel = [singleFingerTap locationInView:_pasteLabel];
            BOOL pointInsidePasteLabel = [_pasteLabel pointInside:pointInPasteLabel withEvent:nil];
            if (pointInsidePasteLabel) {
                //                printf("!!!Paste Label Tapped!!!\n");
                [_pasteLabel removeFromSuperview];
                _isPasteLabelAppear = NO;
                _isLongPressed = NO;
                _isCopyInReady = NO;
                //ここでコピーの処理
                
                //origin.xでソートしてる．sortByXはonoImageViewクラスで実装されてる
                [_tappedsubjecs sortUsingSelector:@selector(sortByX:)];
                
                float distanceFromCopyOriginalX = _copyPointInCanvas.x - [_tappedsubjecs[0] center].x;
                float distanceFromCopyOriginalY = _copyPointInCanvas.y - [_tappedsubjecs[0] center].y;
                
                for (int i=0; i<_tappedsubjecs.count; i++) {
                    onoImageView* cloned = [_tappedsubjecs[i] deepCopy:_tappedsubjecs[i]];
                    CGRect cloneFrame = [cloned frame];
                    cloneFrame.origin.x = cloned.frame.origin.x + distanceFromCopyOriginalX;
                    cloneFrame.origin.y = cloned.frame.origin.y + distanceFromCopyOriginalY;
                    [cloned setFrame:cloneFrame];
                    [_dragSubjects addObject:cloned];
                    [_dropAreas[0] addSubview:cloned];
                    //panの再設定
                    if (cloned.center.y < 180) {
                        cloned.pan = -0.9;
                    }else if (cloned.center.y >= 180 && cloned.center.y < 310){
                        cloned.pan = -0.5;
                    }else if (cloned.center.y >= 310 && cloned.center.y < 458){
                        cloned.pan = 0.0;
                    }else if (cloned.center.y >= 458 && cloned.center.y < 588){
                        cloned.pan = 0.5;
                    }else{
                        cloned.pan = 0.9;
                    }
                }
                _copyPointInCanvas.x = 0;
                _copyPointInCanvas.y = 0;
                for (int i=0; i<_tappedsubjecs.count; i++) {
                    [[_tappedsubjecs[i] handle1] removeFromSuperview];
                    [[_tappedsubjecs[i] handle2] removeFromSuperview];
                    [[_tappedsubjecs[i] handle3] removeFromSuperview];
                    [[_tappedsubjecs[i] handle4] removeFromSuperview];
                    
                    [_tappedsubjecs[i] setIsTapped:NO];
                }
                [_tappedsubjecs removeAllObjects];
                
                
            }else if(!pointInsidePasteLabel){
                //                printf("!!!OUTSIDE PasteLabel Tapped\n");
                [_pasteLabel removeFromSuperview];
                _isPasteLabelAppear = NO;
                _isLongPressed = NO;
            }
        }
        
        if (!_isCopyInReady) {
            for (int i=0;i<_dragSubjects.count;i++) {
#pragma mark: Analyzeに言われて変更したとこ
                //onoImageView *tapSubject = [[onoImageView alloc]init];
                onoImageView *tapSubject = _dragSubjects[i];
                
                CGPoint pointInSubjectsView = [singleFingerTap locationInView:tapSubject];
                BOOL pointInSideTappedObject = [tapSubject pointInside:pointInSubjectsView withEvent:nil];
                if (pointInSideTappedObject) {
                    if(tapSubject.isInCanvas){
                        tapSubject.isTapped = !tapSubject.isTapped;
                    }
                    [_dropAreas[0] bringSubviewToFront:tapSubject];
                    
                    if (tapSubject.isInCanvas && tapSubject.isTapped) {
                        [tapSubject.handle1 removeFromSuperview];
                        [tapSubject.handle2 removeFromSuperview];
                        [tapSubject.handle3 removeFromSuperview];
                        [tapSubject.handle4 removeFromSuperview];
                        
                        [self drawHandle:tapSubject];
                        //タップされたオブジェクトを_tappedsubjects配列に入れとく
                        [_tappedsubjecs addObject:tapSubject];
                    }else if(tapSubject.isInCanvas && !tapSubject.isTapped){
                        [tapSubject.handle1 removeFromSuperview];
                        [tapSubject.handle2 removeFromSuperview];
                        [tapSubject.handle3 removeFromSuperview];
                        [tapSubject.handle4 removeFromSuperview];
                        
                        [_copylabel removeFromSuperview];
                        _isLongPressed = NO;
                        _isPasteLabelAppear = NO;
                        _isCopyInReady = NO;
                        //ハンドルが消えたら_tappedsubjects配列から消す
                        [_tappedsubjecs removeObject:tapSubject];
                    }else{
                        //パレット内のオブジェクトのシングルタップで音鳴らしてるとこ
                        [self playSound:tapSubject];
                    }
                    
                    
                    //printf("%s がタップされたぜ\n",[tapSubject.imageName UTF8String]);
                    //printf("tapSubject.isTapped : %d\n",tapSubject.isTapped);
                    
                    //                    for (int n=0; n<_tappedsubjecs.count; n++) {
                    //                        printf("タップされてるオブジェクト : %d %s\n",n+1, [[[_tappedsubjecs objectAtIndex:n] imageName]UTF8String]);
                    //                    }
                    //NSLog(@"tapPoint x : %f",tapPoint.x);
                    //NSLog(@"tapPoint y : %f\n\n",tapPoint.y);
                    break;
                }
            }
        }
        
        
        
        
    }
}


#pragma mark: プレイボタンが押されたときに呼ばれるメソッド
//playButtonが押された時の処理
//-(void)playButtonDidPushed{
//    _isPlayed = !_isPlayed;
//
//    _playSpeed = 0.4/_Tempo;
//    //printf("playButton Pushed!\n_playspeed = %f\n",_playSpeed);
//
//
//
//    if (!_playHeadDragged) {
//        if (_isPaused) {
//            _isPaused = NO;//!_isPaused;
//        }
//
//        if (_isPlayed == YES) {
//            [_playbutton setImage:[UIImage imageNamed:@"stopButton1.png"]
//                         forState:UIControlStateNormal];
//
//            //[_playbutton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
//            _lastPlayed = nil;
//            [timerForPlayHead invalidate];
//            timerForPlayHead = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(movePlayHead:) userInfo:nil repeats:YES];
//            //printf("_playHeadの位置 %f\n", _playHead.frame.origin.x);
//
//
//        }else{
//            [_playbutton setImage:[UIImage imageNamed:@"playButton1.png"]
//                         forState:UIControlStateNormal];
//            [timerForAutoScroll invalidate];
//            [timerForPlayHead invalidate];
//            //[_playHead.layer removeAllAnimations];
//            _playHead.frame = CGRectMake(35, 0, _playHead.frame.size.width, _playHead.frame.size.height);
//            _isPaused = NO;
//            _addPlayHead = 35;
//            CGPoint scrollviewOffset = _scrollview.contentOffset;
//            scrollviewOffset.x = 0;
//            _scrollview.contentOffset = scrollviewOffset;
//            _playheadX =49;
//            for (int i=0; i<_dragSubjects.count; i++) {
//                [[_dragSubjects objectAtIndex:i] setdidPlayed:NO];
//            }
//            [_dropAreas[0] bringSubviewToFront:_playHead];
//            _lastPlayed = nil;
//            _playStartCount = 0;
//        }
//    }else{
//        if (_isPaused) {
//            [_playbutton setImage:[UIImage imageNamed:@"playButton1.png"]
//                         forState:UIControlStateNormal];
//            _playHeadDragged = NO;
//            [timerForAutoScroll invalidate];
//            [timerForPlayHead invalidate];
//            //[_playHead.layer removeAllAnimations];
//            _playHead.frame = CGRectMake(35, 0, _playHead.frame.size.width, _playHead.frame.size.height);
//            _isPaused = NO;
//            _addPlayHead = 35;
//            CGPoint scrollviewOffset = _scrollview.contentOffset;
//            scrollviewOffset.x = 0;
//            _scrollview.contentOffset = scrollviewOffset;
//            _playheadX = 49;
//            for (int i=0; i<_dragSubjects.count; i++) {
//                [[_dragSubjects objectAtIndex:i] setdidPlayed:NO];
//            }
//            [_dropAreas[0] bringSubviewToFront:_playHead];
//            _lastPlayed = nil;
//            _playStartCount = 0;
//        }else{
//            [_playbutton setImage:[UIImage imageNamed:@"stopButton1.png"]
//                         forState:UIControlStateNormal];
//            _isPaused = NO;
//            _isPlayed = YES;
//            [timerForPlayHead invalidate];
//            timerForPlayHead = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(movePlayHead:) userInfo:nil repeats:YES];
//            _addPlayHead = _playHead.frame.origin.x;
//            //printf("_playHeadの位置 %f\n", _playHead.frame.origin.x);
//            _playHeadDragged = NO;
//        }
//
//    }
//
//
//
//}

-(void)playButtonPressed{
    _playSpeed = 0.4/_Tempo;
    //printf("playButton Pushed!\n_playspeed = %f\n",_playSpeed);
    
    
    
    if (!_playHeadDragged) {
        if (_isPaused) {
            _isPaused = NO;//!_isPaused;
        }
        
        if (_isPlayed == YES) {
            [_playbutton setImage:[UIImage imageNamed:@"stopButton1.png"]
                         forState:UIControlStateNormal];
            
            //[_playbutton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
            _lastPlayed = nil;
            [timerForPlayHead invalidate];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:(1/60) target:self selector:@selector(tick:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
            //[timer invalidate];
            timerForPlayHead = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(movePlayHead:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timerForPlayHead forMode:NSRunLoopCommonModes];
            
            //printf("_playHeadの位置 %f\n", _playHead.frame.origin.x);
            
            
        }else{
            [_playbutton setImage:[UIImage imageNamed:@"playButton1.png"]
                         forState:UIControlStateNormal];
            _playHeadDragged = NO;
            [timerForAutoScroll invalidate];
            [timerForPlayHead invalidate];
            
            [timer invalidate];
            
            //[_playHead.layer removeAllAnimations];
            _playHead.frame = CGRectMake(35, 0, _playHead.frame.size.width, _playHead.frame.size.height);
            _isPaused = NO;
            _addPlayHead = 35;
            CGPoint scrollviewOffset = _scrollview.contentOffset;
            scrollviewOffset.x = 0;
            _scrollview.contentOffset = scrollviewOffset;
            _playheadX =49;
            for (int i=0; i<_dragSubjects.count; i++) {
                [[_dragSubjects objectAtIndex:i] setdidPlayed:NO];
            }
            [_dropAreas[0] bringSubviewToFront:_playHead];
            _lastPlayed = nil;
            _playStartCount = 0;
        }
    }else{
        if (_isPaused) {
            [_playbutton setImage:[UIImage imageNamed:@"playButton1.png"]
                         forState:UIControlStateNormal];
            _playHeadDragged = NO;
            [timerForAutoScroll invalidate];
            [timerForPlayHead invalidate];
            
            [timer invalidate];
            
            //[_playHead.layer removeAllAnimations];
            _playHead.frame = CGRectMake(35, 0, _playHead.frame.size.width, _playHead.frame.size.height);
            _isPaused = NO;
            _addPlayHead = 35;
            CGPoint scrollviewOffset = _scrollview.contentOffset;
            scrollviewOffset.x = 0;
            _scrollview.contentOffset = scrollviewOffset;
            _playheadX = 49;
            for (int i=0; i<_dragSubjects.count; i++) {
                [[_dragSubjects objectAtIndex:i] setdidPlayed:NO];
            }
            [_dropAreas[0] bringSubviewToFront:_playHead];
            _lastPlayed = nil;
            _playStartCount = 0;
        }else{
            [_playbutton setImage:[UIImage imageNamed:@"stopButton1.png"]
                         forState:UIControlStateNormal];
            _isPaused = NO;
            _isPlayed = YES;
            _playheadX = 49;
            [timerForPlayHead invalidate];
            timerForPlayHead = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(movePlayHead:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timerForPlayHead forMode:NSRunLoopCommonModes];
            //[timer invalidate];
            timer = [NSTimer scheduledTimerWithTimeInterval:(1/60) target:self selector:@selector(tick:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
            _addPlayHead = 35;
            //_addPlayHead = _playHead.frame.origin.x;
            //printf("_playHeadの位置 %f\n", _playHead.frame.origin.x);
            _playHeadDragged = NO;
        }
        
    }
    
    
}

//playHeadのアニメーション用
-(void)movePlayHead:(NSTimer *)timerformove{
    
    
    
    if (_playStartCount >= 600 || !_isMetroON) {
        //dispatch_async(globalQueue, ^{
        if (_playHead.frame.origin.x </*=*/ (600 * _BarNum) + 35) {
            _addPlayHead += 1;
            _playheadX += 1;
            //dispatch_async(mainQueue, ^{
            
            _playHead.frame = CGRectMake(_addPlayHead, 0, _playHead.frame.size.width, _playHead.frame.size.height);
            //});
            
            
            /*オートスクロールの処理が重い*///->実機だと結構いい感じ
            if (_isScrollOn) {
                CGPoint playheadlocation = _playHead.frame.origin;
                
                if (playheadlocation.x*_zoomscale >= _scrollview.window.frame.origin.x + 384) {
                    //printf("%f\n",playheadlocation.x);
                    
                    CGPoint scrollviewOffset = _scrollview.contentOffset;
                    scrollviewOffset.x = playheadlocation.x*_zoomscale - 384;
                    if (_playHead.frame.origin.x*_zoomscale <= ((600 * _BarNum) + 35 -250)*_zoomscale) {
                        //dispatch_async(mainQueue, ^{
                        _scrollview.contentOffset = scrollviewOffset;
                        //});
                    }
                    
                }
            }
            
        }else if(_playHead.frame.origin.x == (600 * _BarNum) + 35 && _isLoopOn){
            
            _playHead.frame = CGRectMake(35, 0, _playHead.frame.size.width, _playHead.frame.size.height);
            CGPoint scrollviewOffset = _scrollview.contentOffset;
            scrollviewOffset.x = 0;
            _scrollview.contentOffset = scrollviewOffset;
            
            //            [_playbutton setImage:[UIImage imageNamed:@"playButton1.png"]
            //                         forState:UIControlStateNormal];
            //            _playHeadDragged = NO;
            //            [timerForAutoScroll invalidate];
            //            [timerForPlayHead invalidate];
            //
            //            [timer invalidate];
            //
            //            //[_playHead.layer removeAllAnimations];
            //            _isPaused = NO;
            _addPlayHead = 35;
            _playheadX = 49;
            for (int i=0; i<_dragSubjects.count; i++) {
                [[_dragSubjects objectAtIndex:i] setdidPlayed:NO];
            }
            //[_dropAreas[0] bringSubviewToFront:_playHead];
            _lastPlayed = nil;
            
        }else if(_playHead.frame.origin.x == (600 * _BarNum) + 35 && !_isLoopOn){
            [_playbutton setImage:[UIImage imageNamed:@"playButton1.png"]
                         forState:UIControlStateNormal];
            _playHeadDragged = NO;
            [timerForAutoScroll invalidate];
            [timerForPlayHead invalidate];
            [timer invalidate];
            //[_playHead.layer removeAllAnimations];
            _isPaused = NO;
            //_addPlayHead = 35;
            //_playheadX = 49;
            for (int i=0; i<_dragSubjects.count; i++) {
                [[_dragSubjects objectAtIndex:i] setdidPlayed:NO];
            }
            [_dropAreas[0] bringSubviewToFront:_playHead];
            _lastPlayed = nil;
            
        }
        //});
        
    }else{
        if (_playStartCount == 0 && _isMetroON) {
            [_click play];
            
        }else if(_playStartCount == 150 && _isMetroON){
            [_click play];
        }else if(_playStartCount == 300 && _isMetroON){
            [_click play];
        }else if(_playStartCount == 450 && _isMetroON){
            [_click play];
        }
        
    }
    
    if (_isMetroON) {
        _playStartCount += 1;
    }
    
    
}



#pragma mark: pause buttonが押された時に呼ばれるメソッド
//pausebuttonが押された時の処理
//-(void)pauseButtonDidPushed{
//
//    if (_isPlayed) {
//        //printf("**pauseButton Pushed!!**\n");
//
//        _isPaused = !_isPaused;
//        if (_isPaused) {
//            _playHeadDragged = NO;
//            [timerForPlayHead invalidate];
//            _playheadX = _playHead.frame.origin.x + 15;
//        }else if(!_isPaused){
//
//            _playSpeed = 0.4/_Tempo;
//            _addPlayHead = _playHead.frame.origin.x;
//            _playHeadDragged = NO;
//            timerForPlayHead = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(movePlayHead:) userInfo:nil repeats:YES];
//        }
//    }
//
//
//}

-(void)pauseButtonPressed{
    if (_isPlayed) {
        //printf("**pauseButton Pushed!!**\n");
        
        //_isPaused = !_isPaused;
        if (_isPaused) {
            _playHeadDragged = NO;
            [timerForPlayHead invalidate];
            
            [timer invalidate];
            
            _playheadX = _playHead.frame.origin.x + 15;
        }else if(!_isPaused){
            
            _playSpeed = 0.4/_Tempo;
            _addPlayHead = _playHead.frame.origin.x;
            _playHeadDragged = NO;
            timerForPlayHead = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(movePlayHead:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timerForPlayHead forMode:NSRunLoopCommonModes];
            timer = [NSTimer scheduledTimerWithTimeInterval:(1/60) target:self selector:@selector(tick:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            
            //[ViewController pauseButtonDidPushed];
        }
    }
    
    
}

#pragma mark: 再生ヘッド用タイマー発火後に1/60秒ごとに呼ばれるメソッド
//2回目タイマーが発火したとき再びオブジェクトをドラッグするまで音が鳴らない→オーケー
//ここはもっとシンプルに書けるはず．_lastPlayedとかいらなそう→_lastPlayedがなかったらmuted while enumelatedのエラーが出た
- (void)tick:(NSTimer *)theTimer {
    
    
    //        if (_isPlayed && _isPaused) {
    //            if (_pausebuttonPushed) {
    //                _playHeadDragged = NO;
    //                [timerForPlayHead invalidate];
    //                _playheadX = _playHead.frame.origin.x + 15;
    //                _pausebuttonPushed = YES;
    //            }
    //
    //        }else if(_isPlayed && !_isPaused){
    //            if (_pausebuttonPushed) {
    //                _playSpeed = 0.4/_Tempo;
    //                _addPlayHead = _playHead.frame.origin.x;
    //                _playHeadDragged = NO;
    //                timerForPlayHead = [NSTimer scheduledTimerWithTimeInterval:_playSpeed target:self selector:@selector(movePlayHead:) userInfo:nil repeats:YES];
    //                _pausebuttonPushed = NO;
    //            }
    //
    //        }
    
    
    
    
    /*ここをサブキューに入れちゃうとおかしなことになる*/
    //dispatch_async(globalQueue, ^{
    //printf("_playHeadの位置 %f\n", _playHead.frame.origin.x);
    for (int i = 0; i < _dragSubjects.count; i++) {
        
        if ([[_dragSubjects objectAtIndex:i] getisInCanvas] && /*_playHead.frame.origin.x + 15*/_playheadX >= [[_dragSubjects objectAtIndex:i] frame].origin.x && /*_playHead.frame.origin.x + 15*/_playheadX <= [[_dragSubjects objectAtIndex:i] frame].origin.x + 1) {
            
            if (_lastPlayed != [_dragSubjects objectAtIndex:i]) {
                
                _iscollisioned = YES;
                [[_dragSubjects objectAtIndex:i] setCollision:YES];
                //[_collisionedSubjects addObject:[_dragSubjects objectAtIndex:i]];
            }
        }
        
        if(_iscollisioned){
            //高速列挙中に配列の要素を変更すんな！というエラーの原因がここのような気がしたので配列使うのやめた
            //for (onoImageView* collisionedSubject in _collisionedSubjects) {
#pragma mark: Analyzeに言われて変更したとこ
            //onoImageView* collisionedSubject=[[onoImageView alloc]init];
            onoImageView* collisionedSubject = [_dragSubjects objectAtIndex:i];
            if (!collisionedSubject.didPlayed) {
                //dispatch_async(mainQueue, ^{
                [self playSound:collisionedSubject];
                //});
            }
            _iscollisioned = NO;
            
            //}
            
        }
    }
    
    //    // 初期化（init）し現在の時刻を取得する
    //    NSDate *date = [NSDate date];
    //    // NSDateFomatter=NSDateの値を整形する
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setLocale:[NSLocale currentLocale]];
    //    // 年月日曜日を全て表示する
    //    [formatter setDateStyle:NSDateFormatterFullStyle];
    //    // 時分秒タイムゾーンを全て表示する
    //    [formatter setTimeStyle:NSDateFormatterFullStyle];
    //    // Date型からString型に置換する
    //    NSString *dateStr = [formatter stringFromDate:date];
    
    //printf("%s\n",[dateStr UTF8String]);
    
    //printf("%f\n",_playHead.frame.origin.x);
    
    //});
}


#pragma mark: 音鳴らすとこ
// このメソッドが呼ばれてオーディオを再生する


-(void)playSound:(onoImageView*)onoplay{
    
    int index;
    index = onoplay.soundNumber;
    //float pan = 0.0;
    
    alSource3f(_sources[index], AL_POSITION, onoplay.pan, 0.0f, 0.0f);//x:左右, y:上下, z:前後
    alSourcef(_sources[index], AL_GAIN, onoplay.volume);
    alSourcePlay(_sources[index]);
    
    //printf("onoplay.volume : %f\n",onoplay.volume);
    
    //    onoplay.audio.pan = onoplay.pan;
    //    onoplay.audio.volume = onoplay.volume;
    //    onoplay.audio.currentTime = 0;
    //    [onoplay.audio play];
    //[[soundarr objectAtIndex:index] play];
    
    //    printf("衝突！！ : %s\n", [[onoplay imageName] UTF8String]);
    _lastPlayed = onoplay;
    //printf("lastplayed : %s\n", [[_lastPlayed imageName] UTF8String]);
    [onoplay setdidPlayed:YES];
    //[onoplay.audio prepareToPlay];
    //[_collisionedSubjects removeObjectAtIndex:0];
    
}

#pragma mark: 編集用ハンドルを描くメソッド
-(void)drawHandle:(onoImageView*)draggedview{
    
    draggedview.handle1 = [[handleView alloc]initWithFrame:CGRectMake(draggedview.frame.origin.x - 40, draggedview.frame.origin.y + draggedview.frame.size.height/2 - 50, 40.0, 100.0)];
    //    draggedview.handle1.backgroundColor = [UIColor blackColor];
    draggedview.handle1.opaque = NO;
    draggedview.handle1.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    draggedview.handle1.handlename = @"left";
    [_dropAreas[0] addSubview:draggedview.handle1];
    draggedview.handle1.hidden = NO;
    UIImageView* fakehandle1 = [[UIImageView alloc]initWithFrame:CGRectMake(draggedview.handle1.bounds.origin.x + 25, draggedview.handle1.bounds.origin.y + 47.5, 5.0, 5.0)];
    fakehandle1.backgroundColor = [UIColor redColor];
    [draggedview.handle1 addSubview:fakehandle1];
    
    draggedview.handle2 = [[handleView alloc]initWithFrame:CGRectMake(draggedview.frame.origin.x + draggedview.frame.size.width/2 - 50, draggedview.frame.origin.y - 40,  100.0, 40.0)];
    //    draggedview.handle2.backgroundColor = [UIColor blackColor];
    draggedview.handle2.opaque = NO;
    draggedview.handle2.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    draggedview.handle2.handlename = @"top";
    [_dropAreas[0] addSubview:draggedview.handle2];
    draggedview.handle2.hidden = NO;
    UIImageView* fakehandle2 = [[UIImageView alloc]initWithFrame:CGRectMake(draggedview.handle2.bounds.origin.x + 47.5, draggedview.handle2.bounds.origin.y + 25, 5.0, 5.0)];
    fakehandle2.backgroundColor = [UIColor redColor];
    [draggedview.handle2 addSubview:fakehandle2];
    
    draggedview.handle3 = [[handleView alloc]initWithFrame:CGRectMake(draggedview.frame.origin.x + draggedview.frame.size.width, draggedview.frame.origin.y + draggedview.frame.size.height/2 - 50, 40.0, 100.0)];
    //    draggedview.handle3.backgroundColor = [UIColor blackColor];
    draggedview.handle3.opaque = NO;
    draggedview.handle3.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    draggedview.handle3.handlename = @"right";
    [_dropAreas[0] addSubview:draggedview.handle3];
    draggedview.handle3.hidden = NO;
    UIImageView* fakehandle3 = [[UIImageView alloc]initWithFrame:CGRectMake(draggedview.handle3.bounds.origin.x + 10, draggedview.handle3.bounds.origin.y + 47.5, 5.0, 5.0)];
    fakehandle3.backgroundColor = [UIColor redColor];
    [draggedview.handle3 addSubview:fakehandle3];
    
    draggedview.handle4 = [[handleView alloc]initWithFrame:CGRectMake(draggedview.frame.origin.x + draggedview.frame.size.width/2 - 50, draggedview.frame.origin.y + draggedview.frame.size.height,  100.0, 40.0)];
    //    draggedview.handle4.backgroundColor = [UIColor blackColor];
    draggedview.handle4.opaque = NO;
    draggedview.handle4.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    draggedview.handle4.handlename = @"bottom";
    [_dropAreas[0] addSubview:draggedview.handle4];
    draggedview.handle4.hidden = NO;
    UIImageView* fakehandle4 = [[UIImageView alloc]initWithFrame:CGRectMake(draggedview.handle4.bounds.origin.x + 47.5, draggedview.handle4.bounds.origin.y + 10, 5.0, 5.0)];
    fakehandle4.backgroundColor = [UIColor redColor];
    [draggedview.handle4 addSubview:fakehandle4];
    
    //printf("Handle Drawed!!\n");
    
    //        printf("%s\n",[draggedview.handle1.handlename UTF8String]);
    //        printf("%s\n",[draggedview.handle2.handlename UTF8String]);
    //        printf("%s\n",[draggedview.handle3.handlename UTF8String]);
    //        printf("%s\n",[draggedview.handle4.handlename UTF8String]);
    
}

-(void)settingButtonDidPushed{
    //printf("!!!settingButton Pushed!!!\n");
    _settingViewController = [[SettingViewController alloc]init];
    _settingViewController.contentSizeForViewInPopover = CGSizeMake(300, 650);
    
    _settingViewController.delegate = self;   // デリゲート
    if (self.popOver == nil)
    {
        self.popOver = [[UIPopoverController alloc] initWithContentViewController:_settingViewController];
        self.popOver.delegate = self;
    }
    
    // ポップオーバーが現在表示されていなければ表示する
    if (!self.popOver.popoverVisible)
    {
        
        [self.popOver presentPopoverFromRect:CGRectMake(1020, 0, 0, 0)
                                      inView:[[_dropAreas[0] superview]superview]
                    permittedArrowDirections:UIPopoverArrowDirectionUp   // 矢印の向きを指定する
                                    animated:YES];
            }
    
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    //printf("popOver Closed!!!\n");
    
    printf("小節数 : %d\n",/*_settingViewController.*/_BarNum);
    
    printf("テンポ : %d\n",/*_settingViewController.*/_Tempo);
}

// Delegete Method
- (void)SettingViewControllerDelegateDidFinish:(NSInteger)getBar andTempo:(NSInteger)getTempo
{
    //ピッカービューで選択した値を取得
    _BarNum = getBar;
    
    //testViewの再描画はやめた
    //[_dropAreas[0] setBarNumber:_BarNum];
    //[_dropAreas[0] setNeedsDisplay];
    
    [_scrollview setContentSize:CGSizeMake((_BarNum * 600) + 200, 768)];
//    printf("小節数 : %d\n", getBar);
    _Tempo = getTempo;
    
    
    printf("getBar: %d\n",getBar);
    printf("getTempo: %d\n",getTempo);
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.BarNum = _BarNum;
    appDelegate.Tempo = _Tempo;
    printf("小節数 : %d\n", getBar);
    printf("テンポ : %d\n", getTempo);
}

////pickerView delegateを入れたらここ以下の二つのメソッドを実装しないとwarningが出た
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
//{
//    return 1;
//}
//
//- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    if (pickerView.tag == 1) {
//        return 16;
//    }
//    if (pickerView.tag == 2){
//        return 250;
//    }
//    return 0;
//}
@end