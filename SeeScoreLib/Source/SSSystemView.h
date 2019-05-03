//
//  SSSystemView.h
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//
// This is used by SSScrollView and manages and draws a single system of music using the SeeScoreLib framework
//

#import <UIKit/UIKit.h>
#include <SeeScoreLib/SeeScoreLib.h>
#import "ScoreViewInterface.h"

@class SSScore;
@class SSSystem;
@class SSColourRender;

/*!
 * @interface SSSystemView
 * @abstract used by SSScrollView, manages and draws a single system of music using the SeeScoreLib framework
 */
 // MKMODSS - removed SSViewInterface from protocol list
@interface SSSystemView : UIView <ScoreChangeHandler> // MKMOD - added the 2 protocols - 4/1/17

/*!
 * @property height
 * @abstract the height of the system within the UIView in CGContext units
 */
@property (nonatomic,readonly) float systemHeight;

// MKMOD - deleted property upperMargin - 4/1/17

/*!
 * @property colourRender
 * @abstract any current colour rendering (used to define coloured items in the score)
 */
@property (nonatomic) SSColourRender * _Nullable colourRender;

/*!
 * @property system
 * @abstract the SSSystem which this is displaying
 */
@property (nonatomic,readonly) SSSystem * _Nonnull system;

/*!
 * @property systemIndex
 * @abstract the index of the system that this is displaying - 0 is the top system
 */
@property (nonatomic, readonly) int systemIndex;

/*!
 @property drawScale
 @abstract the scale at which this system was drawn (1.0 approximates to a standard printed score with 6mm staff height)
 */
@property (nonatomic, readonly) float drawScale;

/*!
 @property drawFlags
 @abstract bitset of sscore_dopt_flags_e
 */
@property (nonatomic, readonly) unsigned drawFlags;

/*!
 @property topLeft
 @abstract the top left of the SSSystem in superView coords
 */
@property (nonatomic, readonly) CGPoint topLeft;

-(instancetype _Nonnull)init NS_UNAVAILABLE;

/*!
 * @method initWithBackgroundColour
 * @abstract initialise defining a background colour
 * @param bgcol the background colour
 * @return the SSSystemView
 */
- (instancetype _Nonnull)initWithBackgroundColour:(UIColor* _Nonnull)bgcol;

/*!
 * @method setSystem
 * @abstract setup with the system
 * @param system the system
 * @param score the score
 * @param tl the top left of the system UIView in the superview
 * @param zoomScale the zoom magnification to apply to the system layout
 * @param margin the extra width and height left, right and above, below
 */
// MKMOD - added params tl and margin   4/1/17
-(void)setSystem:(SSSystem* _Nonnull)system
		   score:(SSScore* _Nonnull)score
		 topLeft:(CGPoint)tl
	   zoomScale:(float)zoomScale
		  margin:(CGSize)margin;

/*!
 * @method clear
 * @abstract clear any owned pointers so the view can be recycled
 */
-(void)clear;

/*!
 * @method clearColourRender
 * @abstract clear all coloured rendering
 */
-(void)clearColourRender;

/*!
 * @method clearColourRenderForBarRange:
 * @abstract clear any coloured rendering in the bar range
 * @param barrange the range of bars defined by a start index and number of bars
 */
-(void)clearColourRenderForBarRange:(const sscore_barrange* _Nonnull)barrange;

/*!
 * @method showCursorAtBar
 * @abstract show the bar cursor at the given bar
 * @param barIndex the index of the bar
 * @param pre if true show a single vertical line cursor at the start of the bar, else a rectangle around the bar
 */
-(void)showCursorAtBar:(int)barIndex pre:(BOOL)pre;

/*!
 * @method showCursorAtXpos
 * @abstract show the vertical line cursor at the given xpos in the system
 * @param xpos the x position of the cursor within the system
 * @param barIndex the index of the bar which the cursor is to be displayed within
 */
-(void)showCursorAtXpos:(float)xpos barIndex:(int)barIndex;

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
 * @method showVoiceTracks
 * @abstract show or hide coloured tracks between notes and rests on each voice in each part
 */
-(void)showVoiceTracks:(bool)show;

/*!
 * @method pointInside:withEvent:
 * @abstract detect if the point is within this UIView
 * @param point the point
 * @event the (tap) event or nil
 * @return true if the point is within this system
 */
-(bool)pointInside:(CGPoint)point withEvent:(UIEvent * _Nullable)event;

/*!
 * @method drawItemOutline:ctx:topLeft:colour:margin:linewidth:
 * @abstract draw a dashed outline around the given item
 * @param editItem the item in the system
 * @param ctx the graphics context
 * @param topLeft the top left of the system
 * @param colour the colour of the dashed line
 * @param margin the margin from the item to the drawn outline
 * @param lineWidth the width of the dashed line, 0 for default
 */
-(void)drawItemOutline:(SSEditItem* _Nonnull)editItem ctx:(CGContextRef _Nonnull)ctx topLeft:(CGPoint)topLeft
				colour:(CGColorRef _Nonnull)colour margin:(CGFloat)margin linewidth:(CGFloat)lineWidth;

-(void)drawItemDrag:(SSEditItem* _Nonnull)editItem ctx:(CGContextRef _Nonnull)ctx topLeft:(CGPoint)topLeft dragPos:(CGPoint)dragPos showTargetDashedLine:(bool)showTargetDashedLine;

-(SSTargetLocation* _Nullable)nearestInsertTargetFor:(SSEditType* _Nonnull)editType at:(CGPoint)pos maxDistance:(CGFloat)maxDistance;

-(SSNoteInsertPos)nearestNoteInsertPos:(CGPoint)pos editType:(SSEditType* _Nonnull)editType maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers;

-(SSNoteInsertPos)nearestNoteReinsertPos:(CGPoint)pos editItem:(SSEditItem* _Nonnull)editItem maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers;

// MKMODSS - all of the entries below were not in the 3/19 SeeScore code update

///*
//// MKMOD - added this method 4/1/17
///*!
// * @method zoomUpdate
// * @abstract call for interactive zooming (magnifies backImage)
// * @param z the zoom magnification
// */
//-(void)zoomUpdate:(float)z;
//
///*!
// * @method zoomComplete
// * @abstract finish interactive zooming - system is redrawn at new magnification
// */
//-(void)zoomComplete;
//
///*!
// * @method selectItem
// * @abstract show an item as selected in the layout by colouring
// */
//-(void)selectItem:(sscore_item_handle)item_h part:(int)partIndex bar:(int)barIndex
//       foreground:(CGColorRef)fg background:(CGColorRef)bg;
//
///*!
// * @method deselectItem
// * @abstract deselect a selected item
// */
//-(void)deselectItem:(sscore_item_handle)item_h;
//
///*!
// * @method deselectAll
// * @abstract deselect all selected items
// */
//-(void)deselectAll;
//
///*!
// * @method updateLayout:newState
// * @abstract update the layout after edit
// */
//-(void)updateLayout:(CGContextRef)ctx newState:(const sscore_state_container *)newstate;
//
//*/

@end
