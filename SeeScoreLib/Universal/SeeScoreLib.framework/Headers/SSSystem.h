//
//  SSSystem.h
//  SeeScoreLib
//
//  Copyright (c) 2015 Dolphin Computing Ltd. All rights reserved.
//
// No warranty is made as to the suitability of this for any purpose
//

#ifndef SeeScoreLib_mac_SSSystem_h
#define SeeScoreLib_mac_SSSystem_h

#import <CoreGraphics/CoreGraphics.h>

#include "sscore.h"
#include "sscore_contents.h"
#include "sscore_edit.h"

@class SSScore;

/*!
 @header SSystem.h
 @abstract interface to a SeeScore System (ie a sequence of bars of page width)
 */

/*!
 @struct SSCursorRect
 @abstract information required for drawing a bar cursor returned from getCursorRect
 */
typedef struct
{
	/*!
	 true if the required bar is in the system
	 */
	bool bar_in_system;
	
	/*!
	 the outline of the bar in the system (if bar_in_system = true)
	 */
	CGRect rect;
} SSCursorRect;


/*!
 @interface SSComponent
 @abstract information about a component returned from hitTest and componentsForItem
 */
@interface SSComponent : NSObject

/*!
 @property type
 @abstract the type of component
 */
@property (readonly) enum sscore_component_type_e type;

/*!
 @property partIndex
 @abstract the 0-based index of the part containing this
 */
@property (readonly) int partIndex;

/*!
 @property barIndex
 @abstract the 0-based index of the bar containing this
 */
@property (readonly)  int barIndex;

/*!
 @property rect
 @abstract the minimum rectangle around this item in the layout
 */
@property (readonly) CGRect rect;

/*!
 @property layout_h
 @abstract the unique identifier for the atomic drawn element in the layout (notehead,stem,accidental,rest etc)
 */
@property (readonly) sscore_layout_handle layout_h;

/*!
 @property item_h
 @abstract the unique identifier for the parent item in the score (note,rest,clef,time signature etc)
 */
@property (readonly) sscore_item_handle item_h;

/*!
 @property dirType_h
 @abstract the unique identifier for a direction-type inside a direction
 @discussion is sscore_invalid_item_handle for components which aren't part of a direction-type
 */
@property (readonly) sscore_directiontype_handle dirType_h;

/*!
 @property rawcomponent
 @abstract the sscore_component
 */
@property (readonly) sscore_component rawcomponent;

@end


/*!
 @interface SSDirectionType
 @abstract encapsulates a direction-type element
 */
@interface SSDirectionType : NSObject

/*!
 @property type
 @abstract the type of direction
 */
@property (readonly) enum sscore_direction_type type;

/*!
 @property staffIndex
 @abstract the staff: 1 = lower of 2, else 0
 */
@property (readonly) int staffIndex;

/*!
 @property directive
 @abstract true if a directive, ie aligned with the left of the time signature
 */
@property (readonly) bool directive;

/*!
 @property placement
 @abstract above or below the staff
 */
@property (readonly) enum sscore_placement_e placement;

/*!
 @property dirType_h
 @abstract the unique identifier for a direction-type inside a direction
 */
@property (readonly) sscore_directiontype_handle dirType_h;

/*!
 @property components
 @abstract the components in the layout associated with this item
 */
@property (readonly) NSArray<SSComponent*> *components;

/*!
 @property rawdirectiontype
 @abstract the sscore_con_directiontype
 */
@property (readonly) const sscore_con_directiontype *rawdirectiontype;

@end


/*!
 @interface SSDirectionTypeWords
 @abstract encapsulates a direction-type words element
 */
@interface SSDirectionTypeWords : SSDirectionType

/*!
 @property words
 @abstract getter returns the text in the direction-type. setter sets it
 */
@property NSString* words;

/*!
 @property bold
 @abstract get the bold property of the text.  false if false or undefined
 */
@property (readonly) bool bold;

/*!
 @property italic
 @abstract get the italic property of the text.  false if false or undefined
 */
@property (readonly) bool italic;

/*!
 @property pointSize
 @abstract point size of font if defined, else 0
 */
@property (readonly) float pointSize;

/*!
 @method setBold:italic:
 @abstract set bold and italic parameters
 */
-(void)setBold:(bool)bold italic:(bool)italic;

@end



/*!
 @interface SSColouredItem
 @abstract define colouring of an object in drawWithContext: at: magnification: colourRender:
 */
@interface SSColouredItem : NSObject

/*!
 @property item_h
 @abstract unique identifier of the item to colour
 */
@property sscore_item_handle item_h;

/*!
 @property colour
 @abstract the colour to use
 */
@property CGColorRef colour;

/*!
 @property coloured_render
 @abstract use sscore_dopt_colour_render_flags_e to define exactly what part of an item should be coloured
 */
@property unsigned coloured_render;

/*!
 @method initWithItem:
 @abstract initialise SSColouredItem
 @param item_h unique identifier of the item to colour
 @param colour the colour to use
 @param coloured_render use sscore_dopt_colour_render_flags_e to define exactly what part of an item should be coloured
 */
-(instancetype)initWithItem:(sscore_item_handle)item_h colour:(CGColorRef)colour render:(unsigned)coloured_render;

@end


/*!
 @interface SSColourRender
 @abstract define colouring of objects in drawWithContext: at: magnification: colourRender:
 */
@interface SSColourRender : NSObject

/*!
 @property flags
 @abstract normally 0 (sscore_dopt_flags_e)
 */
@property unsigned flags;
 
/*!
 @property colouredItems
 @abstract array of SSColouredItem
 */
@property NSArray<SSColouredItem*> *colouredItems;

/*!
 @method initWithItems:
 @abstract initialise SSColourRender
 @param items array of SSColouredItem
 */
-(instancetype)initWithItems:(NSArray<SSColouredItem*>*)items;

/*!
 @method initWithFlags:
 @abstract unused at present
 */
-(instancetype)initWithFlags:(unsigned)flags items:(NSArray<SSColouredItem*>*)items;

@end


/*!
 @interface SSStaff
 @abstract info for a single staff
 */
@interface SSStaff : NSObject

/*!
 @property staffRect
 @abstract rectangle enclosing a single staff in a system
 */
@property (readonly) CGRect staffRect;

/*!
 @property numLines
 @abstract the number of lines in the staff
 */
@property (readonly) int numLines;
@end


/*!
 @interface SSStaffLayout
 @abstract info about staves in a part returned from staffLayout
 */
@interface SSStaffLayout : NSObject

/*!
 @property partIndex
 @abstract the part index
 */
@property (readonly) int partIndex;

/*!
 @property tenthSize
 @abstract one tenth of the staff line separation in CG units
 */
@property (readonly) float tenthSize;

/*!
 @property staves
 @abstract the array of staff info for this part (expect normally 1 or 2 in array)
 */
@property (readonly) NSArray<SSStaff*> * staves;
@end

/*!
 @interface SSBarline
 @abstract info about a barline
 */
@interface SSBarline : NSObject

/*!
 @property barIndex
 @abstract the bar index
 */
@property (readonly) int barIndex;

/*!
 @property loc
 @abstract right/left barline
 */
@property (readonly) enum sscore_barlineloc_e loc;

/*!
 @property rect
 @abstract a rectangle completely enclosing the barline and any repeat dots (ie wider for double barlines)
 */
@property (readonly) CGRect rect;
@end

/*!
 @interface SSBarLayout
 @abstract info about barlines in a system/part returned from barLayout:
 */
@interface SSBarLayout : NSObject

/*!
 @property partIndex
 @abstract the part index
 */
@property (readonly) int partIndex;

/*!
 @property barlines
 @abstract array of barline info for the system/part
 */
@property (readonly) NSArray<SSBarline*> * barlines;
@end

@class SSSystem;

@interface SSTargetLocation : NSObject

@property (readonly) SSSystem *system;

@property (readonly) int partIndex;

@property (readonly) int barIndex;

@property (readonly) const sscore_edit_type *itemType;

@property (readonly) const sscore_edit_targetlocation *rawtarget;

@property (readonly) CGPoint insertPos;

@end

/*!
 @interface SSSystem
 @abstract interface to a SeeScore System
 @discussion A System is a range of bars able to draw itself in a CGContextRef, and is a product of calling SScore layoutXXX:
 <p>
 drawWithContext draws the system into a CGContextRef, the call with colourRender argument allowing item colouring (and requiring an additional licence)
 <p>
 partIndexForYPos, barIndexForXPos can be used to locate the bar and part under the cursor/finger
 <p>
 hitTest is used to find the exact layout components (eg notehead, stem, beam) at a particular location (requiring a contents licence)
 <p>
 componentsForItem is used to find all the layout components of a particular score item (requiring a contents licence)
 */
@interface SSSystem : NSObject

/*!
 @property index
 @abstract the index of this system from the top of the score. Index 0 is the topmost.
 */
@property (nonatomic,readonly) int index;

/*!
 @property barRange
 @abstract the start bar index and number of bars for this system.
 */
@property (nonatomic,readonly) sscore_barrange barRange;

/*!
 @property defaultSpacing
 @abstract a default value for vertical system spacing
 */
@property (nonatomic,readonly) float defaultSpacing;

/*!
 @property bounds
 @abstract the bounding box of this system.
 */
@property (nonatomic,readonly) CGSize bounds;

/*!
 @property magnification
 @abstract the magnification this system - a value of 1.0 approximates to a standard 6mm staff height as in a printed score
 */
@property (nonatomic,readonly) float magnification;

/*!
 @property rawsystem
 @abstract access the underlying C type
 */
@property (nonatomic,readonly) sscore_system *rawsystem;

/*!
 @method includesBar:
 @abstract does this system include the bar?
 @return true if this system includes the bar with given index
 */
-(bool)includesBar:(int)barIndex;

/*!
 @method includesBarRange:
 @abstract does this system include the bar range?
 @return true if this system includes any bars in barrange
 */
-(bool)includesBarRange:(const sscore_barrange*)barrange;

/*!
 @method drawWithContext:
 @abstract draw this system at the given point.
 @param ctx the CGContextRef to draw into
 @param tl the coordinate at which to place the top left of the system
 @param magnification the scale to draw at. NB This is normally 1, except during active zooming.
 The overall magnification is set in sscore_layout
 */
-(void)drawWithContext:(CGContextRef)ctx
					at:(CGPoint)tl
		 magnification:(float)magnification;

/*!
 @method drawWithContext:
 @abstract draw this system at the given point allowing optional colouring of particular items/components in the layout.
 @param ctx the CGContextRef to draw into
 @param tl the coordinate at which to place the top left of the system
 @param magnification the scale to draw at. NB This is normally 1, except during active zooming.
 The overall magnification is set in sscore_layout
 @param colourRender each SSRenderItem object in the array defines special colouring of a particular score item
 */
-(enum sscore_error)drawWithContext:(CGContextRef)ctx
								 at:(CGPoint)tl
					  magnification:(float)magnification
					   colourRender:(SSColourRender*)colourRender;

/*!
 @method printTo:
 @abstract draw this system at the given point with optimisation for printing (ie without special pixel alignment).
 @param ctx the CGContextRef to draw into
 @param tl the coordinate at which to place the top left of the system
 @param magnification (normally 1.0) the scale to draw at.
 */
-(void)printTo:(CGContextRef)ctx
			at:(CGPoint)tl
 magnification:(float)magnification;

/*!
 @method cursorRectForBar:context:
 @abstract get the cursor rectangle for a particular system and bar
 @param barIndex the index of the bar in the system
 @param ctx a graphics context only for text measurement eg a bitmap context
 @return the bar rectangle which can be used for a cursor
 */
-(SSCursorRect)cursorRectForBar:(int)barIndex context:(CGContextRef)ctx;

/*!
 @method partIndexForYPos:
 @abstract get the part index of the part enclosing the given y coordinate in this system
 @param ypos the y coord
 @return the 0-based part index
 */
-(int)partIndexForYPos:(float)ypos;

/*!
 @method staffIndexForYPos:
 @abstract get the index of the staff within the part closest to the given y coordinate in this system
 @param ypos the y coord
 @return the 0-based staff index - 0 for a single-staff part
 */
-(int)staffIndexForYPos:(float)ypos;

/*!
 @method barIndexForXPos:
 @abstract get the bar index of the bar enclosing the given x coordinate in this system
 @param xpos the x coord
 @return the 0-based bar index
 */
-(int)barIndexForXPos:(float) xpos;


/*!
 @method staffLocationForYPos:
 @abstract from the ypos return above or below according to the ypos relative to the closest staff
 @param ypos the y coord
 @return  above/below relative to the staff
 */
-(enum sscore_system_stafflocation_e)staffLocationForYPos:(float)ypos;

/*!
 @method hitTest:
 @abstract get an array of components which intersect a given a point in this system
 @discussion a contents licence is required
 @param p the point
 @return array of intersecting SSComponent - empty if unlicensed
 */
-(NSArray<SSComponent*> *)hitTest:(CGPoint)p;

/*!
 @method closeFeatures:
 @abstract get an array of components within a certain distance of a given a point in this system
 @discussion results are sorted in order of increasing distance. A contents licence is required
 @param p the point
 @param distance the distance
 @return array of intersecting SSComponent - empty if unlicensed
 */
-(NSArray<SSComponent*> *)closeFeatures:(CGPoint)p distance:(float)distance;

/*!
 @method componentsForItem:
 @abstract get an array of layout components which belong to a particular score item in this system
 @discussion a contents licence is required
 @param item_h the unique identifier for an item (eg note) in the score
 @return array of SSComponent - empty if unlicensed
 */
-(NSArray<SSComponent*>*)componentsForItem:(sscore_item_handle)item_h;

/*!
 @method boundsForItem:
 @abstract get a bounding box which encloses all layout components for a score item in this system
 @discussion a contents licence is required
 @param item_h
 @return the bounds of (all components of) the item - empty if not licensed
 */
-(CGRect)boundsForItem:(sscore_item_handle)item_h;

/*!
 @method nearestInsertTargetFor:at:
 @abstract return the nearest valid target location to insert an item of given type in the score
 @param itemType the type of item to insert
 @param pos the location in the system near to which we would like to insert the item.
 @param max_distance the maximum distance to accept a target
 @return return the nearest valid target location at which the itemType can be inserted in the score. Return nil if not near a valid point
 */
-(SSTargetLocation*)nearestInsertTargetFor:(const sscore_edit_type *)itemType at:(CGPoint)pos max:(float)max_distance;

/*!
 @method drawDragItem:systemTopLeft:dragInfo:
 @abstract draw any required decoration - (ledgers) for the item being dragged in the system
 @param ctx the graphics context
 @param topLeft the top left of the system
 @param itemType type of the dragged item 
 @param pos the new position
 */
-(void)drawDragItem:(CGContextRef)ctx itemType:(const sscore_edit_type *)itemType pos:(CGPoint)pos;

/*!
 @method nearestNoteComponentAt: maxDistance:
 @abstract find the closest layout component within maxDistance of pos that is part of a note (notehead,stem,dot,accidental etc)
 @param pos the location
 @param maxDist the maximum (euclidean) distance to accept items
 @return the closest note component
 */
-(SSComponent*)nearestNoteComponentAt:(CGPoint)pos maxDistance:(float)maxDist;

/*!
 @method nearestDirectionComponentAt: maxDistance:
 @abstract find the closest layout component within maxDistance of pos that is part of a direction (words etc)
 @param pos the location
 @param type the type of direction to find
 @param maxDist the maximum (euclidean) distance to accept items
 @return the closest note component
 */
-(SSComponent*)nearestDirectionComponentAt:(CGPoint)pos type:(enum sscore_direction_type)type maxDistance:(float)maxDist;

/*!
 @method directionForComponent:
 @abstract find the direction-type from a layout component created from it
 @param directionComponent the component
 @return the direction-type
 */
-(SSDirectionType*)directionTypeForComponent:(SSComponent*)directionComponent;

/*!
 @method directionsNearComponent:
 @abstract find the directions around the point defined by the (note or direction) component
 @param comp a component of a direction or note
 @return array of SSDirectionType* . Those of type sscore_dir_words can be cast to SSDirectionTypeWords, and then the text
 is readable and writeable
 */
-(NSArray<SSDirectionType*>*)directionsNearComponent:(SSComponent*)comp;

/*!
 @method deleteItemForComponent:
 @abstract delete an item identified by a layout component
 @param item a layout component
 @return true if it succeeded
 */
-(bool)deleteItem:(SSComponent*)item;

/*!
 @method deleteDirectionType:
 @abstract delete a single direction-type from a direction
 @param dType the direction-type from directionsNearComponent: or directionTypeForComponent:
 @return true if it succeeded
 */
-(bool)deleteDirectionType:(SSDirectionType*)dType;

/*!
 @method partLayout:
 @abstract get staff measurement for the part in this system
 @param partIndex the 0-based part index
 @return staff measurements
 */
-(SSStaffLayout*)staffLayout:(int)partIndex;

/*!
 @method barLayout:
 @abstract get barline measurements for the part in this system
 @param partIndex the 0-based part index
 @return barline dimensions
 */
-(SSBarLayout*)barLayout:(int)partIndex;

/*!
 @method pointsToFontSize:
 @abstract get the pointsize of a UIFont (of type "Georgia") which will look exactly like a SeeScore direction with this fontsize
 @param points the font size defined in the XML file
 @return the fontsize to use in the call [UIFont fontWithName:@"Georgia" size:fontsize];
 */
-(float)pointsToFontSize:(float)points;

/*!
 @method tryInsertItem:at:
 @abstract attempt to insert the item in the score at the target location, return true if succeeded
 @param info information about the item to insert
 @param target the target location from nearestInsertTarget
 @return true if insert succeeded
 */
-(bool)tryInsertItem:(const sscore_edit_insertinfo*)info at:(SSTargetLocation*)target;

/*!
 @method selectItem:part:bar:foreground:background:
 @abstract select the item in the system/part/bar and colour it
 @param item_h the item handle
 @param partIndex the part index
 @param barIndex the bar index
 @param fgCol foreground colour for highlight
 @param bgCol background colour for highlight
 */
-(void)selectItem:(sscore_item_handle)item_h part:(int)partIndex bar:(int)barIndex
	   foreground:(CGColorRef)fgCol background:(CGColorRef)bgCol;

/*!
 @method deselectItem:
 @abstract deselect the item previously selected item
 @param item_h the item handle
 */
-(void)deselectItem:(sscore_item_handle)item_h;

/*!
 @method deselectAll:
 @abstract deselect all selected items in this system
 */
-(void)deselectAll;

/*!
 @method updateLayout:newState:
 @abstract update the layout to show the state in the sscore_state_container (called by state change handler)
 @param ctx the graphics context
 @param newstate the new state from the state change handler
 */
-(void)updateLayout:(CGContextRef)ctx newState:(const sscore_state_container*)newstate;


// internal use only
@property sscore_libkeytype *key;

// internal use only
-(instancetype)initWithSystem:(sscore_system*)sy score:(SSScore*)sc;

@end

#endif
