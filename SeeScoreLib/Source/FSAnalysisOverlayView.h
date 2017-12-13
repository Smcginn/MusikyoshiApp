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
- (void)noteTappedWithThisID:(int)noteID;

@end


@interface FSAnalysisOverlayView : UIView

-(void) addNoteAtXPos:(CGFloat) iXPos
   withWeightedRating:(int) iWeightedRating
        withRhythmRes:(int) iRhythmResult
         withPitchRes:(int) iPitchResult
               noteID:(int) iNoteID
             isLinked:(bool) isLinked
        linkedSoundID:(int) iLinkedSoundID;

-(void) addSoundAtXPos:(CGFloat) iXPos
          withDuration:(int) iDuration
               soundID:(int) iSoundID
              isLinked:(bool) isLinked
          linkedNoteID:(int) iLinkedNoteID;

-(int) findNoteIDFromXPos: (int) iXpos;

-(void) clearPerfNoteAndSoundData;

-(void) redrawMe;

@end
