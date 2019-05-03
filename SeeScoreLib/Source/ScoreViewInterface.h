//
//  ScoreViewInterface.h
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//

#import <Foundation/Foundation.h>

/*!
 * @struct SSSystemPoint
 * @abstract return value from systemAtYPos
 */
typedef struct SSSystemPoint
{
	// ignore this struct if false
	bool isValid;
	
	// The index of this system
	int systemIndex;
	
	// the position in the coordinates of the system
	CGPoint posInSystem;
	
	// the 0-based part index
	int partIndex;
	
	// the 0-based bar index
	// -1 if to left or right of system
	int barIndex;
	
	// the 0-based staff index (where there are 2 staves in a part)
	int staffIndex;
	
	// position relative to staff
	enum sscore_system_stafflocation_e staffLocation;
	
	// bottom line of staff = 0. bottom space = 1, top line = 8, 1st ledger below is -2
	int lineSpaceIndex;
	
	enum sscore_system_xlocation_e xLocation;
	
} SSSystemPoint;

/*!
 * @protocol ScoreViewInterface
 * @abstract Interface to the underlying view (SSScrollView or SSSystemView) provided to the SSEditLayer
 */
@protocol ScoreViewInterface

-(CGPoint)contentOffset;

-(CGFloat)zoomScale;

-(float)drawScale;

-(CGRect)frame;

-(void)setFrame:(CGRect)frame;

-(bool)pointInside:(CGPoint)point withEvent:(UIEvent * _Nullable)event;

/*!
 * @method systemAtPos
 * @abstract return the system index and location within it for a point in the SSScrollView
 * @discussion use systemAtIndex: to get the SSSystem from the systemIndex
 * @param p the point within the SSScrollView
 * @return the SystemPoint defining the system index, and part and bar indices at p
 */
-(SSSystemPoint)systemAtPos:(CGPoint)p;

-(CGPoint)systemTopLeft:(int)systemIndex;

/*!
 * @method systemAtIndex
 * @return the system at the given index (0-based, top to bottom)
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

-(void)drawItemOutline:(SSEditItem* _Nonnull)editItem systemIndex:(int)systemIndex ctx:(CGContextRef _Nonnull)ctx
				colour:(CGColorRef _Nonnull)colour margin:(CGFloat)margin linewidth:(CGFloat)lineWidth;

-(void)drawItemDrag:(SSEditItem* _Nonnull)editItem systemIndex:(int)systemIndex ctx:(CGContextRef _Nonnull)ctx
			dragPos:(CGPoint)dragPos showTargetDashedLine:(bool)showTargetDashedLine;

-(void)selectVoice:(NSString* _Nonnull)voice systemIndex:(int)systemIndex partIndex:(int)partIndex;
-(void)deselectVoice;

// for displaying fake repeat barlines over the score
-(void)displayFakeRepeatBarlineLeft:(int)barIndex;
-(void)displayFakeRepeatBarlineRight:(int)barIndex;
-(void)clearFakeRepeatBarlines;

@end
