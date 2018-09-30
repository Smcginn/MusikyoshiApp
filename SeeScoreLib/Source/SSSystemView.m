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
	//self.borderColor = [UIColor rColor].CGColor;
    self.borderColor = [UIColor redColor].CGColor;    // CursorColor, CursorColour
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
	float zoom; // normally 1 except while pinch-zooming
	bool isZooming;
	CursorLayer *cursorLayer;
	sscore_changeHandler_id changeHandlerId;
	CGPoint topLeft;
	CGSize margin;
	CGRect ensureVisibleRect;
	CGPoint normalCentre;
}
@end
	
@implementation SSSystemView

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		score = nil;
		system = nil;
		self.backgroundColor = [[UIColor alloc] initWithRed:kDefaultBackgroundColour.r green:kDefaultBackgroundColour.g blue:kDefaultBackgroundColour.b alpha:kDefaultBackgroundColour.a] ;
		zoom = 1.0;
		isZooming = false;
		cursorLayer = [[CursorLayer alloc] init];
		[self.layer addSublayer:cursorLayer];
		changeHandlerId = 0;
	}
	return self;
}

-(id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		score = nil;
		system = nil;
		self.backgroundColor = [[UIColor alloc] initWithRed:kDefaultBackgroundColour.r green:kDefaultBackgroundColour.g blue:kDefaultBackgroundColour.b alpha:kDefaultBackgroundColour.a] ;
		zoom = 1.0;
		isZooming = false;
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
		zoom = 1.0;
		isZooming = false;
		cursorLayer = [[CursorLayer alloc] init];
		[self.layer addSublayer:cursorLayer];
		changeHandlerId = 0;
	}
    return self;
}

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
	return system.magnification;
}

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

-(void)setSystem:(SSSystem*)sys
		   score:(SSScore*)sc
		 topLeft:(CGPoint)tl
		  margin:(CGSize)marg
{
	assert(sys && sc);
	if (score && changeHandlerId != 0)
	{
		[score removeChangeHandler:changeHandlerId];
		changeHandlerId = 0;
	}
	score = sc;
	system = sys;
	topLeft = tl;
	margin = marg;
	_colourRender = nil;
	zoom = 1.0F;
	isZooming = false;
	CGSize sysBounds = sys.bounds;
	self.frame = CGRectMake(topLeft.x,topLeft.y, sysBounds.width + 2 * margin.width, sysBounds.height + 2 * margin.height);
	//_upperMargin = (frame.size.height - self.systemHeight) / 2;
	[self hideCursor];
	[self setNeedsDisplay];
	changeHandlerId = [score addChangeHandler:self];
}

-(void)clear
{
	if (score && changeHandlerId != 0)
	{
		[score removeChangeHandler:changeHandlerId];
		changeHandlerId = 0;
	}
	score = nil;
	system = nil;
	self.colourRender = nil;
}

-(float)systemHeight
{
	return system ? system.bounds.height : 0;
}

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
	// careful to optimise to detect minimum changes as this minimises the area to redraw and has a significant impact on the speed
	NSArray<SSColouredItem*> *changedColourings = [self changedColouringFrom:_colourRender to:render];
	if (changedColourings.count > 0)
	{
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

-(SSCursorRect)cursorRectForBar:(int)barIndex
{
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	SSCursorRect cursorRect = [system cursorRectForBar:barIndex context:ctx];
	UIGraphicsEndImageContext();
	cursorRect.rect.origin.x += margin.width;
	cursorRect.rect.origin.y += margin.height;
	return cursorRect;
}

-(void)showCursorAtBar:(int)barIndex pre:(BOOL)pre
{
	if (score && system) // it may have been recycled on another thread (shouldn't happen?)
	{
		SSCursorRect cursorRect = [self cursorRectForBar:barIndex];
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
		SSCursorRect cursorRect = [self cursorRectForBar:barIndex];
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

-(void)setCursorColour:(UIColor*)colour
{
	[cursorLayer setColour:colour];
}

-(void)zoomUpdate:(float)z
{
	zoom = z;
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

-(void)drawInContext:(CGContextRef)ctx
{
	assert(ctx && system);
	CGPoint tl = CGPointMake(margin.width, margin.height);
	// draw system
	if (_colourRender)
		[system drawWithContext:ctx at:tl magnification:zoom colourRender:_colourRender];
	else
		[system drawWithContext:ctx at:tl magnification:zoom];
}

- (void)drawRect:(CGRect)rect
{
	//[super drawRect:rect];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	// we need to clear the background even when we draw the background image which should fill the frame
	// otherwise we get an intermittent faint horizontal line artifact between systems esp with retina display
	CGContextSetFillColorWithColor (ctx, self.backgroundColor.CGColor);
	CGContextFillRect (ctx, rect);
	if (system)
	{
		[self drawInContext:ctx];
	}
#ifdef DrawOutline
	CGContextSetStrokeColorWithColor (ctx, UIColor.blueColor.CGColor);
	CGContextStrokeRect(ctx, rect);
#endif
}

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

-(void)updateLayout:(CGContextRef)ctx newState:(const sscore_state_container *)newstate
{
	[system updateLayout:ctx newState:newstate];
	CGSize sysBounds = system.bounds;
	self.frame = CGRectMake(topLeft.x,topLeft.y, sysBounds.width + 2 * margin.width, sysBounds.height + 2 * margin.height);
	[self setNeedsDisplay];
}

//@protocol SSViewInterface

-(SSSystemPoint)systemAtPos:(CGPoint)p
{
	SSSystemPoint rval;
	rval.systemIndex = self.systemIndex;
	if (system)
	{
		rval.posInSystem = CGPointMake(p.x - margin.width - topLeft.x, p.y - margin.height - topLeft.y);
		rval.barIndex = [system barIndexForXPos:rval.posInSystem.x];
		rval.partIndex = [system partIndexForYPos:rval.posInSystem.y];
		rval.staffIndex = [system staffIndexForYPos:rval.posInSystem.y];
		rval.staffLocation = [system staffLocationForYPos:rval.posInSystem.y];
	}
	return rval;
}

-(SSSystem*)systemAtIndex:(int)index
{
	return system;
}

-(SSSystem*)systemContainingBarIndex:(int)barIndex
{
	return system;
}

-(int)numSystems
{
	return 1;
}

// the frame of the system within the view
-(CGRect)systemRect:(int)systemIndex
{
	CGSize sysBounds = system.bounds;
	return CGRectMake(topLeft.x+margin.width, topLeft.y+margin.height, sysBounds.width, sysBounds.height);
}

-(NSArray<SSComponent*> *)componentsAt:(CGPoint)p maxDistance:(float)maxDistance
{
	return [system closeFeatures:p distance:maxDistance];
}

-(void)deselectAll
{
	[system deselectAll];
	[self setNeedsDisplay];
}

//@end

static bool changedThis(const sscore_barrange br, sscore_state_container *prevstate, sscore_state_container *newstate)
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
-(void)change:(sscore_state_container *)prevstate newstate:(sscore_state_container *)newstate reason:(int)reason
{
	bool changed = changedThis(self.system.barRange, prevstate, newstate);
	if (changed)
	{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(10,10), YES/*opaque*/, 0.0/* scale*/);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		[self updateLayout:ctx newState:newstate];
		UIGraphicsEndImageContext();
	}	// else nothing changed
}
//@end

@end
