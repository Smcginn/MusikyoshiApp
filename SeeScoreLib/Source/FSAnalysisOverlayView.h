//
//  FSAnalysisOverlayView.h
//  FirstStage
//
//  Created by Scott Freshour on 10/31/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OverlayViewDelegate

@required
- (void)noteTappedAtXCoord:(int)xCoord;

@end


@interface FSAnalysisOverlayView : UIView

/*!
 * @property overlayViewDelegate
 * @abstract for FSAnalysisOverlayView update
 */
@property (nonatomic,assign) id<OverlayViewDelegate> overlayViewDelegate;

-(void) addHitAtXPos:(CGFloat) iXPos
       withRhythmRes:(int) iRhythmResult
        withPitchRes:(int) iPitchResult;

-(void) updateHitAtXPos:(CGFloat) iXPos
          withRhythmRes:(int) iRhythmResult
           withPitchRes:(int) iPitchResult;

-(void) clearHitAtXPos:(CGFloat) iXPos;

-(void) clearAllHits;

-(void) redrawMe;

@end
