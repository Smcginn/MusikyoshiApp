//
//  sscore_sym.h
//  SeeScoreLib
//
//  Created by James Sutton on 01/11/2015.
//  Copyright © 2015 Dolphin Computing Ltd. All rights reserved.
//
// No warranty is made as to the suitability of this for any purpose

#ifndef sscore_sym_h
#define sscore_sym_h

#include "sscore.h"

#ifdef __cplusplus
extern "C" {
#endif

	/*! @header
	 The C interface to measure and draw the SeeScoreLib built-in symbols
	 */
	
	/*!
	 @typedef sscore_symbol
	 @abstract a symbol to draw
	 */
	typedef unsigned sscore_symbol;
	
	/*!
	 @define sscore_sym_invalid
	 @abstract an invalid value for sscore_symbol
	 */
#define sscore_sym_invalid 0
	
	/*!
	 @function sscore_sym_bb
	 @abstract get the default bounding box of a symbol
	 @param graphics the graphics context
	 @param symbol the symbol
	 @return the bounding box of the symbol
	 */
	EXPORT sscore_rect sscore_sym_bb(sscore_graphics *graphics, sscore_symbol symbol);
	
	/*!
	 @function sscore_sym_draw
	 @abstract draw a symbol
	 @param graphics the graphics context
	 @param symbol the symbol
	 @param origin the position at which to draw the origin of the symbol
	 @param width the width to draw the symbol
	 @param height the height to draw the symbol or 0 to use default aspect
	 @param colour the colour to draw the symbol
	 */
	EXPORT void sscore_sym_draw(sscore_graphics *graphics,
								sscore_symbol symbol,
								const sscore_point *origin,
								float width, float height,
								const sscore_colour_alpha *colour);
	
#ifdef __cplusplus
}
#endif

#endif /* sscore_sym_h */
