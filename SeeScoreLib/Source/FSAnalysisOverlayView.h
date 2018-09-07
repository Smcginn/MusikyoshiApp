//
//  FSAnalysisOverlayView.h
//  FirstStage
//
//  Created by Scott Freshour on 10/31/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma once

// This is the amount the parent scroll view should scroll when a note on the
// score is highlighted. (This shifts the note to the right.) Without an offset,
// the parent scroll view will align the left edge of the view directly on the
// center of the note.
static const CGFloat kHighlightNoteXOffset = 70;

// These allow/suppress the drawing of Performance Notes and Sounds below the
// Notes on the SeeScore view. These are strictly debug at the moment, but could
// be enhanced to as a user feature at some point.
//
// kMKDebugOpt_ShowNotesAnalysis also controls responding to touch on the note
// by popping up a dialog displaying the performance details of the note.
//
//   These are left unassigned so they can be changed at runtime in development
//   mode (via the class setters below). For Release, the dialog that can change
//   them is never displayed.
static bool kMKDebugOpt_ShowNotesAnalysis;
static bool kMKDebugOpt_ShowSoundsAnalysis;

@protocol OverlayViewDelegate

@required
- (void)noteTappedWithThisID:(int)noteID;

@end


@interface FSAnalysisOverlayView : UIView

+(BOOL) getShowNotesAnalysis;
+(void) setShowNotesAnalysis: (BOOL)iShowNotes;

+(BOOL) getShowSoundsAnalysis;
+(void) setShowSoundsAnalysis: (BOOL)iShowSounds;

-(void) addScoreObjectAtXPos:(CGFloat) iXPos
                      atYpos:(CGFloat) iYPos
          withWeightedRating:(int) iWeightedRating
                      isNote:(bool)isNote
            withNoteOrRestID:(int) iNoteOrRestID
               scoreObjectID:(int) iScoreObjectID
                    isLinked:(bool) isLinked
               linkedSoundID:(int) iLinkedSoundID;

-(void) addSoundAtXPos:(CGFloat) iXPos
          withDuration:(int) iDuration
               soundID:(int) iSoundID
              isLinked:(bool) isLinked
          linkedNoteID:(int) iLinkedNoteID;

-(int) findScoreObjectIDFromXPos: (int) iXpos;

// scroll to and highlight note (with red circle) with this PerfromanceNote ID
-(bool) highlightScoreObject:(int) iScoreObjectID
                     useXPos:(CGFloat*) ioXPos
                    severity:(int) iSeverity;

-(void) hideHighlight;

-(void) clearPerfNoteAndSoundData;

-(void) redrawMe;

-(void) clearCurrNoteLines;
-(void) drawCurrNoteLineAt:(CGFloat) iXPos;

@end
