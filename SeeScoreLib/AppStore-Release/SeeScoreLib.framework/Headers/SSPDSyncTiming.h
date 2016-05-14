//
//  SSPDSyncTiming.h
//  SeeScoreIOS
//
//  PlayData synchronisation support
//

#ifndef SSPDSyncTiming_h
#define SSPDSyncTiming_h

#import <Foundation/Foundation.h>
#include "sscore_playdata.h"

/*!
 @class SSPDBeatTiming
 @abstract information about the timing of a single beat (except the first beat) in the bar
 @discussion support is included for serialising to and from JSON
 */
@interface SSPDBeatTiming : NSObject
NS_ASSUME_NONNULL_BEGIN

/*!
 @property time_ms
 @abstract time of beat from start of bar (not the first beat which is always at 0)
 */
@property (readonly) int time_ms;

/*!
 @method initWith:
 @abstract initialiser
 @param time_ms the time of the beat from the start of the bar
 */
-(nonnull instancetype)initWith:(int)time_ms;

@end


/*!
 @class SSPDBarTiming
 @abstract timing of beats in a bar
 @discussion All timings are relative to the current bar so it's easy to edit a timing file (remove/add a bar etc)
 */
@interface SSPDBarTiming : NSObject

/*!
 @property barIndex
 @abstract the 0-based index of the bar
 @discussion this is currently only used to report errors
 */
@property (readonly) int barIndex;

/*!
 @property duration_ms
 @abstract the duration of this bar (from 1st beat of this bar to 1st beat of following bar)
 */
@property (readonly) int duration_ms;

/*!
 @property beatTimings
 @abstract array of SSBeatTiming for beats 2..
 @discussion 1st beat is always at start of bar
 */
@property (readonly, nonnull) NSArray<SSPDBeatTiming*> *beatTimings;

/*!
 @property json
 @abstract for JSON serialisation
 */
@property (readonly, nonnull) NSDictionary *json;

/*!
 @method initWith:duration:beats
 @abstract initialiser
 @param barIndex the 0-based bar index
 @param duration_ms the duration of this bar
 @param beatTimings the beat timings for the bar excluding the first beat which is always at the start of the bar
 */
-(nonnull instancetype)initWith:(int)barIndex duration:(int)duration_ms beats:(nonnull NSArray<SSPDBeatTiming*> *)beatTimings;

@end


/*!
 @class SSPDSyncTiming
 @abstract timings of beats in bars for synchronisation support for SSPlayData
 */
@interface SSPDSyncTiming : NSObject

/*!
 @property mediaStart_ms
 @abstract the time at which to start any synchronised media (default = 0)
 */
@property (readonly) int mediaStart_ms;

/*!
 @property bars
 @abstract the array of bar timings
 */
@property (readonly, nonnull) NSArray<SSPDBarTiming*> *bars;

/*!
 @property json
 @abstract for JSON serialisation
 */
@property (readonly, nonnull) NSDictionary *json;

/*!
 @method barFaults
 @abstract check valid timings
 @return array of bar numbers with inconsistent timings
 */
@property (readonly, nonnull) NSArray<NSNumber*> *barFaults;

/*!
 @method initWithBarsArray
 @abstract initialise with array of SSBarTiming
 @param bars the array of bars
 @param mediaStart_ms the delay for media start from start of play of first bar
 @return an object of type SSPDSyncTiming
 */
-(nonnull instancetype)initWithBarsArray:(nonnull NSArray<SSPDBarTiming*> *)bars mediaStart:(int)mediaStart_ms;

/*!
 @method createFromJSON
 @abstract create from a JSON-encoded file
 @param url the URL of a JSON file saved from saveToJSONUrl
 @param error the error if the returned value is nil
 */
+(nullable SSPDSyncTiming*)createFromJSON:(nonnull NSURL *)url error:(NSError**)error;

/*!
 @method saveToJSONUrl
 @abstract save to a JSON file
 @param url the URL of file to save this encoded as JSON
 */
-(bool)saveToJSONUrl:(nonnull NSURL*)url;

/*!
 @method getRawTimingInfo:
 @abstract fill the C timing struct
 @param rval pointer to a C struct sscore_pd_timinginfo
 @return false if failed (rval = nil) 
 */
-(bool)getRawTimingInfo:(nonnull sscore_pd_timinginfo*)rval;

NS_ASSUME_NONNULL_END
@end

#endif /* SSPDSyncTiming_h */
