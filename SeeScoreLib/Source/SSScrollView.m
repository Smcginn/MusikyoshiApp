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
static const CGSize kMargin = {0,0}; // L/R margins

static const float kWindowPlayingCentreFractionFromTop = 0.333; // autoscroll centres the current playing system around here

static const int kMaxRecycleListSize = 5; // no point in recycling too many views

static const float kMaxAnimateScrollDistance = 1000; // if we animate the scroll over a long distance it's very slow as it has to redraw all intermediate positions
static const float kScrollAnimationDuration = 0.5; // not too slow as there has to be a stationary moment for taps to be registered

static const float kMinMagnification = 0.4;
static const float kMaxMagnification = 2.5;

// control automatic reduction of score magnification with smaller screen
static const float kMagnificationReductionScreenWidthThreshold = 768;
static const float kMagnificationProportionToScreenWidth = 0.8F;// this is 0 for constant magnification at different screen widths, 1.0 for magnification proportional to screen width/768.

// MKMOD
//  Commemnted out, then Deleted static BOOL kOptimalSingleSystem
// MKMOD


@interface SSScrollView ()
{
    FSAnalysisOverlayView  *analysisOverlayView; // MKMOD - added - 11/20/17

	NSMutableArray *systemlist; // array of SSSystem

	NSArray<NSNumber*> *displayingParts;

	UIPinchGestureRecognizer *pinchRecognizer;
	float startPinchMagnification; // base magnification used for pinch-zoom

	NSMutableArray *recycleList;
    NSMutableSet *reusableViews;

	int cursorBarIndex;
	BOOL showingCursor;

    // MKMOD - added CursorType_e, cursor_xpos
    enum CursorType_e cursorType;
    float cursor_xpos;

    NSArray<NSValue*> *systemRects; // CGRect frame of each system

	dispatch_queue_t background_layout_queue;
	dispatch_queue_t background_draw_queue;

	bool layoutProcessing;

	NSMutableSet *pendingAddSystems; // set of indices of systems which are to be placed

	SSScore *score;

	int lastStartBarDisplayed; // used to detect change of visible range to update barcontrol display
	int lastNumBarsDisplayed;

	float magnificationScalingForWidth; // everything should be smaller if the width is small (ie smaller for iPhone vs iPad)

	SSLayoutOptions *layOptions;

	bool isPinchEnabled;

	NSMutableDictionary *colouringsForSystems;

    // MKMOD - deleted singlePartDIsplay
    // MKMOD - deleted startBarToDIsplay
    // MKMOD - deleted partToDIsplay
    
	handler_t layoutCompletionHandler;

	SSPlayLoopGraphics *playLoopGraphics;
    
    // MKMOD - deleted editMode
    // MKMOD - deleted ensureVisiblewRect

	sscore_changeHandler_id handlerId; // handler registered with SSScore is automatically notified of changes to the score when editing
    
    BOOL useSeeScoreCursor;
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
	pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch)];
    // MKMOD - moved assign to pendingAddSystems   to below
	[self addGestureRecognizer:pinchRecognizer];
	isPinchEnabled = true;
	colouringsForSystems = NSMutableDictionary.dictionary;
    pendingAddSystems = [NSMutableSet set];
	layOptions = [[SSLayoutOptions alloc] init]; // default layout options
    
    // MKMOD
    //   Removed ref to _xmlScoreWidth
    //   Removed ref to singlePartDisplay
    //   Added, then removed ref to _optimalSingleSystem
    // MKMOD
    
    [self resetBarRectCursor];  // MKMOD - added this

    useSeeScoreCursor = YES;
    
    [self addOverlayView];  // MKMOD - added - 11/20/17
    
	[self setCursorColour: [UIColor redColor]];
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
		[score removeChangeHandler:handlerId];
		handlerId = 0;
		score = nil;
	}
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

-(float)systemDrawScale
{
	SSSystemView *sysView = [self systemViewForIndex:0];
	return sysView ? sysView.drawScale : 1;
}

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
	[self clearDisplay];
	if (score)
		[score removeChangeHandler:handlerId];
	handlerId = 0;
	score = nil;
}

-(void)relayoutWithCompletion:(handler_t)completionHandler
{
    // MKMOD -  removed conditional    if (!editMode) {  around these two lines:
	lastStartBarDisplayed = -1;
	lastNumBarsDisplayed = -1;
	[self removeAllSystems];
	[self setupScore:score openParts:displayingParts mag:self.magnification opt:layOptions completion:completionHandler];
}

-(void)relayout
{
	[self relayoutWithCompletion:^{}];
}

// set flag to abort all background processing (layout and draw) and return immediately.
// Call completion handler on main thread when abort is complete
// It should be safe to call this again before completionhandler is called
-(void)abortBackgroundProcessing:(handler_t)completionHandler
{
	++self.abortingBackground;
	dispatch_async(background_layout_queue, ^{
		dispatch_sync(background_draw_queue, ^{
			// complete the abort only when the background queues are empty
			dispatch_async(dispatch_get_main_queue(), ^{
				[pendingAddSystems removeAllObjects];
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
		[self setupScore:score openParts:displayingParts mag:self.magnification opt:layOptions];
	}
}

- (void)pinch
{
	if (score && systemlist.count > 0)
	{
		int topSysIndex = [self firstSystemIndex];
		float pinchScale = pinchRecognizer.scale;
		[self hideCursor];
		bool beginPinch = pinchRecognizer.state == UIGestureRecognizerStateBegan;
		bool endPinch = pinchRecognizer.state == UIGestureRecognizerStateEnded;
		if (beginPinch)
		{
			startPinchMagnification = self.magnification;
			[self abortBackgroundProcessing:^{}];
		}
		else if (endPinch)
		{
			self.magnification = pinchScale * startPinchMagnification; // calls setMagnification
			// attempt to scroll to bar after 1s.
			// the layout processing on background threads may or may not be finished
			// NB A better way would be to layout starting at the current showing system/s,
			// then we wouldn't need to scroll
			dispatch_after(dispatch_time(0, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				if (!layoutProcessing)
					[self scrollToSystem:topSysIndex];
			});
		}
		else // fast continuous update while pinching
		{
			float mag = limit(pinchScale * startPinchMagnification, kMinMagnification, kMaxMagnification); // limit mag
			[self zoomMagnify:mag / startPinchMagnification];
		}
	}
}

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
	float maxSystemHeight = fmax(self.frame.size.height, 640.F); // don't allow any system higher than the screen else we run out of memory (but prevent 0 size)
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
	float ypos = kMargin.height;  // MKMOD - was     = 0
	CGSize frameSize = self.frame.size;
	assert(frameSize.width > 0);
	int index = 0;
	for (SSSystem *system in systemlist)
	{
		float systemHeight = [self systemHeight:index zoom:1]; // zoom is only needed for actual zooming
        // MKMOD - removed += call to ypos
		CGRect rect = CGRectMake(kMargin.width, ypos, frameSize.width, systemHeight);
		[mutSysRects addObject:[NSValue valueWithCGRect:rect]];
		ypos += systemHeight + system.defaultSpacing;   // MKMOD - altered this assign
		++index;
	}
	return mutSysRects;
}

// reduce magnification for display width < 768
-(float)magnificationScaling:(float)width
{
	return (width < kMagnificationReductionScreenWidthThreshold) ? 1.0 + kMagnificationProportionToScreenWidth*((width / kMagnificationReductionScreenWidthThreshold) - 1.0) : 1.0;
}

-(void)setupScore:(SSScore*)sc openParts:(NSArray<NSNumber*> *)parts mag:(float)mag opt:(SSLayoutOptions *)options
{
	[self setupScore:sc openParts:parts mag:mag opt:options completion:^{}];
}

-(void)setupScore:(SSScore*)sc
		openParts:(NSArray<NSNumber*>*)parts
			  mag:(float)mag
			  opt:(SSLayoutOptions *)options
	   completion:(handler_t)completionHandler
{
	if (score)
		[score removeChangeHandler:handlerId];  // MKMOD - modified this line
	handlerId = 0;
    [self disablePinch];  // MKMOD - added this
	assert(sc);
	assert(parts.count > 0);
	// abort any existing layout/draw...
	[self abortBackgroundProcessing:^{ // .. and on completion:
		assert(!layoutProcessing);
		[self clearAll];
		displayingParts = parts;
		layOptions = options; // MKMOD - added this
		score = sc;
		handlerId = [score addChangeHandler:self];

		_magnification = mag;
		__block CGRect frame = self.frame;
		assert(frame.size.width > 0);
		// we want a smaller scaling for smaller screens (iphone), but less than proportionate
		magnificationScalingForWidth = [self magnificationScaling:frame.size.width];
		if (self.abortingBackground == 0)
		{
            // MKMOD - took out    if (singlePartDisplay) {
				assert(!layoutProcessing);
				layoutProcessing = true;
				assert(systemlist.count == 0);
            
                // MKMOD -  added from here . . .
				dispatch_async(background_layout_queue, ^{
					assert(systemlist.count == 0);
					if (self.abortingBackground == 0)
					{
                        if (_optimalXMLxLayoutMagnification) {
                            __block float systemMagnification = 0;
                            __block bool widthIsTruncated = NO;//YES;
                            do {
                                // MKMOD - ... to here    (see "MKMOD added" above

                                UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
                                CGContextRef ctx = UIGraphicsGetCurrentContext();
                                // MKMOD - took out SSSystem* system = [score layoutSystemContext:  // 5-6 lines
                                
                                // MKMOD - Added this whole call to create sscore_error below
                                enum sscore_error err = [score layoutWithContext:ctx
                                                                           width:frame.size.width - (2 * kMargin.width) maxheight:frame.size.height
                                                                           parts:parts magnification:self.magnification * magnificationScalingForWidth
                                                                         options:options
                                                                        callback:^bool (SSSystem *sys){
                                                                            // callback is called for each new laid out system
                                                                            // return false if abort required
                                                                            if (self.abortingBackground == 0)
                                                                            {
                                                                                // MKMOD -  deleted assign to widthIsTruncated - 5/28/17
                                                                                systemMagnification = sys.magnification;
                                                                                // MKMOD -  changed this log - 5/28/17
//                                                                       NSLog(@"sys.magnification = %f, %i", sys.magnification, widthIsTruncated);
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
                            } while ((systemMagnification < self.magnification) || widthIsTruncated);

                            // MKMOD -  changed this log - 5/28/17
                            // MKMOD -  commented out this log - 11/6/17
//                            NSLog(@"+++systemMagnification:%f - width=%f", systemMagnification, frame.size.width);

                            
                            // MKMOD -  added the dispatch_async "wrapper" - 11/6/17
                            // MKMOD - on 11/20/17, made a similar, if not identical change here.
                            // temp fix, from Matt's checkin
                            // was:  self.frame = frame;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.frame = frame;
                            });
                        }
                        
                        // MKMOD  took out "else {"  (tied to removed if above) and 7 lines  4/1/17 DR commit

                        else
                        // MKMOD
                        // changed from    if (kOptimalSingleSystem) {
                        // MKMOD
                        if (_optimalSingleSystem) {
                            __block int numNewSystems = 0;
                            // MKMOD
                            //   removed    if (_xmlScoreWidth > 1 )
                            //                  frame.size.width = .....
                            // MKMOD
                            do {
                                numNewSystems = 0;
						UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
						CGContextRef ctx = UIGraphicsGetCurrentContext();
						enum sscore_error err = [score layoutWithContext:ctx
                                                           // MKMOD - change values for this line:
                                                           width:frame.size.width - (2 * kMargin.width) maxheight:frame.size.height
                                                            parts:parts magnification:self.magnification * magnificationScalingForWidth
                                                            options:options
                                                            callback:^bool (SSSystem *sys){
                                                            // callback is called for each new laid out system
                                                            // return false if abort required
                                                                if (self.abortingBackground == 0)
                                                                {
                                                                    numNewSystems++;
                                                                    return true;
                                                                }
                                                                else
                                                                    return false;}];
                                UIGraphicsEndImageContext();
                                if (err != sscore_NoError)
                                    break;
                                if (numNewSystems > 1) {
                                    NSLog(@"numNewSystems:%d - width=%f", numNewSystems, frame.size.width);
                                    frame.size.width += 100;
                                }
                                NSLog(@"SSScrollView.magnification = %f", self.magnification); // MKMOD added this
                            } while (numNewSystems > 1);

                            self.frame = frame;
                            // MKMOD
                            // changed NSLog call
                            NSLog(@"one system: xmlScoreWidth = width=%f", frame.size.width);
                            // MKMOD
                        }

                        UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
						CGContextRef ctx = UIGraphicsGetCurrentContext();
						enum sscore_error err = [score layoutWithContext:ctx
                                                                   // MKMOD - change values for this line:
																   width:frame.size.width - 2 * kMargin.width maxheight:frame.size.height
																   parts:parts magnification:self.magnification * magnificationScalingForWidth
																 options:options
																callback:^bool (SSSystem *sys){
																	// callback is called for each new laid out system
																	// return false if abort required

																	if (self.abortingBackground == 0)
																	{
																		dispatch_sync(dispatch_get_main_queue(), ^{
																			if (self.abortingBackground == 0)
																			{
																				[self addSystemToList:sys];
																				[self setNeedsLayout];
																				if (self.scrollDelegate)
																					[self.scrollDelegate update]; // update the barcontrol to show more bars loaded
																			}
																		});
																		return true;
																	}
																	else
																		return false;}];
						UIGraphicsEndImageContext();
                        NSLog(@"XML systemlist.count:%lu", (unsigned long)systemlist.count);
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
						assert(err == sscore_NoError);
					}
                    // MKMOD - added from here . . .   4/1/17 DR commit
                    NSLog(@"SSScrollView.magnification = %f", self.magnification);
                    SSSystem *topSystem = [self systemAtIndex:0];
                    NSLog(@"topSystem.magnification = %f, %i", topSystem.magnification, topSystem.isTruncatedWidth);

					layoutProcessing = false;
                    dispatch_sync(dispatch_get_main_queue(), ^{

                        if (options.useXMLxLayout)
                            [self disablePinch];
                        else
                            [self enablePinch];

                        if (completionHandler)
                            completionHandler();
                    });
                });
                // MKMOD - to here . . .   (see "added from here" above) 4/1/17 DR commit
		}
	}];
}

// MKMOD - redid displayParts significantly   4/1/17 DR commit
-(void)displayParts:(NSArray<NSNumber*>*)openParts
{
	[self setupScore:score openParts:openParts mag:self.magnification opt:layOptions completion:^{}];
}

// MKMOD - redid setLayoutOptions significantly    4/1/17 DR commit
-(void)setLayoutOptions:(SSLayoutOptions*)layoutOptions
{
	[self disablePinch];
	[self setupScore:score openParts:displayingParts mag:self.magnification opt:layoutOptions completion:^{
		if (!layoutOptions.useXMLxLayout)
			[self enablePinch];
	}];
}

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
    [self resetBarRectCursor];  // MKMOD - added   4/1/17 DR commit
	[colouringsForSystems removeAllObjects];
	systemRects = [NSArray array]; // clear
	[reusableViews removeAllObjects];
	[pendingAddSystems removeAllObjects];
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]]) // ignore editlayer
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView clear]; // clear held system
			[recycleList addObject:sysView];
		}
	}
	for (SSSystemView *view in recycleList)
	{
		[view removeFromSuperview];
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

        analysisOverlayView.layer.zPosition = 5;

        // MKMOD - removed commented lines lines - 12/12/17
        [analysisOverlayView redrawMe];
    }
}

-(void)removeSystemView:(SSSystemView*)sysView
{
	assert([self existsSysView:sysView.systemIndex]);
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
		[sysView setSystem:system score:score topLeft:sysFrame.origin margin:CGSizeZero];
		// restore any preserved colouring
		NSNumber *sysIndexKey = [NSNumber numberWithInt:sysIndex];
		SSColourRender *storedColourRenderForSystem = [colouringsForSystems objectForKey:sysIndexKey];
		if (storedColourRenderForSystem != nil)
		{
			sysView.colourRender = storedColourRenderForSystem;
			[colouringsForSystems removeObjectForKey:sysIndexKey];
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
	CGSize sz = CGSizeZero; // MKMOD - changed this line
	for (SSSystem *sys in systemlist)
	{
		sz.height += sys.bounds.height + sys.defaultSpacing;
		if (sys.bounds.width > sz.width)
			sz.width = sys.bounds.width;
	}
	return sz;
}

- (void)layoutSubviews
{
     // MKMOD - added stuff that was deleted later - 11/20/17
	[super layoutSubviews];
	if (self.abortingBackground == 0 && score && systemlist.count > 0) // this is called on every scroll movement
	{
        [self resetBarRectCursor];     // MKMOD - added
		// adjust height of content to include all systems
		self.contentSize = [self systemsSize];
		CGRect containedFrame = containedView.frame;
		containedFrame.origin = CGPointMake(0,0);
		containedFrame.size = self.contentSize;
		containedView.frame = containedFrame;

        // MKMOD - removed editMode from calc
		if (systemlist.count != systemRects.count) // don't normally need to recalc the system rects unless in edit mode
			systemRects = [self getSystemRects];

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
			[self.scrollDelegate update];
		}
		if (self.updateDelegate)
		{
			[self.updateDelegate newLayout];
		}
        if (showingCursor)    // MKMOD - added this fragment
        {
            [self displayCursor];
        }
	}
}

-(bool)changedVisible
{
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
		return [systemlist objectAtIndex:sysIndex];
	else
		return NULL;
}

-(int)systemIndexAtPos:(CGPoint)pos
{
	int index = 0;
	for (NSValue *value in systemRects)
	{
		CGRect sysFrame = [value CGRectValue];
		if (pos.y < sysFrame.origin.y + sysFrame.size.height) // above bottom of sysFrame
		{
			return index;
		}
		++index;
	}
	return (index > 0) ? index - 1: 0;
}

-(CGPoint)topLeftAtSystemIndex:(int)sysIndex
{
    // MKMOD - removed creating a CGRect from system Rects
	if (sysIndex >= 0 && sysIndex < [systemRects count])
	{
		SSSystemView *sysView = [self systemViewForIndex:sysIndex];
		if (sysView)
			return sysView.topLeft; // MKMOD - was making a point from above rect
		else // we may not have a SystemView placed here
		{
            // MKMOD - tis was the call deleted above
			CGRect rect = [[systemRects objectAtIndex:sysIndex] CGRectValue];
			return CGPointMake(rect.origin.x, rect.origin.y);
		}
	}
	return CGPointMake(0,0);
}

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

-(SSSystemView*)systemViewForPos:(CGPoint)pos
{
	int systemIndex = [self systemIndexAtPos:pos];
	return [self systemViewForIndex:systemIndex];
}

-(SSSystemPoint)systemAtPos:(CGPoint)pos
{
	SSSystemView* sysView = [self systemViewForPos:pos];
	SSSystemPoint rval;
	if (sysView)
	{
		CGPoint frameOrigin = sysView.frame.origin;
		rval.systemIndex = sysView.systemIndex;
		SSSystem *system = sysView.system;
		if (system)
		{
			rval.barIndex = [system barIndexForXPos:pos.x - frameOrigin.x];
			rval.partIndex = [system partIndexForYPos:pos.y - frameOrigin.y];
			rval.staffIndex = [system staffIndexForYPos:pos.y - frameOrigin.y];
			rval.staffLocation = [system staffLocationForYPos:pos.y - frameOrigin.y];
		}
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
}

-(int)numSystems
{
	return (int)systemRects.count;
}

-(CGRect)systemRect:(int)systemIndex
{
	if (systemIndex >= 0 && systemIndex < systemRects.count)
	{
		CGRect rect = [[systemRects objectAtIndex:systemIndex] CGRectValue];
		rect.origin = [self topLeftAtSystemIndex:systemIndex]; // offset to allow for margin
		return rect;
	}
	else
		return CGRectMake(0,0,0,0);
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

-(bool)isDisplayingStart   // MKMOD - changed BOOL to bool
{
	return self.contentOffset.y <= 10;
}

-(bool)isDisplayingEnd    // MKMOD - changed BOOL to bool
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

-(bool)isDisplayingWhole   // MKMOD - changed BOOL to bool
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

-(void)scrollToBarContinuous:(int)barIndex
{
	assert(barIndex >= 0 && barIndex < score.numBars);
	if (score && systemlist.count > 0
		&& ![self isDisplayingWhole]) // the scroll view doesn't scroll if the score is not bigger than the
	{							// displayed height, even if it is scrolled of the top - so we prevent this
		SSSystem* sys = [self systemContainingBarIndex:barIndex];
		if (sys != nil) //  when rotating device while playing - tries to scroll to bar which is not yet laid out)
		{
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
    if (!useSeeScoreCursor)
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
			   xpos:xpos
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

-(void)colourPDNotes:(NSArray*)pdnotes colour:(UIColor*)colour
{
	static const unsigned coloured_render = sscore_dopt_colour_notehead | sscore_dopt_colour_ledger;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			NSMutableArray *colouredItems = NSMutableArray.array;
			for (SSPDNote *note in pdnotes)
			{
				if ([sysView.system includesBar:note.startBarIndex])
				{
					SSColouredItem *item = [[SSColouredItem alloc] initWithItem:note.item_h colour:colour.CGColor render:coloured_render];
					[colouredItems addObject:item];
				}
			}
			// add existing coloured items
			[colouredItems addObjectsFromArray:sysView.colourRender.colouredItems];
			SSColourRender *render = [[SSColourRender alloc] initWithItems:colouredItems];
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

-(void)didRotate
{
	[self clearPlayLoopGraphics];
	if (score)
		[self relayout];
}

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

-(void)enablePinch
{
	if (!isPinchEnabled)
	{
		[self addGestureRecognizer:pinchRecognizer];
		isPinchEnabled = true;
	}
}
-(void)disablePinch
{
	if (isPinchEnabled)
	{
		[self removeGestureRecognizer:pinchRecognizer];
		isPinchEnabled = false;
	}
}

-(void)selectItem:(sscore_item_handle)item_h part:(int)partIndex bar:(int)barIndex
	   foreground:(CGColorRef)fg background:(CGColorRef)bg
{
	for (UIView *v in [containedView subviews]) // cannot assume ordering of subviews
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			if ([sysView.system includesBar:barIndex])
			{
				[sysView selectItem:item_h part:partIndex bar:barIndex foreground:fg background:bg];
			}
		}
	}
}

-(void)deselectItem:(sscore_item_handle)item_h
{
	for (UIView *v in [containedView subviews]) // cannot assume ordering of subviews
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView deselectItem:item_h];
		}
	}
}

-(void)deselectAll
{
	for (UIView *v in [containedView subviews]) // cannot assume ordering of subviews
	{
		if ([v isKindOfClass:[SSSystemView class]])
		{
			SSSystemView *sysView = (SSSystemView*)v;
			[sysView deselectAll];
		}
	}
}

-(void)displayPlayLoopGraphicsLeft:(int)leftLoopBarIndex right:(int)rightLoopBarIndex
{
	[self clearPlayLoopGraphics];
	SSSystem *leftSystem = [self systemContainingBarIndex:leftLoopBarIndex];
	SSSystem *rightSystem = [self systemContainingBarIndex:rightLoopBarIndex];
	CGPoint leftSystemTopLeft = [self topLeftAtSystemIndex:leftSystem.index];   // MKMOD  changed
	CGPoint rightSystemTopLeft = [self topLeftAtSystemIndex:rightSystem.index]; // MKMOD  changed
	playLoopGraphics = [[SSPlayLoopGraphics alloc] initWithNumParts:score.numParts
														 leftSystem:leftSystem leftSystemTopLeft:(CGPoint)leftSystemTopLeft leftBarIndex:leftLoopBarIndex
														rightSystem:rightSystem rightSystemTopLeft:(CGPoint)rightSystemTopLeft rightBarIndex:rightLoopBarIndex
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
	return NSArray.array;
}

// MKMOD  deleted method tap
// MKMOD  deleted method pan

#ifdef DrawOutline
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];  // MKMOD - uncommeneted this - 11/20/17
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


//@protocol BarControlProtocol <NSObject>
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
    // MKMOD  deleted a line here
	NSMutableArray<SSSystemView *> *changedViews = NSMutableArray.array;
	for (UIView *v in [containedView subviews])
	{
		if ([v isKindOfClass:[SSSystemView class]]) // ignore SSEditLayer
		{
			SSSystemView *sysView = (SSSystemView*)v;
			sscore_barrange br = sysView.system.barRange;
			for (int i = 0 ; i < br.numbars; ++i)
			{
				int barIndex = br.startbarindex + i;
				if (sscore_edit_barChanged(barIndex, prevstate, newstate))
				{
					[changedViews addObject:sysView];
					break;
				}
			}
		}
	}
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
