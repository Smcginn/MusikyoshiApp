//
//  SSChordEditor.h
//  SeeScoreLib
//
//  Created by James Sutton on 29/10/2015.
//  Copyright © 2015 Dolphin Computing Ltd. All rights reserved.
//

#ifndef SSScoreEditor_h
#define SSScoreEditor_h

#import <CoreGraphics/CoreGraphics.h>
#import <SeeScoreLib/SSScore.h>
#import <SeeScoreLib/sscore_cheditor.h>

/*!
 @class SSChordEditor
 @abstract
 @discussion
 */
@interface SSChordEditor : NSObject

/*!
 @property
 @abstract
 */
@property (readonly) sscore_cheditor *raw_scedit;

/*!
 @method init:ctx:magnification:frameLpartIndex:barIndex:item:
 @abstract initialise the Chord Editor
 @param
 @return
 */
-(instancetype)init:(SSScore*)score
				ctx:(CGContextRef)ctx
	  magnification:(float)magnification
			  frame:(CGRect)frame
		  partIndex:(int)partIndex
		   barIndex:(int)barIndex
			   item:(sscore_item_handle)item_h;

/*!
 @method
 @abstract
 @param
 */
-(void)draw:(CGContextRef)ctx;

/*!
 @method
 @abstract
 @param
 @return
 */
-(CGSize)size:(CGContextRef)ctx;

/*!
 @method
 @abstract
 @param
 @return
 */
-(sscore_cheditor_noteid)noteheadId:(CGContextRef)ctx at:(CGPoint)p maxdist:(float)maxDist;

/*!
 @method
 @abstract
 @param
 @return
 */
-(int)pitchAlterForNotehead:(sscore_cheditor_noteid)noteheadId;

/*!
 @method
 @abstract
 @param
 @return
 */
-(CGRect)noteheadBB:(CGContextRef)ctx notehead:(sscore_cheditor_noteid)noteheadId;

/*!
 @method
 @abstract
 @param
 */
-(void)drag:(CGContextRef)ctx notehead:(sscore_cheditor_noteid)noteheadId translate:(CGPoint)translate;

/*!
 @method
 @abstract
 @param
 */
-(void)endDrag:(CGContextRef)ctx notehead:(sscore_cheditor_noteid)noteheadId translate:(CGPoint)translate;

/*!
 @method
 @abstract
 @param
 */
-(void)showAccidental:(CGContextRef)ctx notehead:(sscore_cheditor_noteid)noteheadId alter:(int)accidental_pitch_alter;

/*!
 @method
 @abstract
 @param
 */
-(void)setAccidental:(CGContextRef)ctx notehead:(sscore_cheditor_noteid)noteheadId alter:(int)accidental_pitch_alter;

/*!
 @method
 @abstract
 @param
 */
-(void)showRemoveChordNote:(CGContextRef)ctx notehead:(sscore_cheditor_noteid)noteheadId;

/*!
 @method removeChordNote
 @abstract
 @param
 */
-(void)removeChordNote:(CGContextRef)ctx notehead:(sscore_cheditor_noteid)noteheadId;

/*!
 @method showAddChordNote
 @abstract
 @param
 */
-(void)showAddChordNote:(CGContextRef)ctx at:(CGPoint)p;

/*!
 @method addChordNote
 @abstract
 @param
 */
-(void)addChordNote:(CGContextRef)ctx at:(CGPoint)p;

/*!
 @method cancelOp
 @abstract
 @param
 */
-(void)cancelOp;

@end

#endif /* SSScoreEditor_h */
