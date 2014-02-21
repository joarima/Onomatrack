//
//  onoINScording.m
//  ono1
//
//  Created by JO ARIMA on 2013/01/02.
//  Copyright (c) 2013年 JO ARIMA. All rights reserved.
//

#import "onoINScording.h"

@implementation onoINScording
- (id)initWithCoder:(NSCoder *)decoder {
    NSData *pngData = [decoder decodeObjectForKey:@"PNGRepresentation"];
    //[self autorelease];
    self = [[onoINScording alloc] initWithData:pngData];
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:UIImagePNGRepresentation(self) forKey:@"PNGRepresentation"];
}
@end
