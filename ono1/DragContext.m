//
//  Created by jve on 4/2/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DragContext.h"
#import "ViewController.h"


@implementation DragContext {

    /*UIView*/onoImageView *_draggedView;
    CGPoint _originalPosition;
    UIView *_originalView;
    UIView *_testview;
    NSMutableArray* _draggedSubjects;
}
@synthesize draggedView = _draggedView;
@synthesize originalView = _originalView;
@synthesize testview = _testview;
@synthesize draggedSubjects = _draggedSubjects;

- (id)initWithDraggedView:(/*UIView*/onoImageView *)draggedView andDroppableareas:(NSMutableArray *)dropareas andDragSubjects:(NSMutableArray *)dragSubjects{
    self = [super init];
    if (self) {
        _draggedView = draggedView;
        _originalPosition = _draggedView.frame.origin;
        _draggedSubjects = dragSubjects;
        _originalView = dropareas[1];
        _testview = dropareas[0];
        _lastpoint = CGPointMake(0, 0);
        //_originalView = draggedView.superview;//ここがdraggedView.superview.superviewになる？viewControllerの上にscrollViewがあるので
    }

    return self;
}

-(id)initWithDraggedHandle:(handleView *)draggedhandle andDroppableareas:(NSMutableArray *)dropareas andDragImage:(onoImageView *)imageWithHandle{
    self = [super init];
    if (self) {
        _imageWithHandle = imageWithHandle;
        _draggedhandle = draggedhandle;
        _originalPosition = _draggedhandle.frame.origin;
        _originalView = dropareas[0];
        _lastHandleFrameX = 0;
        _lastHandleFrameY = 0;
        _isHandleDragged = YES;
    }
    return self;
}

-(id)initWithPlayHead:(UIImageView *)playHead andDroppableareas:(NSMutableArray *)dropareas{
    if(self){
        _playHead = playHead;
        _originalPosition = _playHead.frame.origin;
        _originalView = dropareas[0];
    }
    return self;
}

- (void)dealloc {
   // [_draggedView release];
    //[_originalView release];
    //[super dealloc];
}


- (void)snapToOriginalPosition:(BOOL)unknown{
    [UIView animateWithDuration:0.3 animations:^() {    
        if (_draggedView.isInCanvas == NO) {
        CGPoint originalPointInSuperView = [_draggedView.superview convertPoint:_originalPosition fromView:_originalView];
        _draggedView.frame = CGRectMake(originalPointInSuperView.x, originalPointInSuperView.y, _draggedView.frame.size.width, _draggedView.frame.size.height);
        }
//        else if (_draggedView.isInCanvas == YES && unknown == NO){
//            [_draggedView removeFromSuperview];
//            [_originalView addSubview:_draggedView];
//            
//            for (onoImageView* dragsubject in _draggedSubjects) {
//                if (_draggedView.imageName == dragsubject.imageName) {
//                    _draggedView.frame = CGRectMake(dragsubject.frame.origin.x, dragsubject.frame.origin.y, _draggedView.frame.size.width, _draggedView.frame.size.height);
//                }
//            }
//        }
        else{
            for (onoImageView* dragsubject in _draggedSubjects) {
                if (_draggedView.imageName == dragsubject.imageName) {
                    _draggedView.frame = CGRectMake(dragsubject.frame.origin.x, dragsubject.frame.origin.y, _draggedView.frame.size.width, _draggedView.frame.size.height);
                }
            }
        }
    } completion:^(BOOL finished) {
      
            _draggedView.frame = CGRectMake(_originalPosition.x, _originalPosition.y, _draggedView.frame.size.width, _draggedView.frame.size.height);
        //[_draggedSubjects removeObject:_draggedView];
        [_draggedView removeFromSuperview];
        
        //[_originalView addSubview:_draggedView];
    }];
}
@end