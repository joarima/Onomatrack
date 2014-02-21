//
//  testView.m
//  ono1
//
//  Created by JO ARIMA on 2012/12/29.
//  Copyright (c) 2012年 JO ARIMA. All rights reserved.
//

#import "testView.h"

@implementation testView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.zoomscale = 1.0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
//	CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
    
    CGContextSetLineCap(context, kCGLineCapRound); 
    
	UIFont *font = [UIFont systemFontOfSize:20];
	CGPoint origin = self.frame.origin;
    origin.x += 50;
    origin.y += 50;
	double left = self.bounds.origin.x + 50;
	double top = self.bounds.origin.y + 50;
	double right = left + self.bounds.size.width - 50;
	double bottom = top + self.bounds.size.height - 100;
    
    //for (double v = top; v < bottom; v += 100.0) {
		for (int h = 1; h < right - 100; h += 600.0) {
			NSString* str = [NSString stringWithFormat:@"%d", (h/600) + 1];
			[str drawAtPoint:CGPointMake((left + 5)+h, top - 25) withFont:font];
		}
	//}
    
//	for (double v = top; v < bottom; v += 100.0) {
//		CGContextMoveToPoint(context, left, v);
//		CGContextAddLineToPoint(context, right, v);
//		CGContextStrokePath(context);
//	}
    
    //小節線
    CGContextSetLineWidth(context, 2.5);
    for (double h = left; h < right; h += 600.0) {
		CGContextMoveToPoint(context, h, top - 20);
		CGContextAddLineToPoint(context, h, bottom);
		CGContextStrokePath(context);
	}
    
    //四分線
    CGContextSetLineWidth(context, 1.0);
	for (double h = left; h < right; h += 150.0) {
		CGContextMoveToPoint(context, h, top);
		CGContextAddLineToPoint(context, h, bottom);
		CGContextStrokePath(context);
	}
    
    //TOPの線
    CGContextSetLineWidth(context, 2.5);
    CGContextMoveToPoint(context, 50, top);
    CGContextAddLineToPoint(context, 9650, top);
    CGContextStrokePath(context);
    //BOTTOMの線
    CGContextMoveToPoint(context, 50, bottom);
    CGContextAddLineToPoint(context, 9650, bottom);
    CGContextStrokePath(context);
    
    
    //PAN用
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 50, top+130);
    CGContextAddLineToPoint(context, 9650, top+130);
    CGContextStrokePath(context);
    
    //CGContextSetLineWidth(context, 1.5);
    CGContextMoveToPoint(context, 50, top+260);
    CGContextAddLineToPoint(context, 9650, top+260);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, 50, top+408);
    CGContextAddLineToPoint(context, 9650, top+408);
    CGContextStrokePath(context);
    
    //CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 50, top+538);
    CGContextAddLineToPoint(context, 9650, top+538);
    CGContextStrokePath(context);
    
    
    
    
    //八分線
    CGContextSetLineWidth(context, 1.0);
    CGFloat dashStyle[] = {4.0};
    CGContextSetLineDash(context, 0.0, dashStyle, 1);
    for (int i=125; i < right; i += 150) {
        CGContextMoveToPoint(context, i, top);
		CGContextAddLineToPoint(context, i, bottom);
		CGContextStrokePath(context);
    }
    
    //十六分線
    CGContextSetLineWidth(context, 1.0);
    CGFloat dashStyle16[] = {1.0};
    CGContextSetLineDash(context, 0.0, dashStyle16, 1);
    for (int i=87.5; i < right - 50; i += 75) {
        CGContextMoveToPoint(context, i, top);
		CGContextAddLineToPoint(context, i, bottom);
		CGContextStrokePath(context);
    }


    
//    // create bezierPath instance
//    UIBezierPath *aPath = [UIBezierPath bezierPath];
//    
//    // set render color and style
//    [[UIColor blackColor] setStroke];
//    aPath.lineWidth = 5;
//    
//    // set start point
//    [aPath moveToPoint:CGPointMake(100, 0)];
//    
//    //draw line
//    [aPath addLineToPoint:CGPointMake(200, 40)];
//    [aPath addLineToPoint:CGPointMake(160, 140)];
//    [aPath addLineToPoint:CGPointMake(40, 140)];
//    [aPath addLineToPoint:CGPointMake(0, 40)];
//    
//    // close path so that successed to create pentagon.
//    [aPath closePath];
//    
//    //rendering
//    [aPath stroke];
}


@end
