//
//  SSScrollView
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//
// This is the main scrollable view which displays a MusicXML file

#import <UIKit/UIKit.h>

#import "SSBarControlProtocol.h"
#import "SSUpdateScrollProtocol.h"
#import <SeeScoreLib/SeeScoreLib.h>
// MKMODFIX - removed #import "SSViewInterface.h" 3/23/19
// #import "SSViewInterface.h"                        // MKMODFIX - this should probably come out
// MKMOD - removed import SSEditLayerProtocol.h
#import "FSAnalysisOverlayView.h"   // MKMOD
#import "ScoreViewInterface.h"

@class SSComponent;
// MKMOD - removed class SSEditLayer

/*!
 * @typedef handler_t
 * @abstract a generic handler function
 */
typedef void (^handler_t)(void);

/*!
 * @protocol SSUpdateProtocol
 * @abstract for notification of clear systems and add system
 */
@protocol SSUpdateProtocol

/*!
 * @method cleared
 * @abstract called (on main queue) on clear of systems (eg on pinch)
 */
-(void)cleared;

/*!
 * @method newLayout
 * @abstract called (on main queue) when a new layout of the SSScrollView is complete.
 * @discussion This can be called whenever a new system is shown, such as when scrolling
 */
-(void)newLayout;

@end

// MKMOD - SF commented out THIS version of CursorType_e

//// NS_ENUMS go here!
/*!
 * @enum CursorType_e
 * @abstract define the type of cursor, vertical line or rectangle around the bar
 */
//enum CursorType_e {cursor_line, cursor_rect};
// typedef NS_ENUM(NSInteger, CursorType_e) {cursor_line, cursor_rect};


// MKMOD - SF commented out THIS version of ScrollType_e

/*!
 * @enum ScrollType_e
 * @abstract define the scroll required when setting the cursor
 * @discussion scroll_off is no scroll, scroll_system to scroll to centre the system containing the bar,
 * scroll_bar (smoother than scroll-system) is set to minimise the scroll distance between adjacent bars in
 * different systems
 */
//enum ScrollType_e {scroll_off, scroll_system, scroll_bar};
// typedef NS_ENUM(NSInteger, ScrollType_e) {scroll_off, scroll_system, scroll_bar};


/*!
 * @interface SSScrollView
 * @abstract A scrollable view to display a MusicXML score as a vertical sequence of rectangular system views
 */
// MKMOD - removed SSViewInterface from list
// MKMOD - added OverlayViewDelegate to list
// MKMOD - removed OverlayViewDelegate from list  - 12/12/17
@interface SSScrollView : UIScrollView <SSBarControlProtocol, ScoreChangeHandler, ScoreViewInterface, UIScrollViewDelegate> {

	IBOutlet UIView *containedView;
}

/*!
 * @property score
 * @abstract the score
 */
@property (nonatomic,readonly) SSScore * _Nullable score;

/*!
 * @property drawScale
 * @abstract the current scale of drawn items in contained SSSystemViews (notes etc)
 */
@property (nonatomic,readonly) float drawScale;

/*!
 * @property magnification
 * @abstract the current magnification. Pinch zoom changes this
 */
@property (nonatomic) float magnification;

/*!
 * @property startBarIndex
 * @abstract index of the bar wholly visible at the top left of the window
 */
@property (nonatomic,readonly) int startBarIndex;

/*!
 * @property scrollDelegate
 * @abstract for SSBarControl update
 */
@property (nonatomic,assign) id<SSUpdateScrollProtocol> _Nonnull scrollDelegate;

// MKMOD - added overlayViewDelegate  - 11/20/17
/*!
 * @property overlayViewDelegate
 * @abstract for FSAnalysisOverlayView update
 */
@property (nonatomic,assign) id<OverlayViewDelegate> overlayViewDelegate;

/*!
 * @property isProcessing
 * @abstract true while processing layout
 */
@property (readonly) bool isProcessing;

/*!
 * @property updateDelegate
 * @abstract for notification of change to number of systems displayed
 */
@property (nonatomic,assign) id<SSUpdateProtocol> _Nonnull updateDelegate;

/*!
 * @property displayingSinglePart
 * @abstract true if displaying a single part only
 */
@property (readonly) bool displayingSinglePart;

/*!
 * @property displayingCursor
 * @abstract true if displaying the cursor
 */
@property (readonly) bool displayingCursor;

/*!
 * @property cursorBarIndex
 * @abstract the index of the bar where the cursor is currently if it is displayed
 */
@property (readonly) int cursorBarIndex;

// MKMOD - removed import SSEditLayerProtocol.h
// removed property editLayer

/*!
 * @property bottom
 * @abstract return y-coord of bottom of bottom system
 */
@property (readonly) float bottom;

// MKMOD - added isDisplayingStart
/*!
 * @property isDisplayingStart
 * @abstract true if the first system is (fully) displayed on the screen
 */
//@property (readonly)  bool isDisplayingStart; // MKMODFIX - redundant - delete?

// MKMOD - added isDisplayingEnd
/*!
 * @property isDisplayingEnd
 * @abstract true if the last system is (fully) displayed on the screen
 */
@property (readonly)  bool isDisplayingEnd;


/*!
 * @property isDisplayingStart
 * @abstract true if the entire score is currently visible on the screen (not scrollable in this case)
 */
@property (readonly)  bool isDisplayingStart;


// MKMOD - added isDisplayingWhole  
// MKMODFIX - perhaps this should come out.  Try commenting out.
/*!
 * @property isDisplayingStart
 * @abstract true if the entire score is currently visible on the screen (not scrollable in this case)
 */
@property (readonly)  bool isDisplayingWhole;

/*!
 * @property layoutOptions:
 * @abstract read or set layout options. set triggers a relayout
 */
@property SSLayoutOptions * _Nonnull layoutOptions;

-(instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
 * @method initWithFrame:
 * @abstract initialise this SSScrollView
 * @param aRect the frame of this UIView
 */
- (instancetype _Nonnull)initWithFrame:(CGRect)aRect;

/*!
 * @method setupScore:openParts:mag:opt:
 * @abstract setup the score
 * @param score the score
 * @param parts array indexed by part. Element is boolean NSNumber. True to display part, false to hide it
 * @param mag the magnification (1.0 is nominal standard size, ie approximately 7mm staff height). Pinch zoom changes this
 * @param options the layout options
 */
-(void)setupScore:(SSScore* _Nonnull)score
		openParts:(NSArray<NSNumber*>* _Nonnull)parts
			  mag:(float)mag
			  opt:(SSLayoutOptions * _Nonnull)options;

/*!
 * @method setupScore:openParts:mag:opt:completion:
 * @abstract setup the score with completion handler
 * @param score the score
 * @param parts array indexed by part. Element is boolean NSNumber. True to display part, false to hide it
 * @param mag the magnification (1.0 is nominal standard size, ie approximately 7mm staff height). Pinch zoom changes this
 * @param options the layout options
 * @param completionHandler called on completion of layout
 */
-(void)setupScore:(SSScore* _Nonnull)score
		openParts:(NSArray<NSNumber*>* _Nonnull)parts
			  mag:(float)mag
			  opt:(SSLayoutOptions * _Nonnull)options
	   completion:(handler_t _Nonnull)completionHandler;

// MKMOD removed function def for setSinglePartDisplay

// MKMOD removed function def for clearSinglePartDisplay

/*!
 * @method displayParts
 * @abstract set which parts to display
 * @param parts array indexed by part. Array element is boolean NSNumber. True to display part, false to hide it
 */
-(void)displayParts:(NSArray<NSNumber*>* _Nonnull)parts;


// MKMODFIX - this is not in the latest header file. Commenting out.
/*!
 * @method setLayoutOptions:
 * @abstract set new layout options, triggers a relayout
 */
//-(void)setLayoutOptions:(SSLayoutOptions*)layOptions;

/*!
 * @method abortBackgroundProcessing:
 * @abstract abort all multi-threaded (layout and draw) action. Safe to call when no activity
 * @discussion completionHandler is called on main queue when all activity is complete and queues are empty
 */
-(void)abortBackgroundProcessing:(handler_t _Nonnull)completionHandler;

// MKMOD removed id<SSEditLayerProtocol> (^ss_create_editlayer_t) ....

// MKMOD removed method setEditMode ....

/*!
 * @method clearDisplay
 * @abstract clear displayed systems but retain score
 */
-(void)clearDisplay;

// MKMOD removed method clearEditMode ....

/*!
 * @method clearAll
 * @abstract clear everything - need to call setupScore after calling this
 */
-(void)clearAll;

// MKMOD removed -(BOOL)isDisplayingStart; ....

// MKMOD removed -(BOOL)isDisplayingEnd; ....

// MKMOD removed -(BOOL)isDisplayingWhole; ....

/*!
 @method relayoutWithCompletion
 @abstract clear and relayout systems
 */
-(void)relayout;

/*!
 @method relayoutWithCompletion
 @abstract clear and relayout systems
 @param completionHandler called on completion of layout
 */
-(void)relayoutWithCompletion:(handler_t _Nonnull)completionHandler;

/*!
 @method barIndexForPos:
 @return the bar index at the given point in the score
 */
-(int)barIndexForPos:(CGPoint)pos;

/*!
 @method partIndexForPos:
 @return the part index at the given point in the score
 */
-(int)partIndexForPos:(CGPoint)pos;

/*!
 * @method systemAtPos
 * @abstract return the system index and location within it for a point in the SSScrollView
 * @discussion use systemAtIndex: to get the SSSystem from the systemIndex
 * @param p the point within the SSScrollView
 * @return the SystemPoint defining the system index, and part and bar indices at p
 * return .isValid = false if not valid
 */
-(SSSystemPoint)systemAtPos:(CGPoint)p;

/*
 * @method systemAtIndex
 * @return return the system at the given index (0-based, top to bottom)
 */
-(SSSystem* _Nullable)systemAtIndex:(int)index;

/*!
 * @method systemContainingBarIndex
 * @return the system containing the given 0-based bar index
 */
-(SSSystem* _Nullable)systemContainingBarIndex:(int)barIndex;

/*!
 * @method numSystems
 * @abstract return the number of systems currently displayed
 */
-(int)numSystems;

/*!
 * @method systemRect
 * @abstract the bounds of a given system
 * @return CGRect outline of system by index [0..numSystems-1]
 */
-(CGRect)systemRect:(int)systemIndex;

/*!
 * @method posInViewForSystem:atPoint:
 * @abstract get the view position for a system point
 * @param systemIndex the index of the system
 * @param pos the point in the system
 * @return the position in the view for the given system point allowing for system magnification
 */
-(CGPoint)posInViewForSystem:(int)systemIndex atPoint:(CGPoint)pos;

/*!
 * @method rectInViewForSystem:rect:
 * @abstract get the view rectangle for a system rectangle
 * @param systemIndex the index of the system
 * @param rect the rectangle in the system
 * @return the CGRect in the view for the given system rect allowing for system magnification
 */
-(CGRect)rectInViewForSystem:(int)systemIndex rect:(CGRect)rect;

/*!
 * @enum CursorType_e
 * @abstract define the type of cursor, vertical line or rectangle around the bar
 */
enum CursorType_e {cursor_line, cursor_rect};
//

//  MKMOD - some changes to commented lines here
/*!
 * @enum ScrollType_e
 * @abstract define the scroll required when setting the cursor
 * @discussion scroll_off is no scroll, scroll_system to scroll to centre the system containing the bar,
 * scroll_bar (smoother than scroll-system) is set to minimise the scroll distance between adjacent bars in
 * different systems
 */
enum ScrollType_e {scroll_off, scroll_system, scroll_bar};

/*!
 * @method setCursorAtBar
 * @abstract set the cursor at the given bar
 * @param barIndex the 0-based bar index in which to set the cursor
 * @param type the type of cursor (box or vertical line)
 * @param scroll the type of scroll to reveal the given bar or no scroll
 */
-(void)setCursorAtBar:(int)barIndex
				 type:(enum CursorType_e)type
			   scroll:(enum ScrollType_e)scroll;

/*!
 * @method setCursorAtXpos
 * @abstract set the vertical line cursor to an x position within the system containing the given bar index
 * @param xpos the x position within the system to set the cursor
 * @param barIndex the bar in which the cursor is displayed
 * @param scroll the type of scroll to reveal the given bar or no scroll
 */
-(void)setCursorAtXpos:(float)xpos
			  barIndex:(int)barIndex
			   scroll:(enum ScrollType_e)scroll;

/*!
 * @method hideCursor
 * @abstract hide the cursor
 */
-(void)hideCursor;

/*!
 * @method barRectangle
 * @abstract get the rectangle around a bar suitable for a bar cursor
 */
-(SSCursorRect)barRectangle:(int)barIndex;

/*!
 * @method setCursorColour:
 * @abstract set the cursor outline colour
 * @param colour the new colour
 */
-(void)setCursorColour:(UIColor* _Nonnull)colour;

/*!
 * @method scroll
 * @abstract scroll the display by a percentage of the screen height from the current position
 * @param percent a percentage of the screen height,  +100 to scroll down 1 page, -100 to scroll up 1 page
 */
-(void)scroll:(int)percent;


// MKMODFIX - this is no longer in header.  Commented out?
/*!
 * @method didRotate
 * @abstract called to notify a screen orientation change
 */
// -(void)didRotate;

// MKMODFIX - this is no longer in header.  Commented out?
/*!
 * @method enablePinch
 * @abstract enable pinch-zoom
 */
// -(void)enablePinch;

// MKMODFIX - this is no longer in header.  Commented out?
/*!
 * @method disablePinch
 * @abstract disable pinch-zoom
 */
// -(void)disablePinch;

//
/*!
 * @method colourPDNotes
 * @abstract colour the given set of notes in the given system
 * @param notes array elements are of type SSPDNote*
 * @param colour the colour to use for the components
 */
-(void)colourPDNotes:(NSArray<SSPDNote*>* _Nonnull)notes colour:(UIColor* _Nonnull)colour;

/*!
 * @method colourComponents
 * @abstract colour the components with the given colour
 * @param components array elements are of type SSComponent*
 * @param colour the colour to use for the components
 * @param elementTypes use sscore_dopt_colour_render_flags_e to define exactly what part of an item should be coloured
 */
-(void)colourComponents:(NSArray<SSComponent*>* _Nonnull)components colour:(UIColor * _Nonnull)colour elementTypes:(unsigned)elementTypes;

/*!
 * @method clearColouringForBarRange
 * @abstract clear all draw option colouring setup by setDrawOptions in specified bar range
 * @discussion requires contents-detail licence
 */
-(void)clearColouringForBarRange:(const sscore_barrange* _Nonnull)barrange;

/*!
 * @method clearAllColouring
 * @abstract clear all draw option colouring setup by setDrawOptions
 */
-(void)clearAllColouring;

// MKMODFIX -  This is no longer in header.  Should delete?
/*!
 * @method selectItem
 * @abstract select an item by colouring it
 */
//-(void)selectItem:(sscore_item_handle)item_h part:(int)partIndex bar:(int)barIndex
//	   foreground:(CGColorRef)fg background:(CGColorRef)bg;

// MKMODFIX -  This is no longer in header.  Should delete?
/*!
 * @method deselectItem
 * @abstract deselect an item previously selected
 */
//-(void)deselectItem:(sscore_item_handle)item_h;

// MKMODFIX -  This is no longer in header.  Should delete?
/*!
 * @method deselectAll
 * @abstract deselect all selected items
 */
//-(void)deselectAll;

/*!
 * @method displayPlayLoopGraphicsLeft:right:
 * @abstract display blue dotted double barlines at left and right bar indexes to indicate play loop range
 */
-(void)displayPlayLoopGraphicsLeft:(int)leftLoopBarIndex right:(int)rightLoopBarIndex;

/*!
 * @method clearPlayLoopGraphics
 * @abstract clear play loop graphics setup by displayPlayLoopGraphicsLeft:right:
 */
-(void)clearPlayLoopGraphics;

// MKMOD - BeyondCOmpare got completely out of sync here.  Hopefully I did the hand merge correctly.


/*!
 * @method showVoiceTracks
 * @abstract show or hide coloured tracks between notes and rests on each voice in each part
 */
-(void)showVoiceTracks:(bool)show;

/*!
 * @method componentsAt:
 * @return an array of components within maxDistance of point p
 */
-(NSArray<SSComponent*> * _Nonnull)componentsAt:(CGPoint)p maxDistance:(float)maxDistance;
// MKMOD
//  deleted -(void)tap: ...
// MKMOD

// MKMOD
//  deleted -(void)pan: ...
// MKMOD

// MKMOD
//  Deleted xmlScoreWidth   by David S Reich on 14/05/2016.
// MKMOD

// MKMOD
//  Added by David S Reich on 14/05/2016.
//  Modification Copyright © 2016 Musikyoshi. All rights reserved.
// MKMODFIX - BC error /*!
// MKMODFIX - BC error  * @method componentsAt:
// MKMODFIX - BC error  * @return an array of components within maxDistance of point p
/*!
 * @property optimalSingleSystem
 * @abstract optimalSingleSystem - true for making one very wide single system
 * Set this before calling setupScore
 * Should NOT be set at the same time as optimalXMLxLayoutMagnification
 */
@property (nonatomic) bool optimalSingleSystem;
// MKMOD

// MKMOD
//  Added by David S Reich on 04/03/2017.
//  Modification Copyright © 2017 Musikyoshi. All rights reserved.
/*!
 * @property optimalXMLxLayoutMagnification
 * @abstract optimalXMLxLayoutMagnification - true for setting the magnification when useXMLxLayout is true
 * Set this before calling setupScore
 * Should NOT be set at the same time as optimalSingleSystem
 */
@property (nonatomic) bool optimalXMLxLayoutMagnification;
// MKMOD

//@protocol SSViewInterface

-(float)drawScale;

-(float)zoomMagnification;

-(CGRect)frame;

-(void)setFrame:(CGRect)frame;

-(bool)pointInside:(CGPoint)point withEvent:(UIEvent * _Nullable)event;

-(void)drawItemOutline:(SSEditItem* _Nonnull)editItem systemIndex:(int)systemIndex ctx:(CGContextRef _Nonnull)ctx
				colour:(CGColorRef _Nonnull)colour margin:(CGFloat)margin linewidth:(CGFloat)lineWidth;

-(void)drawItemDrag:(SSEditItem* _Nonnull)editItem systemIndex:(int)systemIndex ctx:(CGContextRef _Nonnull)ctx
			dragPos:(CGPoint)dragPos showTargetDashedLine:(bool)showTargetDashedLine;

-(void)selectVoice:(NSString* _Nonnull)voice systemIndex:(int)systemIndex partIndex:(int)partIndex;

-(SSTargetLocation* _Nullable)nearestInsertTargetFor:(SSEditType* _Nonnull)editType at:(CGPoint)pos maxDistance:(CGFloat)maxDistance;

-(CGPoint)nearestNoteInsertPos:(CGPoint)pos editType:(SSEditType* _Nonnull)editType maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers;

-(CGPoint)nearestNoteReinsertPos:(CGPoint)pos editItem:(SSEditItem* _Nonnull)editItem maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers;

// the change handler causes the systems to be relaid out when the score changes
// There is some attempt to optimise this to reduce the amount of relayout for small changes
-(void)activateChangeHandler;
-(void)deactivateChangeHandler;
-(void)displayFakeRepeatBarlineLeft:(int)barIndex;
-(void)displayFakeRepeatBarlineRight:(int)barIndex;


// For displaying student performance results

// MKMOD - changed third and fourth params - 11/20/17
// MKMOD - added addNotePerformanceResultAtXPos - 12/12/17
// MKMOD - changed to addScoreObjectPerformanceResultAtXPos - 7/26/18
-(void) addScoreObjectPerformanceResultAtXPos:(CGFloat) iXPos
                                       atYpos:(CGFloat) iYPos // MKMOD - added param - 2/14/18
                           withWeightedRating:(int)  iWeightedRating
                                       isNote:(bool)isNote          // MKMOD - changed param - 7/26/18
                             withNoteOrRestID:(int) iNoteOrRestID   // MKMOD - changed param - 7/26/18
                                scoreObjectID:(int) iScoreObjectID  // MKMOD - changed param - 7/26/18
                                     isLinked:(bool) isLinked
                                linkedSoundID:(int)  iLinkedSoundID;
// MKMOD - added updateNotePerformanceResultAtXPos - 11/20/17
// MKMOD - removded updateNotePerformanceResultAtXPos - 7/26/18

// MKMOD - added addSoundPerformanceResultAtXPos - 12/12/17
-(void) addSoundPerformanceResultAtXPos:(CGFloat) iXPos
                           withDuration:(int) iDuration
                                soundID:(int) iSoundID
                               isLinked:(bool) isLinked
                           linkedNoteID:(int) iLinkedNoteID;

-(CGFloat) getCurrentXOffset;  // MKMOD - added - 12/12/17


// MKMOD added highlightNote - 2/14/18
// MKMOD changed to highlightScoreObject - 7/26/18
// scroll to and highlight note or rest with this ScoreObject ID
-(bool) highlightScoreObject:(int) iScoreObjectID
                    severity:(int) iSeverity;


-(void) turnHighlightOff;   // MKMOD added - 2/14/18

// MKMOD - added clearNotePerformanceResultAtXPos - 11/20/17
-(void) clearNotePerformanceResultAtXPos:(CGFloat) iXPos;

// MKMOD - added clearNotePerformanceResults - 11/20/17
-(void) clearNotePerformanceResults;

-(void) clearCurrNoteLines;
-(void) drawCurrNoteLineAt:(CGFloat) iXPos;
-(void) useSeeScoreCursor:(BOOL) iUseSSCursor;

-(void) showAnalysisOverview:(BOOL) iShow;

-(void) clearScoreIsSetup;

// Keeps the SeeScore view from thrashing through unneeded
// (and error-producing) calls to LayoutSubviews, etc.
-(void) freezeLayout;

-(void) setSpecifiedFrameWidth:(int)iSpecifiedFrameWidth;

@end
