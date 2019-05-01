//
//  FSAnalysisOverlayView.m
//  FirstStage
//
//  Created by Scott Freshour on 10/31/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

#import "FSAnalysisOverlayView.h"

static const int kNoHighlight     = -1;
static const int kGreenHighlight  = 0;
static const int kYellowHighlight = 1;
static const int kRedHighlight    = 2;

// static const int kSeverityNone    = 0;
static const int kSeverityGreen   = 0;
static const int kSeverityYellow  = 1;
static const int kSeverityRed     = 2;



// For storing the display data for a single note
@interface NoteDisplayData : NSObject
@property (nonatomic) float xPos;
@property (nonatomic) float yPos;
@property (nonatomic) int   weightedRating;
@property (nonatomic) bool  isNote;
@property (nonatomic) int   noteOrRestID;
@property (nonatomic) int   scoreObjectID;
@property (nonatomic) bool  isLinked;
@property (nonatomic) int   linkedSoundID;
@property (nonatomic) bool  highlight;
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
    
    // This is a red, transparent circle, that will pulse when animated, which
    // encircles a note to show which note a video or alert is referring to.
    CAShapeLayer*    _redHighlightLayer;
    CAShapeLayer*    _greenHighlightLayer;
    CAShapeLayer*    _yellowHighlightLayer;
    
    CALayer*    _monkeyLayer;
    
    BOOL        _kDoDrawNoteLines;  // general: turn feature on/off
    BOOL        _doDrawNoteLine;    // for a single note
    CGFloat     _noteLineXPos;
    
    int         _whichHighlight;
}
@end

@implementation FSAnalysisOverlayView

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _notes  = [[NSMutableArray alloc] init];
        _sounds = [[NSMutableArray alloc] init];
        _kDoDrawNoteLines = YES;
        
        [self createRedHighlightCircleLayer: self];
        [self createGreenHighlightCircleLayer: self];
        [self createYellowHighlightCircleLayer: self];

        // These should be checked in as NO for release mode.
        [FSAnalysisOverlayView  setShowSoundsAnalysis: NO];
        [FSAnalysisOverlayView  setShowNotesAnalysis: NO];
        
        _whichHighlight = kNoHighlight;
    }
    
    return self;
}

+(BOOL) getShowNotesAnalysis
{
    return kMKDebugOpt_ShowNotesAnalysis;
}

+(void) setShowNotesAnalysis: (BOOL)iShowNotes
{
    kMKDebugOpt_ShowNotesAnalysis = iShowNotes;
}

+(BOOL) getShowSoundsAnalysis {
    return kMKDebugOpt_ShowSoundsAnalysis;
}

+(void) setShowSoundsAnalysis: (BOOL)iShowSounds
{
    kMKDebugOpt_ShowSoundsAnalysis = iShowSounds;
}

#pragma mark - Red Circle Highlight Related

-(void) createRedHighlightCircleLayer:(UIView*) view
{
    _redHighlightLayer = [CAShapeLayer new];
    _redHighlightLayer.contentsScale = [UIScreen mainScreen].scale;
    _redHighlightLayer.lineWidth = 2.0;
    _redHighlightLayer.fillColor =
            [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.05].CGColor;
    _redHighlightLayer.strokeColor =
            [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2].CGColor;
    
    const CGFloat kHLRadius =  40.0f;
    CGMutablePathRef p = CGPathCreateMutable();
    CGRect circRect = CGRectMake(-kHLRadius, -kHLRadius, kHLRadius*2, kHLRadius*2);
    CGPathAddEllipseInRect(p, nil, circRect );
    _redHighlightLayer.path = p;
    _redHighlightLayer.opaque = NO;
    _redHighlightLayer.drawsAsynchronously = YES;
    [_redHighlightLayer setHidden: YES];
    
    CGRect frm = _redHighlightLayer.frame;
    frm.origin.x = 100;
    _redHighlightLayer.frame = frm;

    [view.layer addSublayer: _redHighlightLayer];
}

-(void) createGreenHighlightCircleLayer:(UIView*) view
{
    _greenHighlightLayer = [CAShapeLayer new];
    _greenHighlightLayer.contentsScale = [UIScreen mainScreen].scale;
    _greenHighlightLayer.lineWidth = 2.0;
    _greenHighlightLayer.fillColor =
            [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.07].CGColor;
    _greenHighlightLayer.strokeColor =
            [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.25].CGColor;
    
    const CGFloat kHLRadius =  40.0f;
    CGMutablePathRef p = CGPathCreateMutable();
    CGRect circRect = CGRectMake(-kHLRadius, -kHLRadius, kHLRadius*2, kHLRadius*2);
    CGPathAddEllipseInRect(p, nil, circRect );
    _greenHighlightLayer.path = p;
    _greenHighlightLayer.opaque = NO;
    _greenHighlightLayer.drawsAsynchronously = YES;
    [_greenHighlightLayer setHidden: YES];
    
    CGRect frm = _greenHighlightLayer.frame;
    frm.origin.x = 100;
    _greenHighlightLayer.frame = frm;
    
    [view.layer addSublayer: _greenHighlightLayer];
}

-(void) createYellowHighlightCircleLayer:(UIView*) view
{
    _yellowHighlightLayer = [CAShapeLayer new];
    _yellowHighlightLayer.contentsScale = [UIScreen mainScreen].scale;
    _yellowHighlightLayer.lineWidth = 3.0;
    _yellowHighlightLayer.fillColor =
            [UIColor colorWithRed:0.84 green:0.62 blue:0.0 alpha:0.1].CGColor;
    _yellowHighlightLayer.strokeColor =
            [UIColor colorWithRed:0.84 green:0.62 blue:0.0 alpha:0.25].CGColor;
    
    const CGFloat kHLRadius =  40.0f;
    CGMutablePathRef p = CGPathCreateMutable();
    CGRect circRect = CGRectMake(-kHLRadius, -kHLRadius, kHLRadius*2, kHLRadius*2);
    CGPathAddEllipseInRect(p, nil, circRect );
    _yellowHighlightLayer.path = p;
    _yellowHighlightLayer.opaque = NO;
    _yellowHighlightLayer.drawsAsynchronously = YES;
    [_yellowHighlightLayer setHidden: YES];
    
    CGRect frm = _yellowHighlightLayer.frame;
    frm.origin.x = 100;
    _yellowHighlightLayer.frame = frm;
    
    [view.layer addSublayer: _yellowHighlightLayer];
}

-(void) showHighlight
{
    if (_whichHighlight == kRedHighlight)
        [_redHighlightLayer setHidden: NO];
    else if (_whichHighlight == kGreenHighlight)
        [_greenHighlightLayer setHidden: NO];
    else
        [_yellowHighlightLayer setHidden: NO];
}

-(void) hideHighlight
{
    [self stopHighlightAnim];
    [_redHighlightLayer setHidden: YES];
    [_greenHighlightLayer setHidden: YES];
    [_yellowHighlightLayer setHidden: YES];
}

-(void) moveHightlightTo:(CGPoint) pos
{
    _redHighlightLayer.position = pos;
    _greenHighlightLayer.position = pos;
    _yellowHighlightLayer.position = pos;
}

-(void) startHighlightAnim
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.toValue   = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)];
    anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    anim.repeatCount = HUGE_VALF;
    anim.autoreverses = YES;
    if (_whichHighlight == kRedHighlight)
        [_redHighlightLayer addAnimation: anim forKey:nil];
    else if (_whichHighlight == kGreenHighlight)
        [_greenHighlightLayer addAnimation: anim forKey:nil];
    else
        [_yellowHighlightLayer addAnimation: anim forKey:nil];
}

-(void) stopHighlightAnim
{
    [self.layer removeAllAnimations];
    [_redHighlightLayer removeAllAnimations];
    [_greenHighlightLayer removeAllAnimations];
    [_yellowHighlightLayer removeAllAnimations];
}

// If note found, hightlight it, set ioXPos, and return true; return false otherwise
// param ioXPos: on return, set to xPos the caller should scroll to
-(bool) highlightScoreObject:(int) iScoreObjectID
                     useXPos:(CGFloat*) ioXPos
                    severity:(int) iSeverity
{
    switch( iSeverity ) {
        case kSeverityRed:     _whichHighlight = kRedHighlight;    break;
        case kSeverityGreen:   _whichHighlight = kGreenHighlight;  break;
        case kSeverityYellow:  _whichHighlight = kYellowHighlight;
    }
  
    *ioXPos = 0.0;
    for (NoteDisplayData* scoreObjectData in _notes)
    {
        if (scoreObjectData.scoreObjectID == iScoreObjectID)
        {
            *ioXPos = scoreObjectData.xPos;
            scoreObjectData.highlight = true;
            
            CGPoint pos = CGPointMake(scoreObjectData.xPos, scoreObjectData.yPos);
            [self moveHightlightTo: pos];
            [self showHighlight];
            [self startHighlightAnim];
            return true;
        }
    }
    return false;
}

#pragma mark - Performance Sound and Note related

-(void) addScoreObjectAtXPos:(CGFloat) iXPos
                      atYpos:(CGFloat) iYPos
          withWeightedRating:(int) iWeightedRating
                      isNote:(bool)isNote
            withNoteOrRestID:(int) iNoteOrRestID
               scoreObjectID:(int) iScoreObjectID
                    isLinked:(bool)isLinked
               linkedSoundID:(int) iLinkedSoundID
{
    for (NoteDisplayData* noteData in _notes)
    {
        float x = noteData.xPos;
        if (x == iXPos) // already an entry. Just update the exisiting one
        {
            noteData.weightedRating = iWeightedRating;
            noteData.isNote = isNote;
            noteData.noteOrRestID = iNoteOrRestID;
            noteData.yPos =  iYPos;
            noteData.scoreObjectID =  iScoreObjectID;
            noteData.isLinked =  isLinked;
            noteData.linkedSoundID =  iLinkedSoundID;
            noteData.highlight = false;
            return;
        }
    }
    
    // if still here, then didn't find existing entry.  Add one.
    NoteDisplayData* noteData = [[NoteDisplayData alloc] init];
    noteData.xPos = iXPos;
    noteData.yPos = iYPos;
    noteData.weightedRating = iWeightedRating;
    noteData.isNote = isNote;
    noteData.noteOrRestID = iNoteOrRestID; 
    noteData.scoreObjectID =  iScoreObjectID;
    noteData.isLinked =  isLinked;
    noteData.linkedSoundID =  iLinkedSoundID;
    noteData.highlight = false;
    
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

-(int) findScoreObjectIDFromXPos: (int) iXpos {
    int retVal = -1; // not found
    
    float lowerBnd = iXpos - 15;
    float upperBnd = iXpos + 15;
    
    for (NoteDisplayData* noteData in _notes)
    {
        float x = noteData.xPos;
        if ( x > lowerBnd && x < upperBnd )
            retVal = noteData.scoreObjectID;
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

-(void) drawCurrNoteLineAt:(CGFloat) iXPos
{
    if (_kDoDrawNoteLines)
    {
        _doDrawNoteLine = true;
        _noteLineXPos = iXPos;
        CGRect rct = self.frame;
        [self setNeedsDisplayInRect:rct];
    }
}

-(void) clearCurrNoteLines
{
    _doDrawNoteLine = false;
    CGRect rct = self.frame;
    [self setNeedsDisplayInRect:rct];
}

-(void) drawRect:(CGRect)rect
{
    NSLog(@"\n   ******** -> In FSAnalysisOverlayView::drawRect\n");
    
    [super drawRect:rect];
    
    if ( !(kMKDebugOpt_ShowSoundsAnalysis ||
           kMKDebugOpt_ShowNotesAnalysis ||
           _kDoDrawNoteLines) )
    {  return; }

    const CGFloat kNoteBottomY  = 130.0f;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if (_kDoDrawNoteLines && _doDrawNoteLine)
    {
        UIColor* vertLineColor = [UIColor redColor]; // colorWithAlphaComponent: a * 0.5];
        CGContextSetStrokeColorWithColor (ctx, vertLineColor.CGColor);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, _noteLineXPos, 20.0f);
        CGContextAddLineToPoint(ctx, _noteLineXPos, kNoteBottomY);
        CGContextSetLineWidth(ctx, 3.0f);
        CGContextStrokePath(ctx);
    }

    if ( !(kMKDebugOpt_ShowSoundsAnalysis || kMKDebugOpt_ShowNotesAnalysis) ) {
        return;
    }
    
    const CGFloat kSoundBTopY   = 150.0f;
    const CGFloat kSoundBottomY = 155.0f;
    const CGFloat kSoundHeight  = kSoundBottomY - kSoundBTopY;
    
    if ( kMKDebugOpt_ShowNotesAnalysis )
    {
        // Draw descending lines and circles to represent Notes and grading
        for (NoteDisplayData* noteData in _notes)
        {
            float x = noteData.xPos;
            
            // on a scale of 1-20-ish, with 0 the best . . .
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
            NSString* numstr = @"";
            if (noteData.isNote)
                numstr = [NSString stringWithFormat:@"N%d",noteData.noteOrRestID];
            else
                numstr = [NSString stringWithFormat:@"R%d",noteData.noteOrRestID];
            CGRect rect = CGRectMake(x+10, kNoteBottomY-3, 45, 20);
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
