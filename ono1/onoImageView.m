//
//  onoImageView.m
//  ono1
//
//  Created by JO ARIMA on 2013/01/01.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import "onoImageView.h"
//#import "onoINScording.h"
@implementation onoImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isInCanvas = NO;
        self.isDragged = NO;
        self.imageName = nil;
        self.isTapped = NO;
        self.dragCount = 0;
        self.lastImage = nil;
        self.originalSize_width = 0;
        self.originalSize_height = 0;
        self.collision = NO;
        self.didPlayed = NO;
        self.soundNumber = 0;
//        self.audio = nil;
        self.pan = 0;
        self.volume = 0.5;
//        self.handle1 = nil;
//        self.handle2 = nil;
//        self.handle3 = nil;
//        self.handle4 = nil;
    }
    return self;
}
//@synthesize collision;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(onoImageView *)deepCopy:(onoImageView*)draggedimage
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:@"imageViewDeepCopy"];
    [archiver finishEncoding];
    //[archiver release];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    onoImageView *imgView = [unarchiver decodeObjectForKey:@"imageViewDeepCopy"];
    imgView.isInCanvas = draggedimage.isInCanvas;
    imgView.isTapped = draggedimage.isTapped;
    imgView.isDragged = draggedimage.isDragged;
    imgView.imageName = draggedimage.imageName;
    imgView.frame = draggedimage.frame;
    imgView.dragCount = draggedimage.dragCount;
    imgView.lastImage = draggedimage.lastImage;
    imgView.originalSize_width = draggedimage.originalSize_width;
    imgView.originalSize_height = draggedimage.originalSize_height;
    imgView.tag = draggedimage.tag;
    imgView.collision = NO;//draggedimage.collision;
    imgView.didPlayed = NO;
    imgView.soundNumber = draggedimage.soundNumber;

    imgView.handle1 = [[handleView alloc]initWithFrame:draggedimage.handle1.frame];
    imgView.handle2 = [[handleView alloc]initWithFrame:draggedimage.handle2.frame];
    imgView.handle3 = [[handleView alloc]initWithFrame:draggedimage.handle3.frame];
    imgView.handle4 = [[handleView alloc]initWithFrame:draggedimage.handle4.frame];
    
    //imgView.audio = [[AVAudioPlayer alloc]initWithContentsOfURL:draggedimage.audio.url error:nil];//draggedimage.audio;
    imgView.pan = draggedimage.pan;
    imgView.volume = draggedimage.volume;
    //[imgView.audio prepareToPlay];
    //printf("imgView.volume : %f",imgView.volume);
    //imgView.exclusiveTouch = YES;
    return imgView;
}

//origin.xでのソート用
- (NSComparisonResult)sortByX:(onoImageView *)image {
	if (self.frame.origin.x > image.frame.origin.x) {
		return NSOrderedDescending;
	} else if (self.frame.origin.x < image.frame.origin.x) {
		return NSOrderedAscending;
	} else {
		return NSOrderedSame;
	}
}

//- (id)initWithCoder:(NSCoder *)decoder
//{
//    self = [super init];
//    if (self) {
//        _isInCanvas = YES;
//        _isDragged = NO;
//        _imageName = [decoder decodeObjectForKey:@"imageName"];
//        _isTapped = NO;
//        _dragCount = 1;
//        _lastImage = nil;
//        self.originalSize_width = [decoder decodeIntegerForKey:@"originalSize_width"];
//        self.originalSize_height = [decoder decodeIntegerForKey:@"originalSize_height"];
//        _collision = NO;
//        _didPlayed = NO;
//        _soundNumber = [decoder decodeIntegerForKey:@"soundNumber"];
//        _pan = [decoder decodeIntegerForKey:@"pan"];
//        _volume = [decoder decodeIntegerForKey:@"volume"];
//        
////        _handle1 = [[handleView alloc]init];
////        _handle2 = [[handleView alloc]init];
////        _handle3 = [[handleView alloc]init];
////        _handle4 = [[handleView alloc]init];
//    }
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)encoder
//{
//    [encoder encodeObject:_imageName forKey:@"name"];
//    [encoder encodeInteger:self.originalSize_width forKey:@"originalSize_width"];
//    [encoder encodeInteger:self.originalSize_height forKey:@"originalSize_height"];
//    [encoder encodeInteger:_soundNumber forKey:@"soundNumber"];
//    [encoder encodeInteger:_pan forKey:@"pan"];
//    [encoder encodeInteger:_volume forKey:@"volume"];
//}

@end
