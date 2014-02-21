//
//  Created by jve on 4/1/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@class DragContext;
@class onoImageView;
@class SettingViewController;

@interface DragDropManager : NSObject<UIPopoverControllerDelegate,SettingViewControllerDelegate>{
    
    //UIScrollView* pscrollview;
    //@public
    //NSMutableArray* draggableSubjects;
    NSTimer *timer;
    NSTimer *timerForPlayHead;
    NSTimer *timerForAutoScroll;
    NSTimer *timerForAutoScrollVirtical;
    
    ALuint  _buffers[40/*83*/];
    ALuint  _sources[40/*83*/];
    
    //dispatch_queue_t mainQueue;
    //dispatch_queue_t globalQueue;
    //onoImageView* draggedViewWithHandle;
    
}
- (id)initWithDragSubjects:(NSMutableArray *)dragSubjects andDropAreas:(NSMutableArray *)dropAreas andplayHead:(UIImageView*)playhead andscrollview:(UIScrollView*)scrollview;

- (void)setZoomScale:(float)scale;

- (void)dragging:(id)sender;

//-(id)initwithBarNum:(int)barNum andTempo:(int)tempo;

-(float)floatModulo:(float)left;

// delegate
- (void)SettingViewControllerDelegateDidFinish:(NSInteger)getBar andTempo:(NSInteger)getTempo;

-(void)pauseButtonPressed;
-(void)playButtonPressed;

-(void)eraseAll;

-(void)loadProject:(NSString*)plistname;

@property(nonatomic,retain)NSMutableArray* dragSubjects;
@property(nonatomic, retain) DragContext *dragContext;
@property(nonatomic, retain, readonly) NSMutableArray *dropAreas;
@property float zoomscale;
@property BOOL isPlayed;
@property BOOL isPaused;
@property (nonatomic, retain)UIImageView* playHead;
@property BOOL iscollisioned;
@property float addPlayHead;
@property NSMutableArray* collisionedSubjects;
@property onoImageView* lastPlayed;

@property float playSpeed;

@property NSMutableArray *soundarr;

@property NSMutableArray* tappedsubjecs;

@property BOOL playHeadDragged;
@property(nonatomic, retain)UIButton *playbutton;
@property(nonatomic, retain)UIButton *metrobutton;

//@property BOOL pausebuttonPushed;
//@property(nonatomic, retain)UINavigationItem* navItem;

@property SettingViewController* settingViewController;
@property (strong, nonatomic) UIPopoverController *popOver;

@property int BarNum;
@property int Tempo;

@property (nonatomic, retain) UIScrollView* scrollview;

@property float playheadX;

//@property int addScroll;

@property float autoscrollDistance;
//@property float autoscrollDistanceVirtical;
//@property CGPoint scrollcontentoffset;

@property UIImageView* copylabel;
@property UIImageView* pasteLabel;
@property BOOL  isLongPressed;
@property BOOL isCopyInReady;
@property BOOL isPasteLabelAppear;

@property CGPoint copyPointInCanvas;

@property int playStartCount;
@property AVAudioPlayer* click;
@property BOOL isMetroON;
@property BOOL isLoopOn;
@property BOOL isScrollOn;

@property BOOL didScrolled;

//@property(nonatomic,retain)NSString* plistName;

@end