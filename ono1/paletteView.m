//
//  paletteView.m
//  ono1
//
//  Created by JO ARIMA on 2012/12/29.
//  Copyright (c) 2012年 JO ARIMA. All rights reserved.
//

#import "paletteView.h"

@implementation paletteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


////コンテキストの指定(1)
//- (void)setContext:(CGContextRef)context {
//    if (_context!=NULL) {
//        CGContextRelease(_context);
//        _context=NULL;
//    }
//    _context=context;
//    CGContextRetain(_context);
//}
//
////色の指定(2)
//- (void)setColor_r:(int)r g:(int)g b:(int)b {
//    CGContextSetRGBFillColor(
//                             _context,r/255.0f,g/255.0f,b/255.0f,1.0f);
//    CGContextSetRGBStrokeColor(
//                               _context,r/255.0f,g/255.0f,b/255.0f,1.0f);
//}
//
////ライン幅の指定(3)
//- (void)setLineWidth:(float)width {
//    CGContextSetLineWidth(_context,width);
//}
//
////ラインの描画(3)
//- (void)drawLine_x0:(float)x0 y0:(float)y0 x1:(float)x1 y1:(float)y1 {
//    CGContextSetLineCap(_context,kCGLineCapRound);
//    CGContextMoveToPoint(_context,x0,y0);
//    CGContextAddLineToPoint(_context,x1,y1);
//    CGContextStrokePath(_context);
//}
//
////ポリラインの描画(3)
//- (void)drawPolyline_x:(float[])x y:(float[])y length:(int)length {
//    CGContextSetLineCap(_context,kCGLineCapRound);
//    CGContextSetLineJoin(_context,kCGLineJoinRound);
//    CGContextMoveToPoint(_context,x[0],y[0]);
//    for (int i=1;i<length;i++) {
//        CGContextAddLineToPoint(_context,x[i],y[i]);
//    }
//    CGContextStrokePath(_context);
//}
//
////四角形の描画(4)
//- (void)drawRect_x:(float)x y:(float)y w:(float)w h:(float)h {
//    CGContextMoveToPoint(_context,x,y);
//    CGContextAddLineToPoint(_context,x+w,y);
//    CGContextAddLineToPoint(_context,x+w,y+h);
//    CGContextAddLineToPoint(_context,x,y+h);
//    CGContextAddLineToPoint(_context,x,y);
//    CGContextAddLineToPoint(_context,x+w,y);
//    CGContextStrokePath(_context);
//}
//
////四角形の塗り潰し(4)
//- (void)fillRect_x:(float)x y:(float)y w:(float)w h:(float)h {
//    CGContextFillRect(_context,CGRectMake(x,y,w,h));
//}
//
////円の描画(5)
//- (void)drawCircle_x:(float)x y:(float)y w:(float)w h:(float)h {
//    CGContextAddEllipseInRect(_context,CGRectMake(x,y,w,h));
//    CGContextStrokePath(_context);
//}
//
////円の塗り潰し(5)
//- (void)fillCircle_x:(float)x y:(float)y w:(float)w h:(float)h {
//    CGContextFillEllipseInRect(_context,CGRectMake(x,y,w,h));
//}

//初期化
- (id)initWithCoder:(NSCoder*)coder {
    self=[super initWithCoder:coder];
    if (self) {
                //_context=NULL;
    }
    return self;
}

//メモリ解放
//- (void)dealloc {
//    [self setContext:NULL];
//    [super dealloc];
//}

//描画
- (void)drawRect:(CGRect)rect {
    //    //グラフィックスコンテキストの取得(1)
//    [self setContext:UIGraphicsGetCurrentContext()];
//    
//    //色の指定(2)
//    [self setColor_r:150 g:150 b:150];
//    
//    //背景のクリア
//    [self fillRect_x:0 y:0
//                   w:self.frame.size.width h:self.frame.size.height];
//    
//    //ラインの描画(3)
//    [self setColor_r:255 g:0 b:0];
//    [self setLineWidth:2];
//    [self drawLine_x0:25 y0:5 x1:25 y1:5+40];
//    
//    //ポリラインの描画(3)
//    float dx[]={55+0,55+30,55+10,55+40,55+0};
//    float dy[]={5+0,5+5,5+20,5+25,5+40};
//    [self setColor_r:255 g:0 b:0];
//    [self setLineWidth:3];
//    [self drawPolyline_x:dx y:dy length:5];
//    
//    //四角形の描画(4)
//    [self setColor_r:0 g:255 b:0];
//    [self setLineWidth:1];
//    [self drawRect_x:5 y:50 w:40 h:40];
//    
//    //四角形の塗り潰し(4)
//    [self setColor_r:0 g:255 b:0];
//    [self setLineWidth:1];
//    [self fillRect_x:55 y:50 w:40 h:40];
//    
//    //円の描画(5)
//    [self setColor_r:0 g:0 b:255];
//    [self drawCircle_x:5 y:100 w:40 h:40];
//    
//    //円の塗り潰し(5)
//    [self setColor_r:0 g:0 b:255];
//    [self fillCircle_x:55 y:100 w:40 h:40];

}

@end
