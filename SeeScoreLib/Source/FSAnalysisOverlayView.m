//
//  FSAnalysisOverlayView.m
//  FirstStage
//
//  Created by Scott Freshour on 10/31/17.
//  Copyright © 2017 Musikyoshi. All rights reserved.
//

#import "FSAnalysisOverlayView.h"


// For storing the display data for a single note
@interface NoteDisplayData : NSObject
    @property (nonatomic) float xPos;
    @property (nonatomic) int rhythmResult;
    @property (nonatomic) int pitchResult;
@end

@implementation NoteDisplayData
@end



@interface FSAnalysisOverlayView ()
{
    NSMutableArray*  _hits;
}
@end


@implementation FSAnalysisOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _hits = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void) addHit:(CGFloat) iXPos
{
    [_hits addObject:[NSNumber numberWithFloat:iXPos]];
}

-(void) addHitAtXPos:(CGFloat) iXPos
       withRhythmRes:(int) iRhythmResult
        withPitchRes:(int) iPitchResult
{
    for (NoteDisplayData* noteData in _hits)
    {
        float x = noteData.xPos;
        if (x == iXPos) // already an entry. Just update the exisiting one
        {
            noteData.rhythmResult = iRhythmResult;
            noteData.pitchResult =  iPitchResult;
            return;
        }
    }
    
    // if still here, then didn't find existing entry.  Add one.
    NoteDisplayData* noteData = [[NoteDisplayData alloc] init];
    noteData.xPos = iXPos;
    noteData.rhythmResult = iRhythmResult;
    noteData.pitchResult = iPitchResult;
    
    [_hits addObject: noteData];
     
    [self redrawMe];
}

-(void) updateHitAtXPos:(CGFloat) iXPos
          withRhythmRes:(int) iRhythmResult
           withPitchRes:(int) iPitchResult
{
    
}

-(void) clearHitAtXPos:(CGFloat) iXPos
{
    
}

-(void) clearAllHits
{
    [_hits removeAllObjects];
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


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor (ctx, UIColor.greenColor.CGColor);
    
    
    for (NoteDisplayData* noteData in _hits)
    {
        float x       = noteData.xPos;
        int rhythmRes = noteData.rhythmResult;
//        int pitchRes  = noteData.pitchResult;

        UIColor* color = [UIColor clearColor];
        
        NSString* str = @"";
        switch (rhythmRes)
        {
            case 0:
                str = @" !";
                color = [UIColor greenColor];
                break;
            case 1: // Miss
                str = @"X ";
                color = [UIColor redColor];
                break;
            default: // Late
                str = @" >";
                color = [UIColor purpleColor];
                break;
        }
        
        color = [color colorWithAlphaComponent: 0.4];

        
        // Add text below note to indicate "!" (correct), "<" (early), or ">" (late)
        NSMutableAttributedString* attrStr =
            [[NSMutableAttributedString alloc] initWithString:str];
        NSRange formatRange = NSMakeRange(0, 2);

        UIFont* fnt = [UIFont systemFontOfSize:28];
        [attrStr addAttribute:NSForegroundColorAttributeName
                           value:color
                           range:formatRange];
        // Set format part to BOLD, then change the format part's color
        [attrStr addAttribute: NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Bold"
                                              size:28.0]
                        range:formatRange];
        
        //[str drawAtPoint:CGPointMake(x-8,120.f) withFont: fnt];
        [attrStr drawAtPoint:CGPointMake(x-11,120.f)];
        
        // Draw vertical line through note
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, x, 20.0f);
        CGContextAddLineToPoint(ctx, x, 120.0f);
        CGContextSetLineWidth(ctx, 3.0f);
        CGContextSetStrokeColorWithColor (ctx, color.CGColor);
        CGContextStrokePath(ctx);
    }
}

-(void)touchesBegan: (NSSet*) touches
          withEvent: (UIEvent*) event
{
    UITouch *t = [touches anyObject];
    CGPoint _downLocation =[t locationInView:self];
        
    CGFloat touchX = _downLocation.x;
    
    if ( self.overlayViewDelegate )
        [self.overlayViewDelegate noteTappedAtXCoord:(int)touchX];
}
@end
