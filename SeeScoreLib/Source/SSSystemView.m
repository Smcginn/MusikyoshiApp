//
//  SSSystemView.m
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//
// This is used by SSScrollView and manages and draws a single system of music using the SeeScoreLib framework
//

//#define DrawOutline // define this to draw a blue outline around the SSSystemView for debug

#import "SSSystemView.h"
#import <QuartzCore/QuartzCore.h>
#include <dispatch/dispatch.h>
#include "sscore_key.h"
#include <assert.h>

static const float CursorLineWidth = 2;

static const struct {float r,g,b,a;} kDefaultBackgroundColour = {1.0F,1.0F,0.95F,1.0F};

@interface CursorLayer : CALayer
-(CursorLayer*)init;
-(void)show:(CGRect)frame;
-(void)hide;
@end

@implementation CursorLayer

-(CursorLayer*)init
{
	self = [super init];
	self.borderWidth = CursorLineWidth;
    // MKMOD - changed borderColor from blue to orange  4/1/17
    // MKMOD - changed borderColor from orange to red  4/1/17
    self.borderColor = [UIColor redColor].CGColor; 
	self.opacity = 0.0;
	return self;
}

-(void)show:(CGRect)r
{
	self.frame = r;
	self.opacity = 1.0F;
}

-(void)setColour:(UIColor*)colour
{
	self.borderColor = colour.CGColor;
	[self setNeedsDisplay];
}

-(void)hide
{
	self.opacity = 0;
}
@end


@interface SSSystemView ()
{
	SSScore *score;
	SSSystem *system;
	float zoomScale; // zoom magnification of system layout
	// MKMODSS  removed: bool isZooming;
	CursorLayer *cursorLayer;
    // MKMOD - deleted bgColor  4-1-17
    // MKMOD - added 5 lines below  4-1-17
	sscore_changeHandler_id changeHandlerId;
	// MKMODSS  CGPoint topLeft;
	CGSize margin;
	// MKMODSS  CGRect ensureVisibleRect;
	CGPoint normalCentre;
}
@end
	
@implementation SSSystemView

// MKMOD - added this method  4-1-17
-(id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		score = nil;
		system = nil;
		self.backgroundColor = [[UIColor alloc] initWithRed:kDefaultBackgroundColour.r green:kDefaultBackgroundColour.g blue:kDefaultBackgroundColour.b alpha:kDefaultBackgroundColour.a] ;
		zoomScale = 1.0;
		// MKMODSS  isZooming = false;
		cursorLayer = [[CursorLayer alloc] init];
		[self.layer addSublayer:cursorLayer];
		changeHandlerId = 0;
	}
	return self;
}

// MKMOD - added this method  4-1-17
-(id)initWithFrame:(CGRect)frame
{
    // MKMOD - condensed inf statement below from 2 lines   4-1-17
	if (self = [super initWithFrame:frame])
	{
		score = nil;
		system = nil;
        // MKMOD - deleted one line ref'ing bgCol, added a different assignment to self.backgroundColor  4-1-17
		self.backgroundColor = [[UIColor alloc] initWithRed:kDefaultBackgroundColour.r green:kDefaultBackgroundColour.g blue:kDefaultBackgroundColour.b alpha:kDefaultBackgroundColour.a] ;
		zoomScale = 1.0;
		// MKMODSS  isZooming = false;
		cursorLayer = [[CursorLayer alloc] init];
		[self.layer addSublayer:cursorLayer];
		changeHandlerId = 0;
	}
	return self;
}

- (id)initWithBackgroundColour:(UIColor*)bgcol
{
	assert(bgcol);
	if (self = [super init])
	{
		score = nil;
		system = nil;
		self.backgroundColor = bgcol;
		zoomScale = 1.0;
		// MKMODSS  isZooming = false;
		cursorLayer = [[CursorLayer alloc] init];
		[self.layer addSublayer:cursorLayer];
		changeHandlerId = 0;
	}
    return self;
}

// MKMOD - added this method 4/1/17
-(void)dealloc
{
	if (changeHandlerId != 0)
		[score removeChangeHandler:changeHandlerId];
}

-(int)systemIndex
{
	assert(system != nil);
	return system.index;
}

-(float) drawScale
{
	return system.magnification * zoomScale;
}

// MKMOD - added this method 4/1/17
-(CGPoint)topLeft
{
	CGRect f = self.frame;
	return CGPointMake(f.origin.x + margin.width, f.origin.y + margin.height);
}

-(int)partIndexForYPos:(float)ypos
{
	assert(system != nil);
	return [system partIndexForYPos:ypos];
}

-(int)barIndexForXPos:(float)xpos
{
	assert(system != nil);
	return [system barIndexForXPos:xpos];
}

// MKMOD - added params tl, marg 4/1/17
-(void)setSystem:(SSSystem*)sys
		   score:(SSScore*)sc
		 topLeft:(CGPoint)tl
	   zoomScale:(float)zoom
		  margin:(CGSize)marg
{
	assert(sys && sc);
    // MKMOD - added this if fragment 4/1/17
	if (score && changeHandlerId != 0)
	{
		[score removeChangeHandler:changeHandlerId];
		changeHandlerId = 0;
	}
	score = sc;
	system = sys;
	// MKMODSS  topLeft = tl;   // MKMOD - added this  4/1/17
	margin = marg;
	_colourRender = nil;
	zoomScale = zoom;
	// MKMODSS  isZooming = false;
    // MKMOD - deleted 2 lines setting frame  4/1/17
    // MKMOD - added 2 lines below setting frame  4/1/17
	CGSize sysBounds = sys.bounds;
	self.frame = CGRectMake(tl.x, tl.y, (sysBounds.width + 2 * margin.width)*zoomScale, (sysBounds.height + 2 * margin.height)*zoomScale);
	//_upperMargin = (frame.size.height - self.systemHeight) / 2;  // MKMOD - cpmmented this out  4/1/17
	[self hideCursor];
	[self setNeedsDisplay];
	changeHandlerId = [score addChangeHandler:self];
}

-(void)clear
{
    // MKMOD - added this if code fragment  4/1/17
	if (score && changeHandlerId != 0)
	{
		[score removeChangeHandler:changeHandlerId];
		changeHandlerId = 0;
	}
	score = nil;
	system = nil;
	self.colourRender = nil;
}

// MKMOD - deleted method upperMargin  4/1/17

-(float)systemHeight
{
	return system ? system.bounds.height : 0;
}

// MKMOD - changed param from single to array of SSColouredItem*  4/1/17
-(CGRect)boundsForItems:(NSArray<SSColouredItem*> *)items
{
	CGRect uRect = CGRectMake(0, 0, 0, 0);
	for (SSColouredItem *item in items)
	{
		CGRect r = [system boundsForItem:item.item_h];
		if (r.size.width > 0)
		{
			uRect = (uRect.size.width > 0) ? CGRectUnion(uRect, r) : r;
		}
	}
	return uRect;
}

// MKMOD - added entrie changedColouringFrom method  4/1/17
-(NSArray<SSColouredItem*> *)changedColouringFrom:(SSColourRender*)a to:(SSColourRender*)b
{
	NSMutableArray<SSColouredItem*> *rval = NSMutableArray.array;
	if (a == nil || a.colouredItems.count == 0)
	{
		return b.colouredItems;
	}
	else
	{
		NSMutableDictionary *dict_a = NSMutableDictionary.dictionary; // create dictionary lookup for items in a
		for (SSColouredItem *item_a in a.colouredItems)
		{
			NSNumber *key = [[NSNumber alloc] initWithUnsignedInt:(unsigned)item_a.item_h];
			//if ([dict_a objectForKey:key] == nil)
			[dict_a setObject:item_a forKey:key]; // ignore duplicates with same key
		}
		NSMutableSet *unchangedItems = NSMutableSet.set;
		for (SSColouredItem *item_b in b.colouredItems)
		{
			NSNumber *key = [[NSNumber alloc] initWithUnsignedInt:(unsigned)item_b.item_h];
			SSColouredItem *item_a = [dict_a objectForKey:key];
			if (item_a != nil)
			{
				if (item_a.colour != item_b.colour
					|| item_a.coloured_render != item_b.coloured_render)
				{
					[rval addObject:item_a];
					[rval addObject:item_b];
				}
				// else these 2 items are identical in both lists and we don't need to add a change
				[unchangedItems addObject:key];
			}
			else // item_b is not in list a
			{
				[rval addObject:item_b];
			}
		}
		for (NSNumber *key in unchangedItems)
		{
			[dict_a removeObjectForKey:key]; // remove from dict so we can add items left in dict to list of changes
		}
		for (SSColouredItem *item_a in dict_a.allValues) // items remaining in dictionary have not been paired with items in b
		{
			[rval addObject:item_a];
		}
		return rval;
	}
}

-(void)setColourRender:(SSColourRender*)render
{
	assert(render.colouredItems.count < 1000);
    // MKMOD - changed 3 lines to the 3 lines below  4/1/17
	// careful to optimise to detect minimum changes as this minimises the area to redraw and has a significant impact on the speed
	NSArray<SSColouredItem*> *changedColourings = [self changedColouringFrom:_colourRender to:render];
	if (changedColourings.count > 0)
	{
        // MKMOD - changed quite a bit in here. Consult commit on  4/1/17

		CGRect r = [self boundsForItems:changedColourings];
		_colourRender = render;
		if (r.size.width > 0)
		{
			[self setNeedsDisplayInRect:r];
		}
		else
		{
			[self setNeedsDisplay];
		}
	}
}

-(void)clearColourRender
{
	CGRect uRect = CGRectMake(0, 0, 0, 0);
	// add old items to bounds..
	if (_colourRender) // get rect bounds of changing items to optimise the update
	{
        // MKMOD - changed line below  4/1/17
		uRect = [self boundsForItems:_colourRender.colouredItems];
	}
	_colourRender = nil;
	if (uRect.size.width > 0)
	{
		[self setNeedsDisplayInRect:uRect];
	}
	else
	{
		[self setNeedsDisplay];
	}
}

-(bool)bar:(int)barIndex inRange:(const sscore_barrange*)barrange
{
	return barIndex >= barrange->startbarindex && barIndex < barrange->startbarindex + barrange->numbars;
}

-(void)clearColourRenderForBarRange:(const sscore_barrange*)barrange
{
	if (self.colourRender != nil)
	{
		NSMutableArray *newItems = NSMutableArray.array;
		for (SSColouredItem *item in self.colourRender.colouredItems)
		{
			NSArray *comps = [system componentsForItem:item.item_h];
			for (SSComponent *comp in comps)
			{
				if (![self bar:comp.barIndex inRange:barrange])
				{
					[newItems addObject:item]; // add items which arent in specified barrange
				}
				// only look at the first component
				break;
			}
		}
		if (newItems.count > 0)
		{
			SSColourRender *newRender = [[SSColourRender alloc] initWithItems:newItems];
			[self setColourRender:newRender];
		}
		else
			[self setColourRender:nil];
	}
}

-(SSSystem*)system
{
	return system;
}

-(SSCursorRect)barRectangle:(int)barIndex
{
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	SSCursorRect cursorRect = [system cursorRectForBar:barIndex context:ctx];
	UIGraphicsEndImageContext();
	
	// MKMODSS 4 lines below used to be;
	// cursorRect.rect.origin.x += margin.width;
	// cursorRect.rect.origin.y += margin.height;

	cursorRect.rect.origin.x = (cursorRect.rect.origin.x + margin.width) * zoomScale;
	cursorRect.rect.origin.y = (cursorRect.rect.origin.y + margin.height) * zoomScale;
	cursorRect.rect.size.width *= zoomScale;
	cursorRect.rect.size.height *= zoomScale;
	return cursorRect;
}

-(void)showCursorAtBar:(int)barIndex pre:(BOOL)pre
{
	if (score && system) // it may have been recycled on another thread (shouldn't happen?)
	{
		SSCursorRect cursorRect = [self barRectangle:barIndex];
		if (cursorRect.bar_in_system)
		{
			[cursorLayer show:CGRectMake(cursorRect.rect.origin.x,
										 cursorRect.rect.origin.y,
										 pre ? cursorLayer.borderWidth : cursorRect.rect.size.width,
										 cursorRect.rect.size.height)];
		}
		else
			[cursorLayer hide];
	}
}

-(void)showCursorAtXpos:(float)xpos barIndex:(int)barIndex
{
	if (score && system) // it may have been recycled on another thread (shouldn't happen?)
	{
		SSCursorRect cursorRect = [self barRectangle:barIndex];
		if (cursorRect.bar_in_system)
		{
			[cursorLayer show:CGRectMake(xpos  - cursorLayer.borderWidth/2,
										 cursorRect.rect.origin.y,
										 cursorLayer.borderWidth,
										 cursorRect.rect.size.height)];
		}
		else
			[cursorLayer hide];
	}
}

-(void)hideCursor
{
	[cursorLayer hide];
}

// MKMOD - added this method  4/1/17
-(void)setCursorColour:(UIColor*)colour
{
	[cursorLayer setColour:colour];
}

// MKMODSS - removed the following methods
/*
-(void)zoomUpdate:(float)z
{
	zoom = z;
    // MKMOD - added line below   4/1/17
	self.bounds = CGRectMake(0,0,self.bounds.size.width, system.bounds.height*z);
	isZooming = true;
	self.colourRender = nil; // clear colouring on zoom
	[self setNeedsDisplay];
}

-(void)zoomComplete
{
	zoom = 1.0;
	isZooming = false;
	self.colourRender = nil; // clear colouring on zoom
	[self setNeedsDisplay];
}
*/

-(void)drawInContext:(CGContextRef)ctx
{
	assert(ctx && system);
    // MKMOD - changed line below 4/1/17
	CGPoint tl = CGPointMake(margin.width, margin.height);
	// draw system
	if (_colourRender)
	{
		[system drawWithContext:ctx at:tl magnification:zoomScale colourRender:_colourRender];
	}
	else if (_drawFlags != 0) // use drawFlags if no coloured items
	{
		SSColourRender *render = [[SSColourRender alloc] initWithFlags:_drawFlags items:NSArray.array];
		[system drawWithContext:ctx at:tl magnification:zoomScale colourRender:render];
	}
	else
		[system drawWithContext:ctx at:tl magnification:zoomScale];
}

- (void)drawRect:(CGRect)rect
{
	//[super drawRect:rect];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	// we need to clear the background even when we draw the background image which should fill the frame
	// otherwise we get an intermittent faint horizontal line artifact between systems esp with retina display
    // MKMOD - deleted assert, changed line below 4/1/17
	CGContextSetFillColorWithColor (ctx, self.backgroundColor.CGColor);
	CGContextFillRect (ctx, rect);
	if (system)
	{
		[self drawInContext:ctx];
	}
#ifdef DrawOutline
	CGContextSetStrokeColorWithColor (ctx, UIColor.blueColor.CGColor);
	CGContextSetLineWidth(ctx, 3);
	CGContextStrokeRect(ctx, rect);
#endif
}

/*
MKMODSS removed these two methods:
-(void)selectItem:(sscore_item_handle)item_h part:(int)partIndex bar:(int)barIndex
	   foreground:(CGColorRef)fg background:(CGColorRef)bg
{
	[system selectItem:item_h part:partIndex bar:barIndex foreground:fg background:bg];
	[self setNeedsDisplay];
}

-(void)deselectItem:(sscore_item_handle)item_h
{
	[system deselectItem:item_h];
	[self setNeedsDisplay];
}
*/

// MKMODSS - fairly extensive changes here, including removal of param list
-(void)updateLayout
{
	CGSize sysBounds = system.bounds;
	CGRect frame = self.frame;
	frame.size = CGSizeMake((sysBounds.width + 2 * margin.width) * zoomScale, (sysBounds.height + 2 * margin.height) * zoomScale);
	self.frame = frame;
	[self setNeedsDisplay];
}

-(void)drawItemOutline:(SSEditItem*)editItem ctx:(CGContextRef)ctx topLeft:(CGPoint)topLeft
				colour:(CGColorRef)colour margin:(CGFloat)outlineMargin linewidth:(CGFloat)lineWidth
{
	CGRect frame = self.frame;
	CGPoint tl = CGPointMake(frame.origin.x + topLeft.x + margin.width, frame.origin.y + topLeft.y + margin.height);
	[system drawItemOutline:editItem withContext:ctx topleft:tl magnification:zoomScale colour:colour margin:outlineMargin linewidth:lineWidth];
}

-(void)drawItemDrag:(SSEditItem*)editItem ctx:(CGContextRef)ctx topLeft:(CGPoint)topLeft dragPos:(CGPoint)dragPos showTargetDashedLine:(bool)showTargetDashedLine
{
	CGRect frame = self.frame;
	CGPoint tl = CGPointMake(frame.origin.x + topLeft.x + margin.width, frame.origin.y + topLeft.y + margin.height);
	[system drawItemDrag:editItem withContext:ctx topleft:tl magnification:zoomScale pos:dragPos drawLineToNearestTarget:showTargetDashedLine];
}

-(SSTargetLocation*)nearestInsertTargetFor:(SSEditType*)editType at:(CGPoint)pos maxDistance:(CGFloat)maxDistance
{
	CGPoint pos_mag = CGPointMake(pos.x / zoomScale, pos.y / zoomScale);
	return [system nearestInsertTargetFor:editType at:pos_mag max:maxDistance];
}

-(SSNoteInsertPos)nearestNoteInsertPos:(CGPoint)pos editType:(SSEditType*)editType maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers
{
	CGPoint pos_mag = CGPointMake(pos.x / zoomScale, pos.y / zoomScale);
	SSTargetLocation *target = [system nearestInsertTargetFor:editType at:pos_mag max:maxDistance];
	if (target)
	{
		SSNoteInsertPos systemInsertPos = [system nearestNoteInsertPos:target type:editType maxLedgers:maxLedgers];
		systemInsertPos.pos = CGPointMake(systemInsertPos.pos.x * zoomScale, systemInsertPos.pos.y * zoomScale);
		return systemInsertPos;
	}
	else
	{
		SSNoteInsertPos systemInsertPos = {0,{0,0},0,0,0,0};
		return systemInsertPos;
	}
}

-(SSNoteInsertPos)nearestNoteReinsertPos:(CGPoint)pos editItem:(SSEditItem* _Nonnull)editItem maxDistance:(CGFloat)maxDistance maxLedgers:(int)maxLedgers
{
	CGPoint pos_mag = CGPointMake(pos.x / zoomScale, pos.y / zoomScale);
	SSTargetLocation *target = [system nearestReinsertTargetFor:editItem at:pos_mag];
	if (target)
	{
		SSNoteInsertPos systemInsertPos = [system nearestNoteReinsertPos:target item:editItem maxLedgers:maxLedgers];
		systemInsertPos.pos = CGPointMake(systemInsertPos.pos.x * zoomScale, systemInsertPos.pos.y * zoomScale);
		return systemInsertPos;
	}
	else
	{
		SSNoteInsertPos systemInsertPos = {0,{0,0},0,0,0,0};
		return systemInsertPos;
	}
}

//@protocol SSViewInterface

// MKMOD - added method systemAtPos   4/1/17
-(SSSystemPoint)systemAtPos:(CGPoint)p
{
	SSSystemPoint rval;
	rval.systemIndex = self.systemIndex;
	if (system)
	{
		CGPoint topleft = self.frame.origin;
		rval.posInSystem = CGPointMake(p.x - margin.width - topleft.x, p.y - margin.height - topleft.y);
		rval.barIndex = [system barIndexForXPos:rval.posInSystem.x];
		rval.partIndex = [system partIndexForYPos:rval.posInSystem.y];
		rval.staffIndex = [system staffIndexForYPos:rval.posInSystem.y];
		rval.staffLocation = [system staffLocationForPos:rval.posInSystem maxLedgers:5].location;
		rval.lineSpaceIndex = [system staffLineSpaceIndexForYPos:rval.posInSystem.y];
	}
	return rval;
}

// MKMOD - added method systemAtIndex   4/1/17
-(SSSystem*)systemAtIndex:(int)index
{
	return system;
}

// MKMOD - added method systemContainingBarIndex   4/1/17
-(SSSystem*)systemContainingBarIndex:(int)barIndex
{
	return system;
}

// MKMOD - added method numSystems   4/1/17
-(int)numSystems
{
	return 1;
}

// MKMOD - added method systemIndex   4/1/17
// the frame of the system within the view
-(CGRect)systemRect:(int)systemIndex
{
	CGSize sysBounds = system.bounds;
	CGPoint topleft = self.frame.origin;
	return CGRectMake(topleft.x+margin.width, topleft.y+margin.height, sysBounds.width, sysBounds.height);
}

// MKMODSS removed these two methods:
// MKMOD - added method componentsAt   4/1/17
/*
-(NSArray<SSComponent*> *)componentsAt:(CGPoint)p maxDistance:(float)maxDistance
{
	return [system closeFeatures:p distance:maxDistance];
}

-(void)deselectAll
{
	[system deselectAll];
	[self setNeedsDisplay];
}
*/

-(void)showVoiceTracks:(bool)show
{
	if (show)
		_drawFlags |= sscore_dopt_showvoicetracks;
	else
		_drawFlags &= ~sscore_dopt_showvoicetracks;
	[self setNeedsDisplay];
}

-(bool)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
{
	return [super pointInside:point withEvent:event];
}

// MKMOD - deleted method updateLayout here  4/1/17
// MKMOD - (actually, gitkraken confused, redefined it above)   4/1/17
//@end

// MKMOD - added method changedThis  4/1/17
// MKMODSS - changed method changedThis to changedBars
static bool changedBars(const sscore_barrange br, sscore_state_container *prevstate, sscore_state_container *newstate)
{
	for (int i = 0 ; i < br.numbars; ++i)
	{
		int barIndex = br.startbarindex + i;
		if (sscore_edit_barChanged(barIndex, prevstate, newstate))
		{
			return true;
		}
	}
	return false;
}

//@protocol ScoreChangeHandler
// MKMOD - added method "change:"  4/1/17
-(void)change:(sscore_state_container *)prevstate newstate:(sscore_state_container *)newstate reason:(int)reason
{
	if (sscore_edit_partCountChanged(prevstate, newstate)
		|| sscore_edit_barCountChanged(prevstate, newstate)
		|| sscore_edit_headerChanged(prevstate, newstate)
		|| sscore_edit_systemBreakChanged(prevstate, newstate))
		return; // if part count or bar count or header changes SSScrollView will create a complete new layout, so we don't do anything here
	bool changed = changedBars(self.system.barRange, prevstate, newstate); // check if change in bar range of this system
	if (changed)
	{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		[system updateLayout:ctx newState:newstate];
		UIGraphicsEndImageContext();
		dispatch_async(dispatch_get_main_queue(), ^{ // main queue for ui calls
			[self updateLayout];
		});
	}	// else nothing changed
}
//@end

@end
