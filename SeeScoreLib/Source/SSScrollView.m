//
//  SSScrollView
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//

//#define DrawOutline // define this to draw a green outline around the SSScrollView for debug

#import "SSScrollView.h"
#import "SSSystemView.h"
#import <QuartzCore/QuartzCore.h>
// MKMOD - moved import dispatch.h
#import "SSPlayLoopGraphics.h"
// MKMOD - removed import SSEditLayerProtocol.h
// MKMOD - added import FSAnalysisOverlayView.h    - 11/20/17
#import "FSAnalysisOverlayView.h"

// MKMOD - Added KNoteAnalysisRespondsToTouch - 12/12/17
// MKMOD - removed KNoteAnalysisRespondsToTouch - 12/12/17
// MKMOD - Added kMKDebugOpt_NoteAnalysisRespondsToTouch - 12/17/17
// MKMOD - Removed kMKDebugOpt_NoteAnalysisRespondsToTouch - 2/14/18

#include <dispatch/dispatch.h>

// MKMOD - added kMargin
// MKMODSS - Newest SS version set these to 10,10 vs 0,0
static const CGSize kMargin = {0,0}; // {10,10}; // L/R margins

static const float kWindowPlayingCentreFractionFromTop = 0.333; // autoscroll centres the current playing system around here

static const int kMaxRecycleListSize = 5; // no point in recycling too many views

static const float kMaxAnimateScrollDistance = 1000; // if we animate the scroll over a long distance it's very slow as it has to redraw all intermediate positions
static const float kScrollAnimationDuration = 0.5; // not too slow as there has to be a stationary moment for taps to be registered


static const float kMinMagnification = 0.2;  	// MKMODSS - changed from .4
static const float kMinExactMagnification = 1.0;
static const float kMaxMagnification = 3.0;		// MKMODSS - changed from 2.5

// control automatic reduction of score magnification with smaller screen
static const float kMagnificationReductionScreenWidthThreshold = 768;
static const float kMagnificationProportionToScreenWidth = 0.8F;// this is 0 for constant magnification at different screen widths, 1.0 for magnification proportional to screen width/768.

// MKMOD
//  Commemnted out, then Deleted static BOOL kOptimalSingleSystem
// MKMOD
static const int kMaxLedgers = 6; // determines max acceptable distance from staff to be counted as in the staff

@interface SSScrollView ()
{
    FSAnalysisOverlayView  *analysisOverlayView; // MKMOD - added - 11/20/17
    BOOL doShowAnalysisOverlayView;
    
	NSMutableArray *systemlist; // array of SSSystem
	
	NSArray<NSNumber*> *displayingParts;
	
	SSLayoutOptions *_layoutOptions;  // MKMODSS moved up here
	
	// MKMODFIX MKMODSS - these two were deleted from newest version
//	UIPinchGestureRecognizer *pinchRecognizer;
//	float startPinchMagnification; // base magnification used for pinch-zoom
	
	NSMutableArray *recycleList;
    NSMutableSet *reusableViews;
	
	int cursorBarIndex;
	BOOL showingCursor;

    // MKMOD - added CursorType_e, cursor_xpos
	enum CursorType_e cursorType;
	float cursor_xpos;
	
	NSArray<NSValue*> *systemRects; // CGRect frame of each system
	
	CGSize lastFrameSize;
	bool activeZooming;
	float exactModeZoomScale; // when zooming in exact mode we just enlarge the laid out systems
	CGPoint preservedContentOffset; // when zooming in exact mode we preserve the content centre

	dispatch_queue_t background_layout_queue;
	dispatch_queue_t background_draw_queue;
	
	bool layoutProcessing;
	
	NSMutableSet *pendingAddSystems; // set of indices of systems which are to be placed

	SSScore *score;

	int lastStartBarDisplayed; // used to detect change of visible range to update barcontrol display
	int lastNumBarsDisplayed;
	
	float magnificationScalingForWidth; // everything should be smaller if the width is small (ie smaller for iPhone vs iPad)

// MKMOD - moved higher up in nwere version  	SSLayoutOptions *layOptions;

	bool isPinchEnabled;

	bool showingVoiceTracks;
	
	NSMutableDictionary<NSNumber* /*system index*/, SSColourRender*> *colouringsForSystems;

    // MKMOD - deleted singlePartDIsplay
    // MKMOD - deleted startBarToDIsplay
    // MKMOD - deleted partToDIsplay
    
	handler_t layoutCompletionHandler;
	
	SSPlayLoopGraphics *playLoopGraphics;
    
    // MKMOD - deleted editMode
    // MKMOD - deleted ensureVisiblewRect
	
	sscore_changeHandler_id handlerId; // handler registered with SSScore is automatically notified of changes to the score when editing
    
    int  specifiedFrameWidth;
    
    BOOL useSeeScoreCursor;
    BOOL _scoreIsSetup;
    BOOL _layoutCompletedAfterScoreSetup;
    BOOL _layoutFrozen;
    CGRect _resolvedFrame;
}

@property (atomic) int abortingBackground; // set when background layout/draw is aborting

@end

@implementation SSScrollView

-(SSScore *)score
{
	return score;
}

// MKMOD - deleted   -(float) systemUpperMargin
// MKMOD - deleted   -(float) systemLowerMargin

-(void)initAll
{
 //   NSString* verString  = SSScore.versionString;

	if (containedView == nil)// if contained view was not defined in storyboard create it here
	{
		containedView = [[UIView alloc] initWithFrame:self.bounds];
		[self addSubview:containedView];
	}
	if (self.backgroundColor == nil) // ensure we have a defined background colour
		self.backgroundColor = UIColor.whiteColor;
	self.abortingBackground = 0;
	score = nil;
	systemlist = NSMutableArray.array;
	_magnification = 1.0;
	lastStartBarDisplayed = -1;
	lastNumBarsDisplayed = -1;
	reusableViews = [[NSMutableSet alloc] init];
	recycleList = [[NSMutableArray alloc] init];
	background_layout_queue = dispatch_queue_create("uk.co.dolphin-com.seescore.background_layout", NULL);
	background_draw_queue = dispatch_queue_create("uk.co.dolphin-com.seescore.scroller_background_draw", NULL);
	
	// MKMODFIX - These 3 lines are not in the newer code 
//	pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch)];
    // MKMOD - moved assign to pendingAddSystems   to below
//	[self addGestureRecognizer:pinchRecognizer];
	
	isPinchEnabled = true;
	
	
	colouringsForSystems = NSMutableDictionary.dictionary;
	pendingAddSystems = [NSMutableSet set];
	_layoutOptions = [[SSLayoutOptions alloc] init]; // default layout options
    
    // MKMOD
    //   Removed ref to _xmlScoreWidth
    //   Removed ref to singlePartDisplay
    //   Added, then removed ref to _optimalSingleSystem
    // MKMOD
    
	[self resetBarRectCursor];
	super.delegate = self;
	isPinchEnabled = true;
	self.minimumZoomScale = kMinMagnification;
	self.maximumZoomScale = kMaxMagnification;
	exactModeZoomScale = 1.0;
	
    specifiedFrameWidth = 0;
    useSeeScoreCursor = YES;	// MKMOD
    _scoreIsSetup = NO;
    _layoutCompletedAfterScoreSetup = NO;
    _layoutFrozen = NO;
    
    [self addOverlayView];  // MKMOD - added - 11/20/17
    
	// MKMODFIX this line is not in new code
	[self setCursorColour: [UIColor redColor]];
    _resolvedFrame = CGRectMake(0.0, 0.0, 100.0, 100.0);
}

// MKMOD - removed -(bool) displaySinglePart
// MKMOD - removed -(bool) setSinglePartDisplay
// MKMOD - removed -(bool) clearSinglePartDisplay

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
	super.backgroundColor = backgroundColor;
	if (containedView != nil)
		containedView.backgroundColor = backgroundColor;
}

//for when not using a nib
- (instancetype)initWithFrame:(CGRect)aRect
{
	self = [super initWithFrame:aRect];
	if (self)
	{
		[self initAll];
	}
	return self;
}

- (void) awakeFromNib
{
	[super awakeFromNib];
	[self initAll];
}

-(void)dealloc
{
	if (score)
	{
		[systemlist removeAllObjects];
        // MKMOD - removed  if (score)
        // MKMOD - removed      ssscore_edit_removechangehandler
		[self deactivateChangeHandler]; // MKMODSS was:	[score removeChangeHandler:handlerId];
		handlerId = 0;
		score = nil;
	}
}

-(float)zoomMagnification
{
	return exactModeZoomScale;
}

-(SSLayoutOptions *)layoutOptions
{
	return _layoutOptions;
}

-(void)setLayoutOptions:(SSLayoutOptions*)layoutOptions
{
	[self disablePinch];
	self.minimumZoomScale = layoutOptions.useXMLxLayout ? kMinExactMagnification : kMinMagnification;
	self.maximumZoomScale = kMaxMagnification;
	[self setupScore:score openParts:displayingParts mag:self.magnification opt:layoutOptions completion:^{
		[self enablePinch];
	}];
	[self setNeedsLayout];
}


// MKMODSS MKMODFIX  old setLayoutOptions defined below.  Removed from below, moved here, for comparison
// -(void)setLayoutOptions:(SSLayoutOptions*)layoutOptions
// {
// 	[self disablePinch];
// 	[self setupScore:score openParts:displayingParts mag:self.magnification opt:layoutOptions completion:^{
// 		if (!layoutOptions.useXMLxLayout)
// 			[self enablePinch];
// 	}];
// }



-(void)activateChangeHandler
{
	assert(handlerId == 0);
	if (score)
		handlerId = [score addChangeHandler:self];
}

-(void)deactivateChangeHandler
{
	if (score && handlerId != 0)
		[score removeChangeHandler:handlerId];
	handlerId = 0;
}

-(int)numPartsDisplaying
{
	int num = 0;
	for (NSNumber *n in displayingParts)
	{
		if (n.boolValue)
			++num;
	}
	return num;
}

-(int)firstPartDisplaying
{
	int index = 0;
	for (NSNumber *n in displayingParts)
	{
		if (n.boolValue)
			return index;
		++index;
	}
	return 0;
}

-(float)bottom
{
	float bottom = self.frame.origin.y;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			CGRect f = v.frame;
			bottom = fmax(bottom, f.origin.y + f.size.height);
		}
	}
	return bottom;
}

// MKMOD - removed -(bool) setEditLayer
// MKMOD - removed -(bool) setEditMode
// MKMOD - removed -(bool) clearEditMode

-(bool)displayingCursor
{
	return showingCursor;
}

-(int)cursorBarIndex
{
	return cursorBarIndex;
}

// MKMODSS MKMODFIX  This is not in new code
// -(float)systemDrawScale
// {
// 	SSSystemView *sysView = [self systemViewForIndex:0];
// 	return sysView ? sysView.drawScale : 1;
// }

// MKMOD -  Added ClearDisplay, must have confused in merge with ClearAll below.
-(void)clearDisplay
{
	[self clearPlayLoopGraphics];
	_magnification = 1.0;
	lastStartBarDisplayed = -1;
	lastNumBarsDisplayed = -1;
	[self removeAllSystems];
	[systemlist removeAllObjects];
	if (self.updateDelegate)
		[self.updateDelegate cleared];
}


-(void)clearAll
{
	[self hideCursor];
	[self clearDisplay];
	[self deactivateChangeHandler];
	handlerId = 0;
	score = nil;
}

-(void)relayoutWithCompletion:(handler_t)completionHandler
{
    // MKMOD -  removed conditional    if (!editMode) {  around these two lines:
    
// LEAVING FOR LONGTONE WORK  FOR LONGTONE WORK    NSLog(@"\nWHITE TRACKING #3  : SSCrollView::relayoutWithCompletion()    top\n");
    
	if (score)
	{
        
 // LEAVING FOR LONGTONE WORK        NSLog(@"\nWHITE TRACKING #4  : SSCrollView::relayoutWithCompletion(),    if score  \n");
        
		lastStartBarDisplayed = -1;
		lastNumBarsDisplayed = -1;
		[self removeAllSystems];
		[self setupScore:score openParts:displayingParts mag:self.magnification opt:_layoutOptions completion:completionHandler];
	}
	else
    {
	 	completionHandler();
 // LEAVING FOR LONGTONE WORK         NSLog(@"\nWHITE TRACKING #5  : SSCrollView::relayoutWithCompletion(),  else //  if score \n");
    }
}

-(void)relayout
{
 // LEAVING FOR LONGTONE WORK     NSLog(@"\nWHITE TRACKING #2  : SSCrollView::relayout()    top\n");
	[self relayoutWithCompletion:^{}];
}

// set flag to abort all background processing (layout and draw) and return immediately.
// Call completion handler on main thread when abort is complete
// It should be safe to call this again before completionhandler is called
-(void)abortBackgroundProcessing:(handler_t)completionHandler
{
	++self.abortingBackground;
	dispatch_async(background_layout_queue, ^{
		dispatch_sync(self->background_draw_queue, ^{
			// complete the abort only when the background queues are empty
			dispatch_async(dispatch_get_main_queue(), ^{
				[self->pendingAddSystems removeAllObjects];
				--self.abortingBackground;
				if (self.abortingBackground == 0)
					completionHandler();
			});
		});
	});
}


static float limit(float val, float mini, float maxi)
{
	return (val < mini) ? mini : val > maxi ? maxi : val;
}


-(void)setMagnification:(float)mag
{
	if (score && systemlist.count > 0 && ![self isProcessing])
	{
		_magnification = limit(mag, kMinMagnification, kMaxMagnification);
        // MKMOD -  added second param mag below
		[self setupScore:score openParts:displayingParts mag:self.magnification opt:_layoutOptions];
	}
}

// MKMODFIX MKMODSS  The method (pinch) is not in the newest file.

// find lowest index in displayed systems
-(int)firstSystemIndex
{
	int topSysIndex = 100000;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if (sysView.systemIndex < topSysIndex)
				topSysIndex = sysView.systemIndex;
		}
	}
	return topSysIndex;
}

// find highest index in displayed systems
-(int)bottomSystemIndex
{
	int botSysIndex = 0;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if (sysView.systemIndex > botSysIndex)
				botSysIndex = sysView.systemIndex;
		}
	}
	assert(botSysIndex >= 0 && botSysIndex < 1000);
	return botSysIndex;
}

// return set of all system indices of placed systems
-(NSSet*)systemIndexSet
{
	NSMutableSet *set = [NSMutableSet set];
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			NSNumber *num = [NSNumber numberWithInt:sysView.systemIndex];
			assert(![set containsObject:num]);
			[set addObject:num];
		}
	}
	return set;
}

// return true if we have a system view with the given index as a subview
-(bool)existsSysView:(int)sysIndex
{
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if (sysView.systemIndex == sysIndex)
				return true;
		}
	}
	return false;
}

-(void) addSystemToList:(SSSystem *)sys
{
	[systemlist addObject:sys];
}

-(float)systemHeight:(int)sysIndex zoom:(float)zoom
{
	// MKMODSS - maxSystemHeight - this line used to use the following consts:
	// float maxSystemHeight = fmax(self.frame.size.height, 640.F); // don't allow any system higher than the screen else we run out of memory (but prevent 0 size)
	const float maxSystemHeight = 2*self.frame.size.height; // we impose a limit to preserve memory
	assert(sysIndex >= 0 && sysIndex < systemlist.count);
	SSSystem *system = [systemlist objectAtIndex:sysIndex];
	// limit height of system
    // MKMOD - redefined declaration of systemHeight, prev used if editMode in assignment

    float systemHeight = min(system.bounds.height * zoom, maxSystemHeight);
	assert(systemHeight > 0);
	return systemHeight;
}

-(NSArray*)getSystemRects
{
	NSMutableArray *mutSysRects = [[NSMutableArray alloc] init];
	assert(systemlist);
	float ypos = kMargin.height;
	CGSize frameSize = self.frame.size;
	assert(frameSize.width > 0);
	float zoom = exactModeZoomScale * self.zoomScale;
	int index = 0;
	for (SSSystem *system in systemlist)
	{
		// MKMODSS MKMODFIX - line used to be as follows. Perhaps disallowed zoom?
		// float systemHeight = [self systemHeight:index zoom:1]; // zoom is only needed for actual zooming
		float systemHeight = [self systemHeight:index zoom: zoom];
        // MKMOD - removed += call to ypos
		// MKMODSS MKMODFIX - was: CGRect rect = CGRectMake(kMargin.width, ypos, frameSize.width, systemHeight);
		CGRect rect = CGRectMake(kMargin.width, ypos, frameSize.width * zoom, systemHeight);
		[mutSysRects addObject:[NSValue valueWithCGRect:rect]];
		// MKMODSS MKMODFIX - was: ypos += systemHeight + system.defaultSpacing;   // MKMOD - altered this assign
		ypos += systemHeight + system.defaultSpacing * zoom;
		++index;
	}
	return mutSysRects;
}

// reduce magnification for display width < 768
-(float)magnificationScaling:(float)width
{
	return (width < kMagnificationReductionScreenWidthThreshold) ? 1.0 + kMagnificationProportionToScreenWidth*((width / kMagnificationReductionScreenWidthThreshold) - 1.0) : 1.0;
}

// 5/23/19 SCF - added
-(void) setSpecifiedFrameWidth:(int)iSpecifiedFrameWidth
{
    specifiedFrameWidth = iSpecifiedFrameWidth;
}

-(void)setupScore:(SSScore*)sc openParts:(NSArray<NSNumber*> *)parts mag:(float)mag opt:(SSLayoutOptions *)options
{
	[self setupScore:sc openParts:parts mag:mag opt:options completion:^{}];
}

// 3/29/19 SCF - In upgrade, this method, setupScore, was modified extensively in James' new code.
// I didn't see anything in here that was tagged by David, so I just accepted the changes for the entire method.

-(void)setupScore:(SSScore*)sc
		openParts:(NSArray<NSNumber*>*)parts
			  mag:(float)mag
			  opt:(SSLayoutOptions *)options
	   completion:(handler_t)completionHandler
{
//    NSLog(@"\n\nWHITE TRACKING #8  : SSCrollView::setupScore()    top\n\n");

    if (_scoreIsSetup)
    {
//        NSLog(@"\n\nWHITE TRACKING #11 : SSCrollView::setupScore()   EXIT #1 at top\n\n");
        return;
    }
    
    self.magnification = 1.2;    // hyar
    
	[self deactivateChangeHandler];
	handlerId = 0;
	[self disablePinch];
	assert(sc);
	assert(parts.count > 0);
	// abort any existing layout/draw...
	[self abortBackgroundProcessing:^{ // .. and on completion:
		assert(!self->layoutProcessing);
		[self clearAll];
		self->displayingParts = parts;
		self->_layoutOptions = options;
		self.zoomScale = 1.0;
		if (!options.useXMLxLayout)
			self->exactModeZoomScale = 1.0;
		self->score = sc;
		[self activateChangeHandler];
        self->_magnification = mag;

        __block CGRect frame = self.frame;  // moved this up
        frame.size.width = 600;
        //frame.size.height = 200;
        if (specifiedFrameWidth != 0)
            frame.size.width = specifiedFrameWidth;
        
		assert(frame.size.width > 0);
		// we want a smaller scaling for smaller screens (iphone), but less than proportionate
		self->magnificationScalingForWidth = [self magnificationScaling:frame.size.width];
		if (self.abortingBackground == 0)
		{
			assert(!self->layoutProcessing);
			self->layoutProcessing = true;
			assert(self->systemlist.count == 0);
            dispatch_async(self->background_layout_queue, ^{
				assert(self->systemlist.count == 0);
				if (self.abortingBackground == 0)
				{
                    self->_resolvedFrame = frame;
                    if (_optimalXMLxLayoutMagnification) {
                      if (!_scoreIsSetup) {
                        
                        __block float systemMagnification = 0;
                        __block bool widthIsTruncated = NO;//YES;
                        __block int loopCount = 0;
                        __block bool longToneViewComplete = NO;
                        __block bool preLoopDone = NO;
                        do {
                            // MKMOD - ... to here    (see "MKMOD added" above
                            
                            loopCount++;
//                            NSLog(@"\n\n--- In SSCrollView::setupScore() ->  top of reduction loop;  loop count == %i\n\n",
//                                  loopCount);

                            UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
                            CGContextRef ctx = UIGraphicsGetCurrentContext();
                            // MKMOD - took out SSSystem* system = [score layoutSystemContext:  // 5-6 lines
                            
                            // MKMOD - Added this whole call to create sscore_error below
                            enum sscore_error err =
                                [score layoutWithContext:ctx
                                                   width:frame.size.width - (2 * kMargin.width)
                                               maxheight:frame.size.height
                                                   parts:parts
                                           magnification:self.magnification * magnificationScalingForWidth
                                                 options:options
                                                callback:^bool (SSSystem *sys){
                                                    // callback is called for each new laid out system
                                                    // return false if abort required
                                                    if (self.abortingBackground == 0)
                                                    {
                                                        // MKMOD -  deleted assign to widthIsTruncated - 5/28/17
                                                        systemMagnification = sys.magnification;
                                                        //systemMagnification = mag;
                                                        // MKMOD -  changed this log - 5/28/17
                                                        //                                                                       NSLog(@"sys.magnification = %f, %i", sys.magnification, widthIsTruncated);
                                                        _scoreIsSetup = YES;
                                                        self->_resolvedFrame = frame;
                                                        return true;
                                                    }
                                                    else
                                                        return false;}];
                            UIGraphicsEndImageContext();
                            
                            // MKMOD - took out 5 lines here   4/1/17 DR commit
                            
                            // MKMOD - added lines 11 below   4/1/17 DR commit
                            if (err != sscore_NoError)
                                break;
                            if ((systemMagnification < self.magnification) || widthIsTruncated) {
                                // MKMOD -  changed this log - 5/28/17
                                //                                    NSLog(@"systemMagnification:%f - width=%f", systemMagnification, frame.size.width);
                                frame.size.width += 100;
                            }
                            NSLog(@"    ************  In setupScore, bottom of reduction loop; \n");
                            NSLog(@"       loop count == %i,     width = %f\n", loopCount, frame.size.width);
                            NSLog(@"       widthIsTruncated = %s,  systemMag = %f, self.mag = %f\n",
                                  widthIsTruncated ? "YES" : "No", systemMagnification, self.magnification);
                            
                            if (self.forLongToneView) {
                                if (loopCount >= 1)
                                    longToneViewComplete = YES;
                            }

                            // Are we done?
                            if (self.forLongToneView) {
                                if (longToneViewComplete) {
                                    preLoopDone = YES;
                                }
                            } else {
                                if ((systemMagnification < self.magnification) || widthIsTruncated) {
                                    preLoopDone = NO;
                                } else {
                                    preLoopDone = YES;
                                }
                            }
                            
                        } while ( !preLoopDone );
//                        } while ( ((systemMagnification < self.magnification) || widthIsTruncated) &&
//                                 (self.forLongToneView && !longToneViewComplete)
//                               );
//                        NSLog(@"************  In setupScore, Exited reduction loop!");
                      }
                     
                        
                      // MKMOD -  changed this log - 5/28/17
                      // MKMOD -  commented out this log - 11/6/17
                      //                            NSLog(@"+++systemMagnification:%f - width=%f", systemMagnification, frame.size.width);
                    
                    
                      // MKMOD -  added the dispatch_async "wrapper" - 11/6/17
                      // MKMOD - on 11/20/17, made a similar, if not identical change here.
                      // temp fix, from Matt's checkin
                      // was:  self.frame = frame;
                      dispatch_async(dispatch_get_main_queue(), ^{
                          self.contentSize = self->_resolvedFrame.size;
//                          if (self.frame.size.width > self->_resolvedFrame.size.width) {
//                              // score is not as wide as screen. don't alter the frame.
//                              self.contentSize = self->_resolvedFrame.size;
//                          } else {
//                              self.frame = self->_resolvedFrame;
//                          }
                      });
                    }

                    ///////////////////////////////////////
                    // else, for:  if (_optimalXMLxLayoutMagnification)
                    // (merged from David's original code)
                    // goes here
                    ///////////////////////////////////////
                    
                    /////////======================================================================================
                    

//
//
//
//
//
//                    else
//                        if (_optimalSingleSystem) {
//                            __block int numNewSystems = 0;
//                            do {
//                                numNewSystems = 0;
//                                UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
//                                CGContextRef ctx = UIGraphicsGetCurrentContext();
//                                enum sscore_error err = [score layoutWithContext:ctx
//                                                                           width:frame.size.width - (2 * kMargin.width) maxheight:frame.size.height
//                                                                           parts:parts magnification:self.magnification * magnificationScalingForWidth
//                                                                         options:options
//                                                                        callback:^bool (SSSystem *sys){
//                                                                            // callback is called for each new laid out system
//                                                                            // return false if abort required
//                                                                            if (self.abortingBackground == 0)
//                                                                            {
//                                                                                numNewSystems++;
//                                                                                return true;
//                                                                            }
//                                                                            else
//                                                                                return false;}];
//                                UIGraphicsEndImageContext();
//                                if (err != sscore_NoError)
//                                    break;
//                                if (numNewSystems > 1) {
//                                    NSLog(@"numNewSystems:%d - width=%f", numNewSystems, frame.size.width);
//                                    frame.size.width += 100;
//                                }
//                                NSLog(@"SSScrollView.magnification = %f", self.magnification);
//                            } while (numNewSystems > 1);
//
//                            self.frame = frame;
//                            NSLog(@"one system: xmlScoreWidth = width=%f", frame.size.width);
//                        }
 
                    
                    
                    
                    ////////========================================================================================

                    
					UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
					CGContextRef ctx = UIGraphicsGetCurrentContext();
                    float selfMag = self.magnification;
                    float selfMagSc4Wd = self->magnificationScalingForWidth;
                    float mag = self.magnification * self->magnificationScalingForWidth;
                    float wd = _resolvedFrame.size.width - 2 * kMargin.width;
                    float maxHt = 2*_resolvedFrame.size.height;
                    
                    // NSLog(@"************ In setupScore,  wd = %f,    mag = %f,   maxHt = %f", wd, mag, maxHt);
                    
 // LEAVING FOR LONGTONE WORK                     NSLog(@"\n\n  WHITE TRACKING #10 : SSCrollView::setupScore()    AFTER reduction loop\n\n");
					enum sscore_error err =
                        [self->score layoutWithContext:ctx
                                                 width: wd // frame.size.width - 2 * kMargin.width
                                             maxheight:2*_resolvedFrame.size.height
                                                 parts:parts
                                         magnification:mag //self.magnification * self->magnificationScalingForWidth
                                               options:self->_layoutOptions
                                              callback:^bool (SSSystem *sys){
																// callback is called for each new laid out system
																// return false if abort required
																
                                                                CGSize sysBounds = sys.bounds;
                                                  
                                                                //sysBounds.height = 200.0;
                                                                //sys.bounds = sysBounds;
                                                                //sys.magnification = 1.0
																if (self.abortingBackground == 0)
																{
																	dispatch_sync(dispatch_get_main_queue(), ^{
																		if (self.abortingBackground == 0)
																		{
																			[self addSystemToList:sys];
                                                                            self->layoutProcessing = false;
																			[self setNeedsLayout]; // triggers call to layoutSubviews
																			if (self.scrollDelegate)
																				[self.scrollDelegate changedScroll]; // update the barcontrol to show more bars loaded
																		}
																	});
																	return true;
																}
																else
																	return false;}];
					UIGraphicsEndImageContext();
					switch (err)
					{
						case sscore_NoError:break;
						case sscore_OutOfMemoryError:	NSLog(@"out of memory");break;
						case sscore_XMLValidationError: NSLog(@"XML validation error");break;
						case sscore_NoBarsInFileError:	NSLog(@"No bars in file error");break;
						case sscore_WidthTooSmallError: NSLog(@"WidthTooSmall Error"); break;
						case sscore_NullGraphicsError:	NSLog(@"NullGraphics Error"); break;
						case sscore_MagnificationTooSmallError:	NSLog(@"MagnificationTooSmall Error"); break;
						case sscore_MagnificationTooLargeError:	NSLog(@"MagnificationTooLarge Error"); break;
						case sscore_NoPartsError:			NSLog(@"NoParts Error"); break;
						case sscore_NoPartsToDisplayError:	NSLog(@"NoPartsToDisplay Error"); break;
						default:
						case sscore_UnknownError:		NSLog(@"Unknown error");break;
						case sscore_BadHeightError:		NSLog(@"bad height");break;
						case sscore_WidthTooLargeForIphoneError:	NSLog(@"the system width is limited on the iPhone-only licensed framework");break;
						case sscore_HeightTooLargeForIphoneError:	NSLog(@"the system height is limited on the iPhone-only licensed framework");break;
					}
				}
				self->layoutProcessing = false;
 //               DELAY(1.0);
				dispatch_sync(dispatch_get_main_queue(), ^{
					
					if (options.useXMLxLayout
						&& self->systemlist.count > 0) // copy system magnification from top system up to this in exact layout mode so that the magnification looks similar on switch of layout mode
					{
						SSSystem *topSystem = (SSSystem*)[self->systemlist objectAtIndex:0];
                        self->_magnification = topSystem.magnification;
                        //self->_magnification = mag; // topSystem.magnification;
					}

					[self enablePinch];
					
					if (completionHandler)
						completionHandler();
				});
			});
		}
	}];
}


// MKMOD - redid displayParts significantly   4/1/17 DR commit
-(void)displayParts:(NSArray<NSNumber*>*)openParts
{
	[self setupScore:score openParts:openParts mag:self.magnification opt:_layoutOptions completion:^{}];
}

// MKMOD - redid setLayoutOptions significantly    4/1/17 DR commit
// MKMOD    setLayoutOptions defined above.  Removed 

static float min(float a, float b)
{
	return a < b ? a : b;
}

-(bool)isProcessing
{
	return layoutProcessing;
}

// MKMOD - added   4/1/17 DR commit
-(void)resetBarRectCursor
{
	cursorType = cursor_rect;
	cursor_xpos = 0;
}

-(void)removeAllSystems
{
	[self resetBarRectCursor];
	[colouringsForSystems removeAllObjects];
	systemRects = [NSArray array]; // clear
	[reusableViews removeAllObjects];
	[pendingAddSystems removeAllObjects];
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]]) // ignore editlayer
		{
			SSSystemView *sysView = (SSSystemView*)v;
			// [sysView clear]; // clear held system    // MKMODSS MKMODSS this line is not in new code
			[recycleList addObject:sysView];
		}
	}
	for (SSSystemView *view in recycleList)
	{
		[self removeSystemView:view];
	}
	[recycleList removeAllObjects];
}

- (SSSystemView *)getReusableView {
    SSSystemView *view = [reusableViews anyObject];
    if (view)
	{
        [reusableViews removeObject:view];
    }
	else // create new view
	{
		view = [[SSSystemView alloc] initWithBackgroundColour:self.backgroundColor];
	}
	return view;
}

-(int)requiredFirstSystem
{
	if (systemlist.count > 0)
		return min([self systemIndexAtPos:self.bounds.origin], systemlist.count-1);
	else
		return 0;
}
-(int)requiredLastSystem
{
	if (systemlist.count > 0)
		return min([self systemIndexAtPos:CGPointMake(CGRectGetMaxX(self.bounds),CGRectGetMaxY(self.bounds))], systemlist.count-1);
	else
		return 0;
}

-(void)addSystemView:(SSSystemView*)sysView index:(int)sysIndex
{
	assert(![self existsSysView:sysIndex]);
	[containedView addSubview:sysView];

     // MKMOD - added this if section - 11/20/17
    if (analysisOverlayView != nil)
    {
        CGSize sz = self.contentSize;
        CGRect frame = containedView.frame;
        frame.size.width = sz.width;
        [analysisOverlayView setFrame:frame];

        analysisOverlayView.layer.zPosition = 5; // MKMODFIX why 5? might need more dynamic calc'ing

        // MKMOD - removed commented lines lines - 12/12/17
        [analysisOverlayView redrawMe];
        
        doShowAnalysisOverlayView = YES;
    }
}

-(void)removeSystemView:(SSSystemView*)sysView
{
	assert([self existsSysView:sysView.systemIndex]);
	[sysView clear]; // clear held system and change handler
	// store any colour rendering for this system so we can restore it when it becomes visible again and is recreated
	if (sysView.colourRender != nil)
		[colouringsForSystems setObject:sysView.colourRender forKey:[NSNumber numberWithInt:sysView.systemIndex]];
	[sysView removeFromSuperview];
}

-(void)addSystem:(int)sysIndex
{
	NSNumber *sysIndexNum = [NSNumber numberWithInt:sysIndex];
	[pendingAddSystems addObject:sysIndexNum];
	assert(score && systemlist.count > 0);
	assert(![self existsSysView:sysIndex]);
	if (self.abortingBackground == 0)
	{
		assert(sysIndex >= 0 && sysIndex < systemlist.count);
		SSSystemView *sysView = [self getReusableView];
		SSSystem *system = [systemlist objectAtIndex:sysIndex];
		assert(sysIndex >= 0 && sysIndex < systemRects.count);
		CGRect sysFrame = [[systemRects objectAtIndex:sysIndex] CGRectValue];
		assert(sysFrame.size.height > 0 && sysFrame.size.width > 0);
        // MKMOD - deleted call to setFrame   4/1/17 DR commit
        // MKMOD - modified call to  sysView setSystem: below  4/1/17 DR commit
		// MKMODSS - this method's signature is quite different
		[sysView setSystem:system score:score topLeft:sysFrame.origin
				 zoomScale:exactModeZoomScale*self.zoomScale
					margin:CGSizeZero];
		// restore any preserved colouring
		NSNumber *sysIndexKey = [NSNumber numberWithInt:sysIndex];
		SSColourRender *storedColourRenderForSystem = [colouringsForSystems objectForKey:sysIndexKey];
		if (storedColourRenderForSystem != nil)
		{
			sysView.colourRender = storedColourRenderForSystem;
			[colouringsForSystems removeObjectForKey:sysIndexKey];
		}
		else if (showingVoiceTracks)
		{
			[sysView showVoiceTracks:true];
		}
		[self addSystemView:sysView index:sysIndex];
		[pendingAddSystems removeObject:sysIndexNum];
	}
}

// return true if any change
-(bool)removeUnneededSystems
{// recycle any view which are above or below the displayed area
	bool changed = false;
	int firstNeededSystem = [self requiredFirstSystem];
	int lastNeededSystem = [self requiredLastSystem];
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if (sysView.systemIndex < firstNeededSystem
				|| sysView.systemIndex > lastNeededSystem)
			{
				changed = true;
				[recycleList addObject:sysView];
			}
		}
	}
	for (SSSystemView *view in recycleList)
	{
		if (reusableViews.count < kMaxRecycleListSize) // no point in recycling too many
			[reusableViews addObject:view];
		[self removeSystemView:view];
	}
	[recycleList removeAllObjects];
	return changed;
}

-(CGSize)systemsSize
{
	CGSize sz = CGSizeZero;
	for (SSSystem *sys in systemlist)
	{
		sz.height += sys.bounds.height + sys.defaultSpacing;
		if (sys.bounds.width > sz.width)
			sz.width = sys.bounds.width;
	}
//    sz.height = 150.0;
	return sz;
}
// MKMODSS The method layoutSubviews was altered substantially. I did the merge, but my guess is
// that none of ther old stuff was our changes. So I included the method as-is from James' new code.
// The merged method is below, commented out, in case I want to try it.
/*
- (void)layoutSubviews
{
	[super layoutSubviews];
	if (activeZooming)
		return;
	CGSize frameSize = self.frame.size;
	float frameAspect = frameSize.width / frameSize.height;
	float lastFrameAspect = lastFrameSize.width / lastFrameSize.height;
	if (fabs(frameAspect - lastFrameAspect) > 0.1) // auto-detect device rotation by looking for frame width change
		[self relayout];
	if (self.abortingBackground == 0 && score && systemlist.count > 0) // this is called on every scroll movement
	{
		bool wasShowingCursor = showingCursor;
		[self hideCursor];
		// adjust height of content to include all systems
		CGSize size = [self systemsSize];
        bool exactLayout = false; // self.layoutOptions.useXMLxLayout;
		if (exactLayout) // in exact layout mode we preserve the system layout and allow it to disappear off the edge of the screen as we zoom in
			size = CGSizeMake(size.width * exactModeZoomScale * self.zoomScale + kMargin.width, size.height * exactModeZoomScale * self.zoomScale + kMargin.height);
		
		self.contentSize = size;
		CGRect containedFrame = containedView.frame;
		containedFrame.origin = CGPointMake(0,0);
		containedFrame.size = size;
		containedView.frame = containedFrame;

		systemRects = [self getSystemRects];
		
		// preserve content offset after zoom
		if (exactLayout && preservedContentOffset.x > 0)
		{
			CGFloat contentHeight = self.contentSize.height;
			if (preservedContentOffset.y + frameSize.height > contentHeight)
			{
				preservedContentOffset.y = fmax(0, contentHeight - frameSize.height); // limit offset to ensure scroll within limits of frame
			}
			self.contentOffset = preservedContentOffset;
		}
		preservedContentOffset = CGPointZero;

		NSSet* placedSystemIndexSet = [self systemIndexSet]; // set of index of placed systems
		
		int numPlacedSystems = (int)placedSystemIndexSet.count;
		int firstPlacedSystem = [self firstSystemIndex];
		
		int firstNeededSystem = [self requiredFirstSystem];
		int lastNeededSystem = [self requiredLastSystem];
		int numSystemsNeeded = lastNeededSystem - firstNeededSystem + 1;

		if (firstNeededSystem != firstPlacedSystem
			|| numSystemsNeeded != numPlacedSystems)
		{
			// remove hidden systems above or below displayed area
			[self removeUnneededSystems];
			
			// iterate through needed rows, adding any systems that are missing
			for (int index = 0; index < numSystemsNeeded; ++index)
			{
				if (self.abortingBackground != 0)
					break;
				int neededSysIndex = firstNeededSystem + index;
				assert(neededSysIndex >= 0 && neededSysIndex < systemlist.count);
				if (neededSysIndex < systemRects.count)
				{
					NSNumber *sysIndexNum = [NSNumber numberWithInt:neededSysIndex];
					
					BOOL systemIsMissing = ![placedSystemIndexSet containsObject:sysIndexNum]
					&& ![pendingAddSystems containsObject:sysIndexNum];
					
					if (systemIsMissing) // system hasn't been placed and is not pending placement
					{
						[self addSystem:neededSysIndex];
					}
				} // else required system hasn't been laid out yet
			}
		}

		if (self.scrollDelegate && [self changedVisible])
		{
			[self.scrollDelegate changedScroll];
		}
		if (self.updateDelegate)
		{
			[self.updateDelegate newLayout];
		}
		if (wasShowingCursor)
		{
			[self displayCursor];
		}
	}
	lastFrameSize = self.frame.size;
}
*/

// / * MKMODSS  This is the merged method
- (void)layoutSubviews
{
    if (_layoutFrozen) {
        // Score setup and Layout is complete, App has frozen layout, so no need
        // to layout subvies again. (Proceeding causes issues.)
 // LEAVING FOR LONGTONE WORK         NSLog(@"\nWHITE TRACKING #12  : SSCrollView::layoutSubviews()  exiting #1\n");
        return;
    }
    
 // LEAVING FOR LONGTONE WORK     NSLog(@"\nWHITE TRACKING #6  : SSCrollView::layoutSubviews()    top\n");
    
     // MKMOD - added stuff that was deleted later - 11/20/17
    if (_layoutCompletedAfterScoreSetup) {
        self.frame = self->_resolvedFrame; }
    
	[super layoutSubviews];
    if (_layoutCompletedAfterScoreSetup) {
        self.frame = self->_resolvedFrame; }
    
	if (activeZooming)
		return;
	CGSize frameSize = self.frame.size;
	float frameAspect = frameSize.width / frameSize.height;
	float lastFrameAspect = lastFrameSize.width / lastFrameSize.height;
    // auto-detect device rotation by looking for frame width change
    if ( fabs(frameAspect - lastFrameAspect) > 0.1   &&
         !self->layoutProcessing   &&
         !self->_layoutCompletedAfterScoreSetup )
		[self relayout];
	if (self.abortingBackground == 0 && score && systemlist.count > 0) // this is called on every scroll movement
	{
		bool wasShowingCursor = showingCursor;
		// MKMODSS - latest code removed this and substituted line below:  [self resetBarRectCursor];     // MKMOD - added
		[self hideCursor];
		// adjust height of content to include all systems
		CGSize size = [self systemsSize];
		bool exactLayout = self.layoutOptions.useXMLxLayout;
		if (exactLayout) // in exact layout mode we preserve the system layout and allow it to disappear off the edge of the screen as we zoom in
			size = CGSizeMake(size.width * exactModeZoomScale * self.zoomScale + kMargin.width, size.height * exactModeZoomScale * self.zoomScale + kMargin.height);
		
		self.contentSize = size;
		CGRect containedFrame = containedView.frame;
		containedFrame.origin = CGPointMake(0,0);
		containedFrame.size = size;
		containedView.frame = containedFrame;

        // MKMOD - removed editMode from calc
		if (systemlist.count != systemRects.count) // don't normally need to recalc the system rects unless in edit mode
		systemRects = [self getSystemRects];
		
		// preserve content offset after zoom
		if (exactLayout && preservedContentOffset.x > 0)
		{
			CGFloat contentHeight = self.contentSize.height;
			if (preservedContentOffset.y + frameSize.height > contentHeight)
			{
				preservedContentOffset.y = fmax(0, contentHeight - frameSize.height); // limit offset to ensure scroll within limits of frame
			}
			self.contentOffset = preservedContentOffset;
		}
		preservedContentOffset = CGPointZero;

		NSSet* placedSystemIndexSet = [self systemIndexSet]; // set of index of placed systems
		
		int numPlacedSystems = (int)placedSystemIndexSet.count;
		int firstPlacedSystem = [self firstSystemIndex];
		
		int firstNeededSystem = [self requiredFirstSystem];
		int lastNeededSystem = [self requiredLastSystem];
		int numSystemsNeeded = lastNeededSystem - firstNeededSystem + 1;

		if (firstNeededSystem != firstPlacedSystem
			|| numSystemsNeeded != numPlacedSystems)
		{
			// remove hidden systems above or below displayed area
			[self removeUnneededSystems];
			
			// iterate through needed rows, adding any systems that are missing
			for (int index = 0; index < numSystemsNeeded; ++index)
			{
				if (self.abortingBackground != 0)
					break;
				int neededSysIndex = firstNeededSystem + index;
				assert(neededSysIndex >= 0 && neededSysIndex < systemlist.count);
				if (neededSysIndex < systemRects.count)
				{
					NSNumber *sysIndexNum = [NSNumber numberWithInt:neededSysIndex];
					
					BOOL systemIsMissing = ![placedSystemIndexSet containsObject:sysIndexNum]
					&& ![pendingAddSystems containsObject:sysIndexNum];
					
					if (systemIsMissing) // system hasn't been placed and is not pending placement
					{
						[self addSystem:neededSysIndex];
					}
				} // else required system hasn't been laid out yet
			}
		}

		if (self.scrollDelegate && [self changedVisible])
		{
			[self.scrollDelegate changedScroll];
		}
		if (self.updateDelegate)
		{
			[self.updateDelegate newLayout];
		}
		if (wasShowingCursor)
		{
			[self displayCursor];
		}
	}
    lastFrameSize = self->_resolvedFrame.size;

    if (_scoreIsSetup) {
 // LEAVING FOR LONGTONE WORK         NSLog(@"\n\nWHITE TRACKING #13  : SSCrollView::layoutSubviews()   setting  _layoutCompletedAfterScoreSetup = YES \n\n");
        _layoutCompletedAfterScoreSetup = YES;
    }
    
} // End of merged layoutSubviews
// * /

// YOYOYO Good to here

-(bool)changedVisible
{
 // LEAVING FOR LONGTONE WORK     NSLog(@"\nWHITE TRACKING #7  : SSCrollView::changedVisible()    top\n");

    int startBarDisplayed = [self startBarDisplayed];
	if (startBarDisplayed != lastStartBarDisplayed)
	{
		lastStartBarDisplayed = startBarDisplayed;
		return true;
	}
	int numBarsDisplayed = [self numBarsDisplayed];
	if (numBarsDisplayed != lastNumBarsDisplayed)
	{
		lastNumBarsDisplayed = numBarsDisplayed;
		return true;
	}
	return false;
}

-(SSSystem*)systemAtIndex:(int)sysIndex
{
	if (systemlist.count > 0)
	{
		assert(sysIndex >= 0 && sysIndex < systemlist.count);
		return [systemlist objectAtIndex:sysIndex];
	}
	else
		return NULL;
}

-(int)systemIndexAtPos:(CGPoint)pos
{
	int index = 0;
	for (NSValue *value in systemRects)
	{
		CGRect sysFrame = value.CGRectValue;//[self valueToRect:value];//
		if (pos.y < sysFrame.origin.y + sysFrame.size.height) // above bottom of sysFrame
		{
			return index;
		}
		++index;
	}
	return (index > 0) ? index - 1: 0;
}

// YOYOYO Good to here

-(CGPoint)topLeftAtSystemIndex:(int)sysIndex
{
    // MKMOD - removed creating a CGRect from system Rects
	if (sysIndex >= 0 && sysIndex < [systemRects count])
	{
		// MKMOD Prior to 3/20 code update, this was:
		// SSSystemView *sysView = [self systemViewForIndex:sysIndex];
		// if (sysView)
		// 	return sysView.topLeft; // MKMOD - was making a point from above rect
		// else // we may not have a SystemView placed here
		// {
        //     // MKMOD - tis was the call deleted above
		// 	CGRect rect = [[systemRects objectAtIndex:sysIndex] CGRectValue];
		// 	return CGPointMake(rect.origin.x, rect.origin.y);
		// }
	
		assert(sysIndex >= 0 && sysIndex < systemRects.count);
		
		// MKMODSS This if/else is now missing *from above):
		// if (sysView)
		// 	return sysView.topLeft; // MKMOD - was making a point from above rect
		// else // we may not have a SystemView placed here
		// {
            // MKMOD - this was the call deleted above
		NSValue *value = [systemRects objectAtIndex:sysIndex];
		CGRect rect = value.CGRectValue;//[self valueToRect:value];
		return CGPointMake(rect.origin.x, rect.origin.y);
		// }
	}
	return CGPointMake(0,0);
}

// YOYOYO Good to here

-(SSSystemView*)systemViewForIndex:(int)systemIndex
{
	for (UIView *v in [containedView subviews]) // cannot assume ordering of subviews
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if (sysView.systemIndex == systemIndex)
			{
				return sysView;
			}
		}
	}
	return nil;
}

-(bool)rect:(CGRect)rect contains:(CGPoint)pos
{
	return pos.x >= rect.origin.x && pos.x <= rect.origin.x + rect.size.width
		&& pos.y >= rect.origin.y && pos.y <= rect.origin.y + rect.size.height;
}

-(SSSystemView*)systemViewForPos:(CGPoint)pos
{
	UIView *v = [self hitTest:pos withEvent:nil];
	if (v != nil && [v isKindOfClass:SSSystemView.class])
		return (SSSystemView*)v;
	else
		return nil;
}

// YOYOYO Good to here

-(SSSystemPoint)systemAtPos:(CGPoint)pos
{
	SSSystemView* sysView = [self systemViewForPos:pos];
// MKMODSS	SSSystemPoint rval;
	if (sysView)
	{
		CGPoint posInSystem = [self convertPoint:pos toView:sysView];
		if (posInSystem.x >= 0 && posInSystem.y >= 0)
		{
			assert(exactModeZoomScale > 0.1);
			posInSystem = CGPointMake(posInSystem.x/exactModeZoomScale, posInSystem.y/exactModeZoomScale);
			SSSystem *system = sysView.system;
			if (system)
			{
				SSSystemPoint rval;
				memset(&rval, 0, sizeof(rval));
				rval.isValid = true;
				rval.systemIndex = sysView.systemIndex;
				rval.posInSystem = posInSystem;
				SSStaffLocation *sloc = [system staffLocationForPos:posInSystem maxLedgers:kMaxLedgers];
				rval.partIndex = sloc.partIndex;
				rval.barIndex = sloc.barIndex;
				rval.staffIndex = sloc.staffIndex;
				rval.staffLocation = sloc.location;
				rval.xLocation = sloc.xlocation;
				rval.lineSpaceIndex = sloc.lineSpaceIndex;
				return rval;
			}
		}
	}
	// MKMODDSS   Now:
	{
		SSSystemPoint rval = {false,-1,{0,0},-1, -1, -1, sscore_system_staffloc_undefined,0,sscore_system_xloc_undefined };
		return rval;
	}
	
	//MKMODSS    was:
    /*
	
		else
		{
			rval.partIndex = -1;
			rval.barIndex = -1;
			rval.staffIndex = 0;
			rval.staffLocation = sscore_system_staffloc_undefined;
		}
		rval.posInSystem = [self convertPoint:pos toView:sysView];
        // MKMOD - was modifying rval.posInSystem.y
	}
	else
	{
		rval.systemIndex = 0;
		rval.posInSystem = CGPointMake(0,0);
		rval.partIndex = -1;
		rval.barIndex = -1;
		rval.staffIndex = 0;
		rval.staffLocation = sscore_system_staffloc_undefined;
	}
	return rval;

	
	*/
	
}

-(CGPoint)systemTopLeft:(int)systemIndex
{
	return [self systemRect:systemIndex].origin;
}

-(int)numSystems
{
	return (int)systemRects.count;
}

-(CGRect)systemRect:(int)systemIndex
{
	if (systemIndex >= 0 && systemIndex < systemRects.count)
	{
		NSValue *value = [systemRects objectAtIndex:systemIndex];
		CGRect rect = value.CGRectValue;//[self valueToRect:value];
		rect.origin = [self topLeftAtSystemIndex:systemIndex]; // offset to allow for margin
		return rect;
	}
	else
		return CGRectMake(0,0,0,0);
}

-(CGPoint)posInViewForSystem:(int)systemIndex atPoint:(CGPoint)pos
{
	if (systemIndex >= 0 && systemIndex < systemRects.count)
	{
		assert(exactModeZoomScale > 0.1);
		SSSystemView* sysView = [self systemViewForIndex:systemIndex];
		if (sysView)
		{
			CGPoint p1 = CGPointMake(pos.x * exactModeZoomScale, pos.y * exactModeZoomScale);
			CGPoint p2 =  [self convertPoint:p1 fromView:sysView];
			return p2;
			
		}
	}
	return CGPointZero;
}

-(CGRect)rectInViewForSystem:(int)systemIndex rect:(CGRect)rect
{
	if (systemIndex >= 0 && systemIndex < systemRects.count)
	{
		assert(exactModeZoomScale > 0.1);
		SSSystemView* sysView = [self systemViewForIndex:systemIndex];
		if (sysView)
		{
			CGRect r1 = CGRectMake(rect.origin.x * exactModeZoomScale, rect.origin.y * exactModeZoomScale,
								   rect.size.width * exactModeZoomScale, rect.size.height * exactModeZoomScale);
			CGRect r2 =  [self convertRect:r1 fromView:sysView];
			return r2;
			
		}
	}
	return CGRectZero;
}

-(int)topLeftFullSystem
{
	int index = 0;
	CGPoint topLeft = self.bounds.origin;
	for (NSValue *value in systemRects)
	{
		CGRect sysFrame = [value CGRectValue];
		if (topLeft.y < sysFrame.origin.y + sysFrame.size.height/2) // include system if more than half visible
		{
			return index;
		}
		++index;
	}
	return (index > 0) ? index - 1: 0;
}

-(int)numFullSystemsDisplayed
{
	int index = 0;
	CGRect bounds = self.bounds;
	int rval = 0;
	for (NSValue *value in systemRects)
	{
		CGRect sysFrame = [value CGRectValue];
		if (sysFrame.origin.x > bounds.origin.x + bounds.size.height)
			break; // finished
		CGRect overlap = CGRectIntersection(sysFrame, bounds);
		if (overlap.size.height > sysFrame.size.height/2)
		{ // count system as visible if more than half is visble
			++rval;
		}
		++index;
	}
	return rval > 0 ? rval : systemRects.count > 0 ? 1 : 0; // don't return 0 unless there really are no systems at all to display
}

-(bool)isDisplayingStart
{
	return self.contentOffset.y <= 10;
}

-(bool)isDisplayingEnd
{
	if (systemlist.count > 0)
	{
		CGRect lastSysFrame = [systemRects.lastObject CGRectValue];
		int bottomSysIndex = [self bottomSystemIndex];
		int lastIndex = (int)systemlist.count - 1;
		float bottom = self.contentOffset.y + self.frame.size.height;
		float lastFrameBottom = lastSysFrame.origin.y + lastSysFrame.size.height;
		return bottomSysIndex == lastIndex && bottom >= lastFrameBottom;
	}
	else
		return YES;
}

-(bool)isDisplayingWhole
{
	return [self isDisplayingStart] && [self isDisplayingEnd];
}

-(int)barIndexForPos:(CGPoint)pos
{
	SSSystemView* sysView = [self systemViewForPos:CGPointMake(pos.x, pos.y)];
	if (sysView)
	{
		return [sysView.system barIndexForXPos:pos.x - sysView.frame.origin.x];
	}
	return -1; // not found
}

-(int)partIndexForPos:(CGPoint)pos;
{
	SSSystemView* sysView = [self systemViewForPos:CGPointMake(pos.x, pos.y)];
	if (sysView)
	{
		SSSystem *system = sysView.system;
		if (system)
			return [system partIndexForYPos:pos.y - sysView.frame.origin.y];
		else
			return -1; // not found
	}
	else
		return -1; // not found
}

// scrolling
- (void)scrollToSystem:(int)sysIndex
{
	if (score && systemlist.count > 0
		&& ![self isDisplayingWhole]) // the scroll view doesn't scroll if the score is not bigger than the
	{							// displayed height, even if it is scrolled of the top - so we prevent this
		CGPoint pos = CGPointMake(0, [self topLeftAtSystemIndex:sysIndex].y);
		bool animate = fabs(pos.y - self.contentOffset.y) < kMaxAnimateScrollDistance;
		if (animate)
		{
			[UIView animateWithDuration:kScrollAnimationDuration
								  delay:0
								options:UIViewAnimationOptionCurveEaseOut
							 animations:^{
								 self.contentOffset = pos;
							 }
							 completion:nil];
		}
		else
			[self setContentOffset:pos animated:animate];
	}
}

-(SSSystem*)systemContainingBarIndex:(int)barIndex
{
	for (SSSystem *sys in systemlist)
	{
		if ([sys includesBar:barIndex])
			return sys;
	}
	return nil;
}

- (void)scrollToBar:(int)barIndex
{
	if (score && systemlist.count > 0
		&& ![self isDisplayingWhole]) // the scroll view doesn't scroll if the score is not bigger than the
	{							// displayed height, even if it is scrolled of the top - so we prevent this
		int sysIndex = [self systemContainingBarIndex:barIndex].index;
		[self scrollToSystem:sysIndex];
	}
}

// YOYOYO Good to here

-(void)scrollToBarContinuous:(int)barIndex
{
	assert(barIndex >= 0 && barIndex < score.numBars);
	if (score && systemlist.count > 0 && systemRects.count > 0
		&& ![self isDisplayingWhole]) // the scroll view doesn't scroll if the score is not bigger than the
	{							// displayed height, even if it is scrolled of the top - so we prevent this
		SSSystem* sys = [self systemContainingBarIndex:barIndex];
		if (sys != nil) //  when rotating device while playing - tries to scroll to bar which is not yet laid out)
		{
			assert(sys.index >= 0 && sys.index < systemRects.count);
			CGRect sysFrame = [[systemRects objectAtIndex:sys.index] CGRectValue];
			float windowHeight = self.bounds.size.height;
			float windowPlayingCentre = kWindowPlayingCentreFractionFromTop * windowHeight;
			float sysFrac = (float)(barIndex - sys.barRange.startbarindex) / (float)sys.barRange.numbars;
			float playingCentre = sysFrame.origin.y + sysFrame.size.height * sysFrac;
			float scrolly = playingCentre - windowPlayingCentre;
			if (scrolly > self.contentSize.height - windowHeight)
				scrolly = self.contentSize.height - windowHeight;
			else if (scrolly < 0)
				scrolly = 0;
			CGPoint os = CGPointMake(0, scrolly);
			[UIView animateWithDuration:kScrollAnimationDuration
								  delay:0
								options:UIViewAnimationOptionCurveEaseOut
							 animations:^{
								 self.contentOffset = os;
							 }
							 completion:nil];
		}
	}
}

-(void)scroll:(int)percent
{
	if (score && systemlist.count > 0
		&& ![self isDisplayingWhole]) // the scroll view doesn't scroll if the score is not bigger than the
	{							// displayed height, even if it is scrolled of the top - so we prevent this
		CGRect frame = self.frame;
		CGSize contentSize = self.contentSize;
		CGPoint startContentOffset = self.contentOffset;
		CGPoint newTopLeftOffset = CGPointMake(0, startContentOffset.y + frame.size.height * ((float)percent / 100.0F));
		if (newTopLeftOffset.y + frame.size.height > contentSize.height)
		{
			// special case for bottom
			newTopLeftOffset = CGPointMake(0, contentSize.height - frame.size.height); // don't scroll beyond bottom/right
			[UIView animateWithDuration:kScrollAnimationDuration
								  delay:0
								options:UIViewAnimationOptionCurveEaseOut
							 animations:^{
								 self.contentOffset = newTopLeftOffset;
							 }
							 completion:nil];
		}
		else if (newTopLeftOffset.y < 0)
		{
			// special case for top
			[UIView animateWithDuration:kScrollAnimationDuration
								  delay:0
								options:UIViewAnimationOptionCurveEaseOut
							 animations:^{
								 self.contentOffset = CGPointMake(0, 0);// don't scroll above top
							 }
							 completion:nil];
		}
		else if (percent > 0)
		{
			// scroll to nearest system top above
			for (int sysIndex = 1; sysIndex < systemlist.count; ++sysIndex)
			{
				CGPoint pos = [self topLeftAtSystemIndex:sysIndex];
				if (pos.y > startContentOffset.y // ensure we go  DOWN
					&& pos.y > newTopLeftOffset.y)
				{
					// scroll to system top
					[self scrollToSystem:sysIndex - 1];
					return;
				}
			}
		}
		else
		{
			// scroll to nearest system top above
			for (int sysIndex = (int)systemlist.count-1; sysIndex >= 0; --sysIndex)
			{
				CGPoint pos = [self topLeftAtSystemIndex:sysIndex];
				if (pos.y < startContentOffset.y && pos.y < newTopLeftOffset.y) // ensure we go UP
					
				{
					// scroll to system top
					[self scrollToSystem:sysIndex + 1];
					return;
				}
			}
		}
	}
}


-(float)cursorAnimationDuration
{
	return [CATransaction animationDuration];
}

// MKMOD - added this method   4/1/17
-(void)displayCursor
{
	showingCursor = false;

	if (!useSeeScoreCursor)  // MKMOD
       return;
	   
    
	int sysIndex = [self systemContainingBarIndex:cursorBarIndex].index;
	// show cursor in correct system and hide it in all others
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if (sysView.systemIndex == sysIndex)
			{
				if (cursor_xpos == 0)
				{
					[sysView showCursorAtBar:cursorBarIndex pre:cursorType==cursor_line];
				}
				else
				{
					[sysView showCursorAtXpos:cursor_xpos barIndex:cursorBarIndex];
				}
				showingCursor = true;
			}
			else
			{
				[sysView hideCursor];
			}
		}
	}
}

// MKMOD - GitKraken compare very confused here. May not have changed anything
-(void)setCursor:(int)barIndex
			xpos:(float)xpos
			type:(enum CursorType_e)type
		  scroll:(enum ScrollType_e)scroll
{
    if (!useSeeScoreCursor)
        return;
    
	assert(barIndex >= 0 && barIndex < score.numBars);
	if (score && systemlist.count > 0)
	{
		cursorBarIndex = barIndex;
		showingCursor = true;
		cursorType = type;
		cursor_xpos = xpos;
		// scroll to system first so that the system is displayed and we can show the cursor
		if (scroll != scroll_off
			&& self.contentSize.height > self.frame.size.height) // don't scroll if content height is less than screen height
		{
			if (scroll == scroll_system)
			{
				[self scrollToBar:barIndex];
			}
			else if (scroll == scroll_bar)
			{
				[self scrollToBarContinuous:barIndex];
			}
		}
		[self displayCursor];
	}
}

-(void)setCursorAtBar:(int)barIndex
				 type:(enum CursorType_e)type
			   scroll:(enum ScrollType_e)scroll
{
	if (!useSeeScoreCursor)
        return;
    
	[self setCursor:barIndex
			   xpos:0
			   type:type
			 scroll:scroll];
}

-(void)setCursorAtXpos:(float)xpos
			  barIndex:(int)barIndex
				scroll:(enum ScrollType_e)scroll
{
    if (!useSeeScoreCursor)
        return;
    
	[self setCursor:barIndex
			   xpos:xpos * exactModeZoomScale
			   type:cursor_line
			 scroll:scroll];
}

-(void)hideCursor
{
	showingCursor = false;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView hideCursor];
		}
	}
}

// YOYOYO Good to here

-(SSCursorRect)barRectangle:(int)barIndex
{
	SSSystem *system = [self systemContainingBarIndex:barIndex];
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if (sysView.system == system)
			{
				return [sysView barRectangle:barIndex];
			}
		}
	}
	SSCursorRect rval = {0,{{0,0},{0,0}}};
	return rval;
}

-(void)colourPDNotes:(NSArray*)pdnotes colour:(UIColor*)colour
{
	static const unsigned coloured_render = sscore_dopt_colour_notehead | sscore_dopt_colour_ledger;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			NSMutableDictionary<NSValue*, SSColouredItem*> *colouredItems = NSMutableDictionary.dictionary; // use a dictionary to ensure each item is only coloured once
			// add existing coloured items
			for (SSColouredItem *item in sysView.colourRender.colouredItems)
			{
				[colouredItems setObject:item forKey:[NSNumber numberWithUnsignedLongLong:item.item_h]];
			}
			for (SSPDNote *note in pdnotes)
			{
				if ([sysView.system includesBar:note.startBarIndex])
				{
					SSColouredItem *item = [[SSColouredItem alloc] initWithItem:note.item_h colour:colour.CGColor render:coloured_render];
					[colouredItems setObject:item forKey:[NSNumber numberWithUnsignedLongLong:item.item_h]];
				}
			}
			// MKMODSS:  NOt in new code: // add existing coloured items
			// MKMODSS:  NOt in new code: [colouredItems addObjectsFromArray:sysView.colourRender.colouredItems];
			SSColourRender *render = [[SSColourRender alloc] initWithItems:colouredItems.allValues];
			[sysView setColourRender:render];
		}
	}
}

-(void)colourComponents:(NSArray*)components colour:(UIColor *)colour elementTypes:(unsigned)elementTypes
{
	[colouringsForSystems removeAllObjects]; // clear all colourings in invisible systems
    // MKMOD - added this entire for loop
	for (SSComponent *comp in components)
	{
		SSSystem *system = [self systemContainingBarIndex:comp.barIndex];
		NSNumber *key = [NSNumber numberWithInt:system.index];
		SSColouredItem *item = [[SSColouredItem alloc] initWithItem:comp.item_h colour:colour.CGColor render:elementTypes];
		NSMutableArray<SSColouredItem*> *newColouredItems = NSMutableArray.array;
		SSColourRender *colourRender = [colouringsForSystems objectForKey:key];
		if (colourRender && colourRender.colouredItems.count > 0)
			[newColouredItems addObjectsFromArray:colourRender.colouredItems];
		[newColouredItems addObject:item];
		SSColourRender *newColourRender = [[SSColourRender alloc] initWithItems:newColouredItems];
		[colouringsForSystems setObject:newColourRender forKey:key];
	}
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
            // MKMOD - deleted 11 lines
            
            // MKMOD - added these 2 lines
			NSNumber *key = [NSNumber numberWithInt:sysView.systemIndex];
			SSColourRender *colourRender = [colouringsForSystems objectForKey:key];
			[sysView setColourRender:colourRender];
		}
	}
}

-(void)showVoiceTracks:(bool)show
{
	showingVoiceTracks = show;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView showVoiceTracks:show];
		}
	}
}

-(void)clearColouringForBarRange:(const sscore_barrange*)barrange
{
	// clear colourings for hidden systems in bar range
	// NB this clears colourings for each whole system which includes the bar range not just the bar range
	for (SSSystem *system in systemlist)
	{
		if ([system includesBarRange:barrange])
			[colouringsForSystems removeObjectForKey:[NSNumber numberWithInt:system.index]];
	}
	// clear colourings in bar range in displayed systems
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if ([sysView.system includesBarRange:barrange])
			{
				[sysView clearColourRenderForBarRange:barrange];
			}
		}
	}
}

-(void)clearAllColouring
{
	[colouringsForSystems removeAllObjects]; // clear all colourings in invisible systems
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView clearColourRender];
		}
	}
}

// MKMODSS - newcode deleted this method     
/*
-(void)didRotate
{
	[self clearPlayLoopGraphics];
	if (score)
		[self relayout];
}
*/


- (void)didReceiveMemoryWarning
{
	[self abortBackgroundProcessing:^{
		//release everything and setup again - what else can we do?
		[self removeAllSystems];
		int64_t delayInSeconds = 2.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self relayout];
		});
	}];
}

// MKMODSS - newcode deleted these methods     
/*
// zoom

-(void)zoomSystem:(SSSystemView *)sysView zoom:(float)zoom height:(float)sysheight space:(float)sysSpacing ypos:(float)ypos
{
	assert(sysView.systemIndex >= 0 && sysView.systemIndex < systemRects.count);
	CGRect rect = [[systemRects objectAtIndex:sysView.systemIndex] CGRectValue];
	rect.origin.y = ypos;
	rect.size.height = sysheight;
	rect.size.width *= zoom;
	sysView.frame = rect;
	[sysView zoomUpdate:zoom];
}

// magnify num systems, for interactive pinch zoom, from system at startIndex
// Downwards if inc = +1, upwards if inc = -1
-(void)zoomSystems:(float)zoom
			 start:(int)startIndex
			   num:(int)num
			  ypos:(float)ypos
			   inc:(int)inc
	 systemSpacing:(float)systemSpacing
	   systemsDict:(NSDictionary*)dict // SystemView* indexed by system index
{
	assert(systemlist.count > 0);
	for (int i = 0; i < num; ++i)
	{
		int sysIndex = startIndex + i*inc;
		if (sysIndex >= 0 && sysIndex < systemlist.count)
		{
			SSSystemView *sysView = [dict objectForKey:[NSNumber numberWithInt:sysIndex]];
			if (sysView)
			{
				assert(sysIndex == sysView.systemIndex);
				assert(sysIndex < systemRects.count);
				float systemHeight = [self systemHeight:sysIndex zoom:zoom];
				if (inc < 0)
					ypos -= systemHeight + systemSpacing * -inc;
				[self zoomSystem:sysView zoom:zoom height:systemHeight space:systemSpacing ypos:ypos];
				if (inc > 0)
					ypos += systemHeight + systemSpacing * inc;
			}
		}
	}
}

-(void)zoomMagnify:(float)zoom
{
	if (score && systemlist.count > 0)
	{
		int topPlacedSystem = [self firstSystemIndex];
		float systemSpacing = ((SSSystem*)systemlist.firstObject).defaultSpacing * zoom;
		int numPlacedSystems = (int)[self systemIndexSet].count;
		if (numPlacedSystems > 0)
		{
			// put all displayed systems into dict keyed by sys index
			NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
			for (UIView *v in [containedView subviews])
			{
				if ([v isKindOfClass:[SSSystemView class]])
				{
					SSSystemView *sysView = (SSSystemView*)v;
					int sysIndex = sysView.systemIndex;
					[dict setObject:sysView forKey:[NSNumber numberWithInt:sysIndex]];
				}
			}
			// magnify around middle system
			int centreSystemIdx = topPlacedSystem + numPlacedSystems/2;
			float centreSystem_ypos;
			{
				// find the ypos of the centre-most system. We will keep the top left of this system unmoved during zoom
				assert(centreSystemIdx >= 0 && centreSystemIdx < systemRects.count);
				centreSystem_ypos = [[systemRects objectAtIndex:centreSystemIdx] CGRectValue].origin.y;
			}
			// magnify from vertical centre downwards
			[self zoomSystems:zoom
						start:centreSystemIdx
						  num:1+numPlacedSystems/2
						 ypos:centreSystem_ypos
						  inc:+1
				systemSpacing:systemSpacing
				  systemsDict:dict];
			// magnify from vertical centre upwards
			[self zoomSystems:zoom
						start:centreSystemIdx-1
						  num:numPlacedSystems/2
						 ypos:centreSystem_ypos
						  inc:-1
				systemSpacing:systemSpacing
				  systemsDict:dict];
		}
	}
}
*/

-(void)enablePinch
{
	if (!isPinchEnabled)
	{
		isPinchEnabled = true;
		[self.pinchGestureRecognizer setEnabled:isPinchEnabled];
	}
}
-(void)disablePinch
{
	if (isPinchEnabled)
	{
		isPinchEnabled = false;
		[self.pinchGestureRecognizer setEnabled:isPinchEnabled];
	}
}


//UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return containedView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	activeZooming = true;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
					   withView:(UIView *)view
						atScale:(CGFloat)scale
{
	activeZooming = false;
    bool exactLayout = false; // self.layoutOptions.useXMLxLayout;
	if (exactLayout)
	{
		// we redraw the systems at the new size (layoutSubviews), but preserve the (expensive) score layout of each system.
		// If we don't redraw (setNeedsLayout) this just produces a pixelated magnified image with low quality at high magnification
		assert(scale == self.zoomScale);
		exactModeZoomScale *= scale;
		if (exactModeZoomScale < kMinExactMagnification)
			exactModeZoomScale = kMinExactMagnification;
		
		// preserve content offset to be reset in layoutSubviews
		preservedContentOffset = self.contentOffset;

		self.minimumZoomScale = kMinExactMagnification / exactModeZoomScale;
		self.maximumZoomScale = kMaxMagnification / exactModeZoomScale;
		[self removeAllSystems];
		[self setNeedsLayout];
	}
	else
	{
		exactModeZoomScale = 1.0;
		self.magnification *= scale;
		self.minimumZoomScale = kMinMagnification / self.magnification;
		self.maximumZoomScale = kMaxMagnification / self.magnification;
	}
	self.zoomScale = 1.0;
	[self.scrollDelegate changedZoom];
}
//end UIScrollViewDelegate

-(void)displayPlayLoopGraphicsLeft:(int)leftLoopBarIndex right:(int)rightLoopBarIndex
{
	[self clearPlayLoopGraphics];
	SSSystem *leftSystem = [self systemContainingBarIndex:leftLoopBarIndex];
	SSSystem *rightSystem = [self systemContainingBarIndex:rightLoopBarIndex];
	CGPoint leftSystemTopLeft = [self topLeftAtSystemIndex:leftSystem.index];
	CGPoint rightSystemTopLeft = [self topLeftAtSystemIndex:rightSystem.index];
	playLoopGraphics = [[SSPlayLoopGraphics alloc] initWithNumParts:score.numParts
														 leftSystem:leftSystem leftSystemTopLeft:(CGPoint)leftSystemTopLeft leftBarIndex:leftLoopBarIndex
														rightSystem:rightSystem rightSystemTopLeft:(CGPoint)rightSystemTopLeft rightBarIndex:rightLoopBarIndex
															   zoom:exactModeZoomScale
															 colour:UIColor.blueColor];
	[self.layer addSublayer:playLoopGraphics.background];
	[self.layer addSublayer:playLoopGraphics.foreground];
	[self setNeedsDisplay];
}

-(void)clearPlayLoopGraphics
{
	if (playLoopGraphics)
	{
		[playLoopGraphics.background removeFromSuperlayer];
		[playLoopGraphics.foreground removeFromSuperlayer];
		playLoopGraphics = nil;
		[self setNeedsDisplay];
	}
}

// MKMOD  deleted method warnShowingKeyboardRect
// MKMOD  deleted method warnHidingKeyboard
// MKMOD  deleted method ensureVisible

-(NSArray<SSComponent*> *)componentsAt:(CGPoint)p maxDistance:(float)maxDistance
{
	SSSystemPoint sysPt = [self systemAtPos:p];
	if (sysPt.isValid)
	{
		SSSystem *sys = [self systemAtIndex:sysPt.systemIndex];
		if (sys)
		{
			NSArray<SSComponent*> *components = [sys hitTest:sysPt.posInSystem];
			if (components.count == 0)
			{
				// if the tap didn't actually hit a component lets look at close components
				components = [sys closeFeatures:sysPt.posInSystem distance:maxDistance];
			}
			return components;
		}
	}
	return NSArray.array;
}

// MKMOD  deleted method tap
// MKMOD  deleted method pan

#ifdef DrawOutline
- (void)drawRect:(CGRect)rect
{
    CGRect frm = self.frame
    
 // LEAVING FOR LONGTONE WORK     NSLog(@"\nWHITE TRACKING #1  : SSCrollView::drawRect()\n");
    
	[super drawRect:rect];  // MKMOD - uncommeneted this - 11/20/17  MKMODSS - line was still commented in 3/19 update
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor (ctx, UIColor.greenColor.CGColor);
	CGContextStrokeRect(ctx, rect);
    // MKMOD  added this for loop   4/1/17
	for (NSValue *val in systemRects)
	{
		CGContextSetStrokeColorWithColor (ctx, UIColor.blueColor.CGColor);
		CGContextStrokeRect(ctx, CGRectInset(val.CGRectValue, 1,1));
	}

    // MKMOD - added from here to end of method - 11/20/17
    CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(ctx, red);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 100.0f, 20.0f);
    CGContextAddLineToPoint(ctx, 100.0f, 120.0f);
    CGContextStrokePath(ctx);

    /*


    UIBezierPath *line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake( 400.0f, 20.0f)];
    [line addLineToPoint:CGPointMake( 400.0f, 20.0f)];
    [line setLineWidth:5.0]; /// Make it easy to see
 //   [[self lineColor] set]; /// Make future drawing the color of lineColor.
    [line stroke];
 //   CGContextStrokePath(ctx, line);
     */
}
#endif

-(void)drawItemOutline:(SSEditItem*)editItem systemIndex:(int)systemIndex ctx:(CGContextRef)ctx
				colour:(CGColorRef)colour margin:(CGFloat)margin linewidth:(CGFloat)lineWidth
{
	SSSystemView* sysView = [self systemViewForIndex:systemIndex];
	if (sysView)
	{
		CGPoint origin = self.frame.origin;
		CGPoint scrollOffset = self.contentOffset;
		CGPoint tl = CGPointMake(origin.x - scrollOffset.x, origin.y - scrollOffset.y);
		[sysView drawItemOutline:editItem ctx:ctx topLeft:tl colour:colour margin:margin linewidth:lineWidth];
	}
}

-(void)drawItemDrag:(SSEditItem*)editItem systemIndex:(int)systemIndex ctx:(CGContextRef)ctx dragPos:(CGPoint)dragPos showTargetDashedLine:(bool)showTargetDashedLine
{
	SSSystemView* sysView = [self systemViewForIndex:systemIndex];
	if (sysView)
	{
		CGPoint origin = self.frame.origin;
		CGPoint scrollOffset = self.contentOffset;
		CGPoint tl = CGPointMake(origin.x - scrollOffset.x, origin.y - scrollOffset.y);
		[sysView drawItemDrag:editItem ctx:ctx topLeft:tl dragPos:dragPos showTargetDashedLine:showTargetDashedLine];
	}
}

-(void)selectVoice:(NSString*)voice systemIndex:(int)systemIndex partIndex:(int)partIndex
{
	SSSystemView* sysView = [self systemViewForIndex:systemIndex];
	if (sysView)
	{
		[sysView.system selectVoice:voice partIndex:partIndex];
		[sysView setNeedsDisplay];
	}
}


- (void)deselectVoice {
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView.system deselectVoice];
			[sysView setNeedsDisplay];
		}
	}
}

-(SSTargetLocation*)nearestInsertTargetFor:(SSEditType*)editType at:(CGPoint)pos maxDistance:(CGFloat)maxDistance
{
	SSSystemView* sysView = [self systemViewForPos:pos];
	if (sysView)
	{
		CGPoint sysPos = [self convertPoint:pos toView:sysView];
		return [sysView nearestInsertTargetFor:editType at:sysPos maxDistance:maxDistance];
	}
	return nil;
}


-(CGPoint)nearestNoteInsertPos:(CGPoint)pos editType:(SSEditType* _Nonnull)editType maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers
{
	SSSystemView* sysView = [self systemViewForPos:pos];
	if (sysView)
	{
		SSNoteInsertPos nip = [sysView nearestNoteInsertPos:[self convertPoint:pos toView:sysView] editType:editType maxDistance:maxDistance maxLedgers:maxLedgers];
		return [sysView convertPoint:nip.pos toView:self];
	}
	return CGPointZero;
}

-(int)nearestSystemIndexAtYpos:(CGFloat)ypos
{
	int index = 0;
	for (NSValue *systemRect in systemRects)
	{
		CGRect sysFrame = systemRect.CGRectValue;
		if (ypos < sysFrame.origin.y + sysFrame.size.height)
			return index;
		++index;
	}
	return index;
}

-(SSSystemView* _Nullable)systemViewContainingItem:(SSEditItem* _Nonnull)editItem
{
	int barIndex = editItem.barIndex;
	if (barIndex >= 0)
	{
		SSSystem* system = [self systemContainingBarIndex:barIndex];
		if (system)
		{
			return [self systemViewForIndex:system.index];
		}
	}
	return nil;
}

-(CGPoint)nearestNoteReinsertPos:(CGPoint)pos editItem:(SSEditItem* _Nonnull)editItem maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers
{
	// find the system containing this item
	SSSystemView* sysView = [self systemViewContainingItem:editItem];
	if (sysView)
	{
		SSNoteInsertPos nip = [sysView nearestNoteReinsertPos:[self convertPoint:pos toView:sysView] editItem:editItem maxDistance:maxDistance maxLedgers:maxLedgers];
		if (nip.defined)
			return [self convertPoint:nip.pos fromView:sysView];
	}
	return CGPointZero;
}

//@protocol BarControlProtocol
// for BarControl

// get the total number of bars
- (int)totalBars
{
	if (score)
	{
		return score.numBars;
	}
	else
		return 0;
}

// get the start and number of bars displayed
- (int)startBarDisplayed
{
	if (systemlist.count > 0)
	{
		int topSystemIndex = [self topLeftFullSystem];
		SSSystem *system = [self systemAtIndex:topSystemIndex];
		assert(system);
		return system.barRange.startbarindex;
	}
	else
		return 0;
}

- (int)numBarsDisplayed
{
	if (systemlist.count > 0)
	{
		int total = 0;
		int topSystemIndex = [self topLeftFullSystem];
		int numSystems = [self numFullSystemsDisplayed];
		for (int i = 0; i < numSystems; ++i)
		{
			int sysIndex = topSystemIndex + i;
			SSSystem *system = [self systemAtIndex:sysIndex];
			total += system.barRange.numbars;
		}
		return total;
	}
	else
		return 0;
}

- (int)numBarsLoaded
{
	if (systemlist.count > 0)
	{
		int total = 0;
		for (SSSystem *sys in systemlist)
		{
			total += sys.barRange.numbars;
		}
		return total;
	}
	else
		return 0;
}

// barcontrol cursor moved
- (void)cursorChanged:(int)cursorIndex
{
   // return;
    
	[self scrollToBar:cursorIndex];
}
//@end

// MKMOD  added this method 4/1/17
-(void)setCursorColour:(UIColor*)colour
{
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]]) // ignore SSEditLayer
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView setCursorColour:colour];
		}
	}
}

// Handle efficient redisplay after edit

//@protocol ScoreChangeHandler
-(void)change:(sscore_state_container *)prevstate newstate:(sscore_state_container *)newstate reason:(int)reason
{
	if (sscore_edit_partCountChanged(prevstate, newstate)
		|| sscore_edit_barCountChanged(prevstate, newstate)
		|| sscore_edit_headerChanged(prevstate, newstate)
		|| sscore_edit_systemBreakChanged(prevstate, newstate))
	{
		if (sscore_edit_partCountChanged(prevstate, newstate))
		{
			NSMutableArray *arr = NSMutableArray.array;
			for (int i = 0; i < score.numParts; ++i)
			{
				[arr addObject:[NSNumber numberWithBool: true]]; // display all parts if number of parts changes
			}
			displayingParts = arr;
		}
		dispatch_async(dispatch_get_main_queue(), ^{ // get off this thread - relayout can remove ScoreChangeHandler listeners which upsets the caller
			[self relayout]; // part count or bar count changed - complete relayout (we could preserve all systems before the 1st changed bar)
		});
	}
	else
	{
		int changedSystemCount = 0;
		for (SSSystem *sys in systemlist)
		{
			sscore_barrange br = sys.barRange;
			for (int i = 0 ; i < br.numbars; ++i)
			{
				int barIndex = br.startbarindex + i;
				if (sscore_edit_barChanged(barIndex, prevstate, newstate))
				{
					changedSystemCount++;
					break; // test next system
				}
			}
		}
		if (changedSystemCount > 0)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				if (changedSystemCount > 1)
					[self relayout]; // more than 1 system affected - complete relayout
				else if (changedSystemCount == 1) // only 1 system changed (probably 1 bar) - just update that system
					[self setNeedsLayout];
			});
			// else nothing changed
			
			/*
			// MKMODSS  Above was:
		if (changedViews.count > 1)
		{
        	// MKMOD  deleted 5 lines here   4/1/17
			dispatch_async(dispatch_get_main_queue(), ^{ // get off this thread - relayout can remove ScoreChangeHandler listeners which upsets the caller
				[self relayout]; // more than 1 system affected - complete relayout
			});
		}
		else if (changedViews.count == 1) // only 1 system changed (probably 1 bar) - just update that
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[self setNeedsLayout];
			});
		}
		// else nothing changed
		*/	
			
		}
	}
}
//@end

//@protocol SSViewInterface

-(float)drawScale
{
	return _magnification * exactModeZoomScale;
}

-(CGRect)frame
{
	return super.frame;
}

-(void)setFrame:(CGRect)f
{
	super.frame = f;
}

-(bool)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	return [super pointInside:point withEvent:event];
}

-(void)displayFakeRepeatBarlineLeft:(int)barIndex
{
	[self clearPlayLoopGraphics];
	SSSystem *system = [self systemContainingBarIndex:barIndex];
	CGPoint systemTopLeft = [self topLeftAtSystemIndex:system.index];
	playLoopGraphics = [[SSPlayLoopGraphics alloc] initWithNumParts:score.numParts
														 leftSystem:system leftSystemTopLeft:systemTopLeft leftBarIndex:barIndex
														rightSystem:nil rightSystemTopLeft:CGPointZero rightBarIndex:0
															   zoom:exactModeZoomScale
															 colour:UIColor.blueColor];
	[self.layer addSublayer:playLoopGraphics.background];
	[self.layer addSublayer:playLoopGraphics.foreground];
	[self setNeedsDisplay];
}

-(void)displayFakeRepeatBarlineRight:(int)barIndex
{
	[self clearPlayLoopGraphics];
	SSSystem *system = [self systemContainingBarIndex:barIndex];
	CGPoint systemTopLeft = [self topLeftAtSystemIndex:system.index];
	playLoopGraphics = [[SSPlayLoopGraphics alloc] initWithNumParts:score.numParts
														 leftSystem:nil leftSystemTopLeft:CGPointZero leftBarIndex:0
														rightSystem:system rightSystemTopLeft:systemTopLeft rightBarIndex:barIndex
															   zoom:exactModeZoomScale
															 colour:UIColor.blueColor];
	[self.layer addSublayer:playLoopGraphics.background];
	[self.layer addSublayer:playLoopGraphics.foreground];
	[self setNeedsDisplay];
}

-(void)clearFakeRepeatBarlines
{
	[self clearPlayLoopGraphics];
}

// YOYOYO

-(void) showAnalysisOverview:(BOOL) iShow
{
    if (analysisOverlayView == nil )
    {
        doShowAnalysisOverlayView = iShow;
        analysisOverlayView.hidden = !doShowAnalysisOverlayView;
    }
}

// MKMOD - added addOverlayView - 11/20/17
-(void) addOverlayView
{
    if (analysisOverlayView == nil )
    {
        CGRect frame = containedView.frame;
        analysisOverlayView = [[FSAnalysisOverlayView alloc] initWithFrame:frame];
        [analysisOverlayView setBackgroundColor:[UIColor clearColor]];
        [containedView addSubview:analysisOverlayView];
        // MKMOD - removed setting delegate - 12/12/17
    }
}

// MKMOD - added addNotePerformanceResultAtXPos - 11/20/17
// MKMOD - changed param list- 12/12/17
// MKMOD - changed to addScoreObjectPerformanceResultAtXPos - 7/26/17
// For displaying student performance results
-(void) addScoreObjectPerformanceResultAtXPos:(CGFloat) iXPos
                                       atYpos:(CGFloat) iYPos // MKMOD - added 2/14/18
                           withWeightedRating:(int)  iWeightedRating
                                       isNote:(bool)isNote          // MKMOD - changed 7/26/17
                             withNoteOrRestID:(int) iNoteOrRestID   // MKMOD - changed 7/26/17
                                scoreObjectID:(int) iScoreObjectID  // MKMOD - changed 7/26/17
                                     isLinked:(bool) isLinked
                                linkedSoundID:(int)  iLinkedSoundID
{
    if (analysisOverlayView)
    {
        // MKMOD - changed param list- 12/12/17
        [analysisOverlayView addScoreObjectAtXPos: iXPos    // MKMOD - changed 7/26/17
                                           atYpos: iYPos  // MKMOD - added 2/14/18
                               withWeightedRating: iWeightedRating
                                           isNote: isNote           // MKMOD - changed 7/26/17
                                 withNoteOrRestID: iNoteOrRestID    // MKMOD - changed 7/26/17
                                    scoreObjectID: iScoreObjectID   // MKMOD - changed 7/26/17
                                         isLinked: isLinked
                                    linkedSoundID: iLinkedSoundID];
    }
}

// MKMOD - added updateNotePerformanceResultAtXPos - 11/20/17
// MKMOD - removed updateNotePerformanceResultAtXPos - 7/26/18

// MKMOD - added addSoundPerformanceResultAtXPos - 12/12/17
-(void) addSoundPerformanceResultAtXPos:(CGFloat) iXPos
                           withDuration:(int) iDuration
                                soundID:(int) iSoundID
                               isLinked:(bool) isLinked
                           linkedNoteID:(int) iLinkedNoteID
{
    if (analysisOverlayView)
    {
        [analysisOverlayView addSoundAtXPos: iXPos
                               withDuration: iDuration
                                    soundID: iSoundID
                                   isLinked: isLinked
                               linkedNoteID: iLinkedNoteID ];
    }
}

// MKMOD - added getCurrentXOffset - 12/12/17
-(CGFloat) getCurrentXOffset
{
    CGPoint currOrg = [[self.layer presentationLayer] bounds].origin;
    CGFloat pXPos = currOrg.x;
    return pXPos;
}

// MKMOD - added 2/14/18
// MKMOD - changed from highlightNote to highlightScoreObject - 7/26/18
-(bool) highlightScoreObject:(int) iScoreObjectID
                    severity:(int) iSeverity
{
    CGFloat xPos = 0.0;
    if (analysisOverlayView)
    {
        // MKMOD - changed analysisOverlayView method call - 7/26/18
        bool found = [analysisOverlayView highlightScoreObject: iScoreObjectID
                                                       useXPos: &xPos
                                                      severity: iSeverity ];
        if (found)
        {
            CGPoint pos = CGPointMake(xPos-kHighlightNoteXOffset, 0);
            [self setContentOffset:pos animated:true];
            return true;
        }
    }
    return false;
}

// MKMOD - added 2/14/18
-(void) turnHighlightOff
{
    if (analysisOverlayView)
        [analysisOverlayView hideHighlight];
}

// MKMOD - added clearNotePerformanceResultAtXPos - 11/20/17
-(void) clearNotePerformanceResultAtXPos:(CGFloat) iXPos
{
}

// MKMOD - added clearNotePerformanceResults - 11/20/17
-(void) clearNotePerformanceResults
{
    [analysisOverlayView clearPerfNoteAndSoundData];
}

-(void) clearScoreIsSetup
{
    _scoreIsSetup = NO;
    _layoutCompletedAfterScoreSetup = NO;
    _layoutFrozen = NO;
}

-(void) freezeLayout;
{
    // Keeps the SeeScore view from thrashing through unneeded
    // (and error-producing) calls to LayoutSubviews, etc.
    _layoutFrozen = YES;
}

// MKMOD - added noteTappedAtXCoord - 11/20/17
// MKMOD - deleted noteTappedAtXCoord - 12/12/17

-(void) clearCurrNoteLines {
    [analysisOverlayView clearCurrNoteLines];
}

-(void) drawCurrNoteLineAt:(CGFloat) iXPos {
    [analysisOverlayView drawCurrNoteLineAt: iXPos];
}

-(void) useSeeScoreCursor:(BOOL) iUseSSCursor {
    useSeeScoreCursor = iUseSSCursor;
}

// MKMOD - changed logic in method - 11/12/17
// Added use of kMKDebugOpt_NoteAnalysisRespondsToTouch - 12/17/17
// Added more use of kMKDebugOpt_NoteAnalysisRespondsToTouch ? - 2/14/18
// Added if [FSAnalysisOverlayView  getShowNotesAnalysis] in method body - 2/14/18
-(void)touchesBegan: (NSSet*) touches
          withEvent: (UIEvent*) event
{
    UITouch *t = [touches anyObject];
    CGPoint _downLocation =[t locationInView:self];

    BOOL scrEnabled = self.scrollEnabled;
    self.scrollEnabled = YES;
    scrEnabled = self.scrollEnabled;

    
    CGFloat touchX = _downLocation.x;
    // MKMOD - changed these two lines - 7/26/18
    int scoreObjectID = [analysisOverlayView findScoreObjectIDFromXPos: touchX];
    if ( scoreObjectID >= 0 ) // -1 means not found
    {
         if ( self.overlayViewDelegate )
            // MKMOD - changed this line - 7/26/18
            [self.overlayViewDelegate noteTappedWithThisID: scoreObjectID];
    }
}

@end
