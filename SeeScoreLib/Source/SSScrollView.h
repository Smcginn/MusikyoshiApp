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
#import "SSViewInterface.h"
#import "FSAnalysisOverlayView.h"

@class SSComponent;

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

//// NS_ENUMS go here!
/*!
 * @enum CursorType_e
 * @abstract define the type of cursor, vertical line or rectangle around the bar
 */
//enum CursorType_e {cursor_line, cursor_rect};
typedef NS_ENUM(NSInteger, CursorType_e) {cursor_line, cursor_rect};

/*!
 * @enum ScrollType_e
 * @abstract define the scroll required when setting the cursor
 * @discussion scroll_off is no scroll, scroll_system to scroll to centre the system containing the bar,
 * scroll_bar (smoother than scroll-system) is set to minimise the scroll distance between adjacent bars in
 * different systems
 */
//enum ScrollType_e {scroll_off, scroll_system, scroll_bar};
typedef NS_ENUM(NSInteger, ScrollType_e) {scroll_off, scroll_system, scroll_bar};


/*!
 * @interface SSScrollView
 * @abstract A scrollable view to display a MusicXML score as a vertical sequence of rectangular system views
 */
@interface SSScrollView : UIScrollView <SSBarControlProtocol, ScoreChangeHandler> {

	IBOutlet UIView *containedView;
}

/*!
 * @property score
 * @abstract the score
 */
@property (nonatomic,readonly) SSScore *score;

/*!
 * @property itemDrawScale
 * @abstract the current scale of drawn items in contained SSSystemViews (notes etc)
 */
@property (nonatomic,readonly) float systemDrawScale;

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
@property (nonatomic,assign) id<SSUpdateScrollProtocol> scrollDelegate;

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
@property (nonatomic,assign) id<SSUpdateProtocol> updateDelegate;

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

/*!
 * @property bottom
 * @abstract return y-coord of bottom of bottom system
 */
@property (readonly) float bottom;

/*!
 * @property isDisplayingStart
 * @abstract true if the first system is (fully) displayed on the screen
 */
@property (readonly)  bool isDisplayingStart;

/*!
 * @property isDisplayingEnd
 * @abstract true if the last system is (fully) displayed on the screen
 */
@property (readonly)  bool isDisplayingEnd;

/*!
 * @property isDisplayingStart
 * @abstract true if the entire score is currently visible on the screen (not scrollable in this case)
 */
@property (readonly)  bool isDisplayingWhole;


/*!
 * @method initWithFrame:
 * @abstract initialise this SSScrollView
 * @param aRect the frame of this UIView
 */
- (instancetype)initWithFrame:(CGRect)aRect;

/*!
 * @method setupScore:openParts:mag:opt:
 * @abstract setup the score
 * @param score the score
 * @param parts array indexed by part. Element is boolean NSNumber. True to display part, false to hide it
 * @param mag the magnification (1.0 is nominal standard size, ie approximately 7mm staff height). Pinch zoom changes this
 * @param options the layout options
 */
-(void)setupScore:(SSScore*)score
		openParts:(NSArray<NSNumber*>*)parts
			  mag:(float)mag
			  opt:(SSLayoutOptions *)options;

/*!
 * @method setupScore:openParts:mag:opt:completion:
 * @abstract setup the score with completion handler
 * @param score the score
 * @param parts array indexed by part. Element is boolean NSNumber. True to display part, false to hide it
 * @param mag the magnification (1.0 is nominal standard size, ie approximately 7mm staff height). Pinch zoom changes this
 * @param options the layout options
 * @param completionHandler called on completion of layout
 */
-(void)setupScore:(SSScore*)score
		openParts:(NSArray<NSNumber*>*)parts
			  mag:(float)mag
			  opt:(SSLayoutOptions *)options
	   completion:(handler_t)completionHandler;

/*!
 * @method displayParts
 * @abstract set which parts to display
 * @param parts array indexed by part. Array element is boolean NSNumber. True to display part, false to hide it
 */
-(void)displayParts:(NSArray<NSNumber*>*)parts;

/*!
 * @method setLayoutOptions:
 * @abstract set new layout options, triggers a relayout
 */
-(void)setLayoutOptions:(SSLayoutOptions*)layOptions;

/*!
 * @method abortBackgroundProcessing:
 * @abstract abort all multi-threaded (layout and draw) action. Safe to call when no activity
 * @discussion completionHandler is called on main queue when all activity is complete and queues are empty
 */
-(void)abortBackgroundProcessing:(handler_t)completionHandler;

/*!
 * @method clearDisplay
 * @abstract clear displayed systems but retain score
 */
-(void)clearDisplay;

/*!
 * @method clearAll
 * @abstract clear everything - need to call setupScore after calling this
 */
-(void)clearAll;

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
-(void)relayoutWithCompletion:(handler_t)completionHandler;

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
 */
-(SSSystemPoint)systemAtPos:(CGPoint)p;

/*!
 * @method systemAtIndex
 * @return return the system at the given index (0-based, top to bottom)
 */
-(SSSystem*)systemAtIndex:(int)index;

/*!
 * @method systemContainingBarIndex
 * @return the system containing the given 0-based bar index
 */
-(SSSystem*)systemContainingBarIndex:(int)barIndex;

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

///*!
// * @enum CursorType_e
// * @abstract define the type of cursor, vertical line or rectangle around the bar
// */
//enum CursorType_e {cursor_line, cursor_rect};
//
///*!
// * @enum ScrollType_e
// * @abstract define the scroll required when setting the cursor
// * @discussion scroll_off is no scroll, scroll_system to scroll to centre the system containing the bar,
// * scroll_bar (smoother than scroll-system) is set to minimise the scroll distance between adjacent bars in
// * different systems
// */
//enum ScrollType_e {scroll_off, scroll_system, scroll_bar};

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
 * @method setCursorColour:
 * @abstract set the cursor outline colour
 * @param colour the new colour
 */
-(void)setCursorColour:(UIColor*)colour;

/*!
 * @method scroll
 * @abstract scroll the display by a percentage of the screen height from the current position
 * @param percent a percentage of the screen height,  +100 to scroll down 1 page, -100 to scroll up 1 page
 */
-(void)scroll:(int)percent;

/*!
 * @method didRotate
 * @abstract called to notify a screen orientation change
 */
-(void)didRotate;

/*!
 * @method enablePinch
 * @abstract enable pinch-zoom
 */
-(void)enablePinch;

/*!
 * @method disablePinch
 * @abstract disable pinch-zoom
 */
-(void)disablePinch;

//
/*!
 * @method colourPDNotes
 * @abstract colour the given set of notes in the given system
 * @param notes array elements are of type SSPDNote*
 * @param colour the colour to use for the components
 */
-(void)colourPDNotes:(NSArray<SSPDNote*>*)notes colour:(UIColor*)colour;

/*!
 * @method colourComponents
 * @abstract colour the components with the given colour
 * @param components array elements are of type SSComponent*
 * @param colour the colour to use for the components
 * @param elementTypes use sscore_dopt_colour_render_flags_e to define exactly what part of an item should be coloured
 */
-(void)colourComponents:(NSArray<SSComponent*>*)components colour:(UIColor *)colour elementTypes:(unsigned)elementTypes;

/*!
 * @method clearColouringForBarRange
 * @abstract clear all draw option colouring setup by setDrawOptions in specified bar range
 * @discussion requires contents-detail licence
 */
-(void)clearColouringForBarRange:(const sscore_barrange*)barrange;

/*!
 * @method clearAllColouring
 * @abstract clear all draw option colouring setup by setDrawOptions
 */
-(void)clearAllColouring;

/*!
 * @method selectItem
 * @abstract select an item by colouring it
 */
-(void)selectItem:(sscore_item_handle)item_h part:(int)partIndex bar:(int)barIndex
	   foreground:(CGColorRef)fg background:(CGColorRef)bg;

/*!
 * @method deselectItem
 * @abstract deselect an item previously selected
 */
-(void)deselectItem:(sscore_item_handle)item_h;

/*!
 * @method deselectAll
 * @abstract deselect all selected items
 */
-(void)deselectAll;

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

/*!
 * @method componentsAt:
 * @return an array of components within maxDistance of point p
 */
-(NSArray<SSComponent*> *)componentsAt:(CGPoint)p maxDistance:(float)maxDistance;

//  Added by David S Reich on 14/05/2016.
//  Modification Copyright © 2016 Musikyoshi. All rights reserved.
/*!
 * @property optimalSingleSystem
 * @abstract optimalSingleSystem - true for making one very wide single system
 * Set this before calling setupScore
 * Should NOT be set at the same time as optimalXMLxLayoutMagnification
 */
@property (nonatomic) bool optimalSingleSystem;

//  Added by David S Reich on 04/03/2017.
//  Modification Copyright © 2017 Musikyoshi. All rights reserved.
/*!
 * @property optimalXMLxLayoutMagnification
 * @abstract optimalXMLxLayoutMagnification - true for setting the magnification when useXMLxLayout is true
 * Set this before calling setupScore
 * Should NOT be set at the same time as optimalSingleSystem
 */
@property (nonatomic) bool optimalXMLxLayoutMagnification;


// For displaying student performance results

-(void) addNotePerformanceResultAtXPos:(CGFloat) iXPos
                                atYpos:(CGFloat) iYPos
                    withWeightedRating:(int)  iWeightedRating
                      withRhythmResult:(int)  iRhythmResult
                       withPitchResult:(int)  iPitchResult
                                noteID:(int)  iNoteID
                              isLinked:(bool) isLinked
                         linkedSoundID:(int)  iLinkedSoundID;

-(void) addSoundPerformanceResultAtXPos:(CGFloat) iXPos
                           withDuration:(int) iDuration
                                soundID:(int) iSoundID
                               isLinked:(bool) isLinked
                           linkedNoteID:(int) iLinkedNoteID;

-(void) updateNotePerformanceResultAtXPos:(CGFloat) iXPos
                         withRhythmResult:(int) iRhythmResult
                          withPitchResult:(int) iPitchResult;

-(CGFloat) getCurrentXOffset;

// scroll to and highlight note with this PerfromanceNote ID
-(bool) highlightNote:(int) iNoteID;

-(void) turnHighlightOff;

-(void) clearNotePerformanceResultAtXPos:(CGFloat) iXPos;

-(void) clearNotePerformanceResults;


@end
