//
//  SSUpdateScrollProtocol.h
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//

#import <Foundation/Foundation.h>

@protocol SSUpdateScrollProtocol

// called on (potential) scroll position change
-(void)changedScroll;

// called on (potential) change of zoom
-(void)changedZoom;

@end
