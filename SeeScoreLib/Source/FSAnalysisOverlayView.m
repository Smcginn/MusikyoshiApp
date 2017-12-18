//
//  FSAnalysisOverlayView.m
//  FirstStage
//
//  Created by Scott Freshour on 10/31/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

#import "FSAnalysisOverlayView.h"

// If true, adds Sound and Note data overlay (for debugging, not for release)

// If this is false, won't draw anything to do with Sounds And Note Analysis
// If ttrue, will consult the other consts for drawing Notes or Sounds
const bool kMKDebugOpt_ShowSoundsAndNoteAnalysis = true;

const bool kMKDebugOpt_ShowNotesAnalysis = true;
const bool kMKDebugOpt_ShowSoundsAnalysis = false;

// For storing the display data for a single note
@interface NoteDisplayData : NSObject
@property (nonatomic) float xPos;
@property (nonatomic) int   weightedRating;
@property (nonatomic) int   rhythmResult;
@property (nonatomic) int   pitchResult;
@property (nonatomic) int   noteID;
@property (nonatomic) bool  isLinked;
@property (nonatomic) int   linkedSoundID;
@end

@implementation NoteDisplayData
@end


@interface SoundDisplayData : NSObject
@property (nonatomic) float xPos;
@property (nonatomic) int   duration;
@property (nonatomic) int   soundID;
@property (nonatomic) bool  isLinked;
@property (nonatomic) int   linkedNoteID;
@end

@implementation SoundDisplayData
@end

@interface FSAnalysisOverlayView ()
{
    NSMutableArray*  _notes;
    NSMutableArray*  _sounds;
}
@end


@implementation FSAnalysisOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _notes  = [[NSMutableArray alloc] init];
        _sounds = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void) addNoteAtXPos:(CGFloat) iXPos
   withWeightedRating:(int) iWeightedRating
        withRhythmRes:(int) iRhythmResult
         withPitchRes:(int) iPitchResult
               noteID:(int) iNoteID
             isLinked:(bool)isLinked
        linkedSoundID:(int) iLinkedSoundID
{
    for (NoteDisplayData* noteData in _notes)
    {
        float x = noteData.xPos;
        if (x == iXPos) // already an entry. Just update the exisiting one
        {
            noteData.weightedRating = iWeightedRating;
            noteData.rhythmResult = iRhythmResult;
            noteData.pitchResult =  iPitchResult;
            noteData.noteID =  iNoteID;
            noteData.isLinked =  isLinked;
            noteData.linkedSoundID =  iLinkedSoundID;
            return;
        }
    }
    
    // if still here, then didn't find existing entry.  Add one.
    NoteDisplayData* noteData = [[NoteDisplayData alloc] init];
    noteData.xPos = iXPos;
    noteData.weightedRating = iWeightedRating;
    noteData.rhythmResult = iRhythmResult;
    noteData.pitchResult = iPitchResult;
    noteData.noteID =  iNoteID;
    noteData.isLinked =  isLinked;
    noteData.linkedSoundID =  iLinkedSoundID;
    
    [_notes addObject: noteData];
    
    [self redrawMe];
}
 
 -(void) addSoundAtXPos:(CGFloat) iXPos
           withDuration:(int) iDuration
                soundID:(int) iSoundID
               isLinked:(bool)isLinked
           linkedNoteID:(int) iLinkedNoteID
 {
     for (SoundDisplayData* soundData in _sounds)
     {
         float x = soundData.xPos;
         if (x == iXPos) // already an entry. Just update the exisiting one
         {
             soundData.duration = iDuration;
             soundData.soundID =  iSoundID;
             soundData.isLinked =  isLinked;
             soundData.linkedNoteID =  iLinkedNoteID;
             return;
         }
     }
     
     // if still here, then didn't find existing entry.  Add one.
     SoundDisplayData* soundData = [[SoundDisplayData alloc] init];
     soundData.xPos = iXPos;
     soundData.duration = iDuration;
     soundData.soundID =  iSoundID;
     soundData.isLinked =  isLinked;
     soundData.linkedNoteID =  iLinkedNoteID;
     
     [_sounds addObject: soundData];
     
     [self redrawMe];
}

-(int) findNoteIDFromXPos: (int) iXpos {
    int retVal = -1; // not found
    
    float lowerBnd = iXpos - 15;
    float upperBnd = iXpos + 15;
    
    for (NoteDisplayData* noteData in _notes)
    {
        float x = noteData.xPos;
        if ( x > lowerBnd && x < upperBnd )
            retVal = noteData.noteID;
    }
    
    return retVal;
}

-(void) clearPerfNoteAndSoundData
{
    [_notes removeAllObjects];
    [_sounds removeAllObjects];
    [self redrawMe];
}

-(void) redrawMe
{
    CGRect rct = self.frame;
    [self setNeedsDisplayInRect:rct];
}

-(void) redrawAt:(CGFloat) iCenterXPos
{
    CGRect rct = self.frame;
    [self setNeedsDisplayInRect:rct];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (!kMKDebugOpt_ShowSoundsAndNoteAnalysis) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    const CGFloat kNoteBottomY  = 130.0f;
    const CGFloat kSoundBTopY   = 150.0f;
    const CGFloat kSoundBottomY = 155.0f;
    const CGFloat kSoundHeight  = kSoundBottomY - kSoundBTopY;
    
    if ( kMKDebugOpt_ShowNotesAnalysis )
    {
        // Draw descending lines and circles to represent Notes and grading
        for (NoteDisplayData* noteData in _notes)
        {
            float x = noteData.xPos;
            
            // on a scale of 1-15, with 0 the best . . .
            CGFloat weightedRatio = (CGFloat)noteData.weightedRating / 15.0f;
            if ( weightedRatio > 1.0 )
                weightedRatio = 1.0;
            if ( weightedRatio == 0.0 )
                weightedRatio = 0.1;
            
            CGFloat a = 0.1 + (0.6 * weightedRatio);
            CGFloat red   = weightedRatio;
            CGFloat green = red > 0.3 ? 0.0 : 1-red;
            UIColor *circleColor = [UIColor colorWithRed:red green:green blue:0 alpha:a];
            
            // Draw the circle
            CGRect circleRect = CGRectMake(x-5.0f, 130.0f, 10.0, 10.0);
            CGContextSetStrokeColorWithColor (ctx, circleColor.CGColor);
            CGContextSetFillColorWithColor(ctx, circleColor.CGColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextFillEllipseInRect (ctx, circleRect);
            CGContextStrokeEllipseInRect(ctx, circleRect);
            CGContextFillPath(ctx);
            
            // Draw vertical line through note
            UIColor* vertLineColor = [circleColor colorWithAlphaComponent: a * 0.5];
            CGContextSetStrokeColorWithColor (ctx, vertLineColor.CGColor);
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, x, 20.0f);
            CGContextAddLineToPoint(ctx, x, kNoteBottomY);
            CGContextSetLineWidth(ctx, 3.0f);
            CGContextStrokePath(ctx);
            
            // print the note # to the right of the note
            NSString* numstr = [NSString stringWithFormat:@"%d",noteData.noteID];
            CGRect rect = CGRectMake(x+10, kNoteBottomY-3, 20, 20);
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:10]};
            [numstr drawInRect:rect withAttributes:attributes];
        }
    }
    
    if ( kMKDebugOpt_ShowSoundsAnalysis )
    {
        // Draw boxes to represent Sound Objects
        int stagger = 0;
        for (SoundDisplayData* soundData in _sounds)
        {
            float x     = soundData.xPos;
            int dur     = soundData.duration;
            bool linked = soundData.isLinked;
            float y = 0.0;
            
            if (linked)
            {
                // stagger the linked sounds so can see any issues representing legato notes
                if (stagger == 0) {
                    y = kSoundBTopY;
                    stagger = 1;
                }
                else {
                    y = kSoundBTopY + kSoundHeight + 2;
                    stagger = 0;
                }
            }
            else // Draw the unlinked sounds below the rows of linked
                y = kSoundBTopY + (2*kSoundHeight) + 5;
            
            // Linked sounds green, unlinked red.
            UIColor* color = linked ? [UIColor greenColor]
                                    : [UIColor redColor];
            
            CGRect soundRect = CGRectMake(x, y, dur, kSoundHeight);
            CGContextSetStrokeColorWithColor (ctx, color.CGColor);
            CGContextSetFillColorWithColor(ctx, color.CGColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokeRect(ctx, soundRect);
            CGContextFillPath(ctx);
            
            // print the sound # below the sound. They might jam together, but that's okay
            NSString* numstr = [NSString stringWithFormat:@"%d",soundData.soundID];
            y -= 2;
            CGRect rect = CGRectMake(x, y, 20, 20);
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:10]};
            [numstr drawInRect:rect withAttributes:attributes];
        }
    }
}

@end
