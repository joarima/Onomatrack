//
//  Created by jve on 4/2/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "onoImageView.h"

@interface DragContext : NSObject
@property(nonatomic, retain, readonly) /*UIView*/onoImageView *draggedView;
@property(nonatomic, retain) UIView *originalView;
@property(nonatomic, retain) UIView *testview;
@property(nonatomic, retain) NSMutableArray *draggedSubjects;

@property(nonatomic, retain) handleView* draggedhandle;
@property(nonatomic, retain) onoImageView* imageWithHandle;
@property int lastHandleFrameX;
@property int lastHandleFrameY;

@property BOOL isHandleDragged;

@property(nonatomic, retain) UIImageView* playHead;
@property CGPoint lastpoint;

- (id)initWithDraggedView:(onoImageView *)draggedView andDroppableareas:(NSMutableArray*)dropareas andDragSubjects:(NSMutableArray*)dragSubjects;

-(id)initWithDraggedHandle:(handleView*)draggedhandle andDroppableareas:(NSMutableArray *)dropareas andDragImage:(onoImageView*)imageWithHandle;
- (void)snapToOriginalPosition:(BOOL)unknown;

-(id)initWithPlayHead:(UIImageView*)playHead andDroppableareas:(NSMutableArray *)dropareas;
@end