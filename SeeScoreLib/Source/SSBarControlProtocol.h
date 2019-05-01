//
//  SSBarControlProtocol.h
//  SeeScoreIOS
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//

#import <Foundation/Foundation.h>

@protocol SSBarControlProtocol <NSObject>

// get the total number of bars
- (int)totalBars;

// get the start and number of bars displayed
- (int)startBarDisplayed;
- (int)numBarsDisplayed;

// the number of bars of the score laid out
- (int)numBarsLoaded;

// Called when the BarControl cursorIndex is changed
- (void)cursorChanged:(int)cursorIndex;

@end
