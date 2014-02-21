//
//  handleView.m
//  ono1
//
//  Created by JO ARIMA on 2013/01/10.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import "handleView.h"

@implementation handleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.handlename = nil;
        self.originalSize_width = 0;
        self.originalSize_height = 0;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
