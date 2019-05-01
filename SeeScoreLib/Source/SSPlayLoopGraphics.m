//
//  SSPlayLoopGraphics.m
//  SeeScoreiOS Sample App
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//

#import <Foundation/Foundation.h>
#import "SSPlayLoopGraphics.h"

@implementation SSPlayLoopGraphics
{
	CAShapeLayer *backgroundLayer;
	CAShapeLayer *foregroundLayer;
}

-(instancetype)initWithNumParts:(int)numParts
					 leftSystem:(SSSystem*)leftSystem leftSystemTopLeft:(CGPoint)leftSystemTopLeft leftBarIndex:(int)leftBarIndex
					rightSystem:(SSSystem*)rightSystem rightSystemTopLeft:(CGPoint)rightSystemTopLeft rightBarIndex:(int)rightBarIndex
						   zoom:(float)zoom
						 colour:(UIColor*)colour
{
	if (self = [super init])
	{
		UIBezierPath *path = UIBezierPath.bezierPath;
		UIBezierPath *backgroundPath = UIBezierPath.bezierPath;
		if (leftSystem != nil && leftBarIndex >= 0)
		{
			[path appendPath:[self pathForRepeatBarlinesForSystem:leftSystem numParts:numParts
													systemTopLeft:leftSystemTopLeft barIndex:leftBarIndex loc:sscore_bl_left  zoom:zoom background:false]];
			[backgroundPath appendPath:[self pathForRepeatBarlinesForSystem:leftSystem numParts:numParts
															  systemTopLeft:leftSystemTopLeft barIndex:leftBarIndex loc:sscore_bl_left  zoom:zoom background:true]];
		}
		if (rightSystem != nil && rightBarIndex >= 0 && rightBarIndex >= leftBarIndex)
		{
			[path appendPath:[self pathForRepeatBarlinesForSystem:rightSystem numParts:numParts
													systemTopLeft:rightSystemTopLeft barIndex:rightBarIndex loc:sscore_bl_right  zoom:zoom background:false]];
			[backgroundPath appendPath:[self pathForRepeatBarlinesForSystem:rightSystem numParts:numParts
															  systemTopLeft:rightSystemTopLeft barIndex:rightBarIndex loc:sscore_bl_right  zoom:zoom background:true]];
		}
		if (!backgroundLayer)
			backgroundLayer = [[CAShapeLayer alloc] init];
		if (!foregroundLayer)
			foregroundLayer = [[CAShapeLayer alloc] init];
		backgroundLayer.path = backgroundPath.CGPath;
		backgroundLayer.opacity = 0.6F;
		backgroundLayer.fillColor = [UIColor whiteColor].CGColor;
		foregroundLayer.path = path.CGPath;
		foregroundLayer.opacity = 1.F;
		foregroundLayer.fillColor = colour.CGColor;
	}
	return self;
}
-(CAShapeLayer *)background
{
	return backgroundLayer;
}
-(CAShapeLayer *)foreground
{
	return foregroundLayer;
}

static const float kThickBarlineThicknessTenths = 5;
static const float kThinBarlineThicknessTenths = 2;
static const float kBarlineSeparationTenths = 3.5;
static const float kRepeatDotsBarlineGap = 4; // gap from barline to repeat dots
static const float kRepeatDotRadius = 2.4F;
static const float kRepeatDotOffset = 5; // from centre of staff
static const float kBarlineBackgroundMargin = 5;

-(UIBezierPath*)pathForRepeatBarline:(SSStaffLayout*)staffLayout systemTop:(float)systemTop systemLeft:(float)systemLeft rect:(CGRect)barlineRect loc:(enum sscore_barlineloc_e)loc zoom:(float)zoom
{
	const float thick = kThickBarlineThicknessTenths * staffLayout.tenthSize;
	const float barlineGap = kBarlineSeparationTenths * staffLayout.tenthSize;
	const float thin = kThinBarlineThicknessTenths * staffLayout.tenthSize;
	const float midBarLine = (barlineRect.origin.x + barlineRect.size.width/2);
	UIBezierPath *path = UIBezierPath.bezierPath;
	CGRect rThick =
	{	{systemLeft + (midBarLine - thick/2) * zoom, // thick barline straddles existing barline
		systemTop + (barlineRect.origin.y) * zoom},
		{thick * zoom, barlineRect.size.height * zoom} };
	[path appendPath:[UIBezierPath bezierPathWithRect:rThick]];
	float thinLeft = (loc == sscore_bl_left) ? rThick.origin.x + thick + barlineGap * zoom : rThick.origin.x - (barlineGap + thin) * zoom;
	CGRect rThin =
	{	{thinLeft, rThick.origin.y},
		{thin * zoom, barlineRect.size.height * zoom} };
	[path appendPath:[UIBezierPath bezierPathWithRect:rThin]];
	const float dotRadius = kRepeatDotRadius * staffLayout.tenthSize * zoom;
	const float dotGap = kRepeatDotsBarlineGap * staffLayout.tenthSize * zoom;
	float dotLeft = (loc == sscore_bl_left)	? thinLeft + thin + dotGap : thinLeft - dotGap - 2*dotRadius;
	// add 2 dots
	for (SSStaff *staff in staffLayout.staves)
	{
		float centreStaffy = systemTop + (staff.staffRect.origin.y + staff.staffRect.size.height/2) * zoom;
		float dot1Top = centreStaffy - (kRepeatDotOffset * staffLayout.tenthSize) * zoom - dotRadius;
		float dot2Top = centreStaffy + (kRepeatDotOffset * staffLayout.tenthSize) * zoom - dotRadius;
		if (dot2Top < systemTop + (barlineRect.origin.y + barlineRect.size.height) * zoom) // don't draw the dots if the barline is truncated in y
		{
			[path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(dotLeft, dot1Top, dotRadius*2, dotRadius*2)]];
			[path appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(dotLeft, dot2Top, dotRadius*2, dotRadius*2)]];
		}
	}
	return path;
}

-(UIBezierPath*)backgroundPathForRepeatBarline:(SSStaffLayout*)staffLayout systemTop:(float)systemTop systemLeft:(float)systemLeft rect:(CGRect)barlineRect loc:(enum sscore_barlineloc_e)loc margin:(float)marginTenths zoom:(float)zoom
{
	const float width = (kThickBarlineThicknessTenths + kBarlineSeparationTenths + kThinBarlineThicknessTenths + kRepeatDotsBarlineGap + 2*kRepeatDotRadius + 2*marginTenths) * staffLayout.tenthSize;
	const float thickBarlineThickness = kThickBarlineThicknessTenths * staffLayout.tenthSize;
	const float backgroundMargin = marginTenths * staffLayout.tenthSize;
	UIBezierPath *path = UIBezierPath.bezierPath;
	CGRect rect = CGRectMake(barlineRect.origin.x * zoom, systemTop + (barlineRect.origin.y - backgroundMargin) * zoom, width * zoom, (barlineRect.size.height + 2* backgroundMargin) * zoom);
	if (loc == sscore_bl_left)
		rect.origin.x += systemLeft + ( -thickBarlineThickness/2 + backgroundMargin) * zoom;
	else
		rect.origin.x += systemLeft + ( -width + backgroundMargin + thickBarlineThickness/2) * zoom;
	[path appendPath:[UIBezierPath bezierPathWithRect:rect]];
	return path;
}

-(UIBezierPath*)pathForRepeatBarlinesForSystem:(SSSystem*)system numParts:(int)numParts systemTopLeft:(CGPoint)systemTopLeft barIndex:(int)barIndex loc:(enum sscore_barlineloc_e)loc zoom:(float)zoom background:(bool)background
{
	UIBezierPath *path = UIBezierPath.bezierPath;
	for (int partIndex = 0; partIndex < numParts; ++partIndex)
	{
		SSStaffLayout *staffLayout = [system staffLayout:partIndex];
		SSBarLayout *barLayout = [system barLayout:partIndex];
		for (SSBarline *barline in barLayout.barlines)
		{
			if  ( (barline.barIndex == barIndex && barline.loc == loc)
				 || (loc == sscore_bl_right && barline.barIndex == barIndex+1 && barline.loc == sscore_bl_left)) // use a left barline of the following bar in place of a right barline
			{
				if (background)
					[path appendPath:[self backgroundPathForRepeatBarline:staffLayout systemTop:systemTopLeft.y systemLeft:systemTopLeft.x rect:barline.rect loc:loc margin:kBarlineBackgroundMargin zoom:zoom]];
				else
					[path appendPath:[self pathForRepeatBarline:staffLayout systemTop:systemTopLeft.y systemLeft:systemTopLeft.x rect:barline.rect loc:loc zoom:zoom]];
				break;
			}
		}
	}
	return path;
}

/*-(void)clear
{
	if (backgroundLayer)
		[backgroundLayer removeFromSuperlayer];
	if (foregroundLayer)
		[foregroundLayer removeFromSuperlayer];
	backgroundLayer = foregroundLayer = nil;
	if (containerView)
		[containerView setNeedsDisplay];
}*/
@end
