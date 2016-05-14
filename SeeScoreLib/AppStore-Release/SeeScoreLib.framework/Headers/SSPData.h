//
//  SSPData.h
//  SeeScoreLib
//
//  Copyright (c) 2015 Dolphin Computing Ltd. All rights reserved.
//
// No warranty is made as to the suitability of this for any purpose
//

#ifndef SeeScoreLib_mac_SSPData_h
#define SeeScoreLib_mac_SSPData_h

#include "sscore_playdata.h"

/*!
 @header	SSPData.h
 
 @abstract	interface to the SeeScore Play Data
 */

/*! a special value used for the part index for the metronome part
 */
static const int kMetronomePartIndex = -1;

@class SSScore;
@class SSPDSyncTiming;

/*! @protocol SSUTempo
 @abstract allows the UI to define the bpm (if no tempo in the XML) or tempo scaling (relative to bpm defined in the XML)
 */
@protocol SSUTempo <NSObject>

/*!
 @method bpm
 @return the beats-per-minute value (only used if the MusicXML contains no timing info)
 */
-(int)bpm;

/*!
 @method tempoScaling
 @return the scaling for the tempo defined in the MusicXML (1.0 is nominal)
 */
-(float)tempoScaling;

@end

/*!
 @interface SSPDNote
 @abstract play information about a note (ie start time, duration in ms and pitch etc)
 */
@interface SSPDNote : NSObject

/*!
 @property rawnote
 @abstract the sscore_pd_note
 */
@property (readonly) sscore_pd_note rawnote;

/*!
 @property midiPitch
 @abstract the midi pitch value of the note 60 = C4. 0 = unpitched (eg percussion)
 */
@property (readonly) int midiPitch;

/*!
 @property startBarIndex
 @abstract 0-based index of bar in which this note starts (may be tied over bars)
 */
@property (readonly) int startBarIndex;

/*!
 @property start
 @abstract millisecond start time from start of bar
 */
@property (readonly) int start;

/*!
 @property duration
 @abstract total millisecond duration of note may be longer than a bar if tied over barline
 */
@property (readonly) int duration;

/*!
 @property dynamic
 @abstract [0..100] value of the last dynamic
 */
@property (readonly) int dynamic;

/*!
 @property grace
 @abstract set for grace note
 */
@property (readonly) enum sscore_pd_grace_e grace;

/*!
 @property item_h item
 @abstract handle used in sscore_contents
 */
@property (readonly) sscore_item_handle item_h;

/*!
 @property midi_start
 @abstract midi start time (24 ticks per crotchet/quarter note)
 */
@property (readonly) int midi_start;

/*!
 @property midi_duration
 @abstract midi duration (24 ticks per crotchet/quarter note)
 */
@property (readonly) int midi_duration;

/*!
 @property beatIndex
 @abstract beat index for metronome beat (has integer values)
 @discussion for notes this can have a fractional value according to the start time of the note
 */
@property (readonly) float beatIndex;

@end

/*!
 @interface SSPDPart
 @abstract a single part bar containing an array of notes
 */
@interface SSPDPart : NSObject

/*!
 @property keySig
 @abstract the key signature for the bar (+ve is num sharps, -ve is num flats)
 */
@property (readonly) int keySig;

/*!
 @property timeSig
 @abstract the time signature for the bar
 */
@property (readonly) sscore_timesig timeSig;

/*!
 @property notes
 @abstract the notes in the bar for this part
 */
@property (readonly)  NSArray<SSPDNote*> *notes;

@end

/*!
 @interface SSPDBar
 @abstract a multi part bar containing single parts SSPDPart and a metronome SSPDPart
 */
@interface SSPDBar : NSObject

/*!
 @property countInBar
 @abstract return a copy of this bar as a count-in bar (ie with a maximum of 4 beats)
 */
@property (readonly) SSPDBar *countInBar;

/*!
 @property index
 @abstract the bar index [0..number of bars in score-1]
 */
@property (readonly) int index;

/*!
 @property sequenceIndex
 @abstract the index of the bar in the play sequence (accounting for repeats)
 */
@property (readonly) int sequenceIndex;

/*!
 @property isLastInSequence
 @abstract true if this is the last bar in the sequence
 */
@property (readonly) bool isLastInSequence;

/*!
 @property tempoCrotchetBPM
 @abstract crotchet tempo in beats per minute
 */
@property (readonly) int tempoCrotchetBPM;

/*!
 @property metronomeBeatsInBar
 @abstract number of metronome beats in a bar
 */
@property (readonly) int metronomeBeatsInBar;

/*!
 @property duration_ms
 @abstract the bar duration in milliseconds
 */
@property (readonly) int duration_ms;

/*!
 @property metronome
 @abstract get a virtual SSPDPart for the metronome
 This contains 1 note for each metronome beat
 */
@property (readonly) SSPDPart *metronome;

/*!
 @method duration_midi
 @abstract get the bar duration in midi ticks (24 per crotchet)
 @param crotchet_duration midi ticks in crotchet
 @return duration of the current bar in midi ticks
 */
-(int)duration_midi:(int)crotchet_duration;

/*!
 @method part:
 @abstract get the SSPDPart for the 0-based part index
 */
-(SSPDPart*) part:(int)partIndex;

@end


/*!
 @interface BeatTiming
 @abstract define the exact timing of a single beat
 @discussion used to synchronise the play to a performance
 */
@interface BeatTiming : NSObject

/*!
 @property beatIndex
 @abstract the index of the beat in the bar [0..number of beats in bar-1].
 The first beat is 0
 */
@property int beatIndex;

/*!
 @property barPlayIndex
 @abstract the index of the bar containing this beat in play order (first played bar is 0).
 */
@property int barPlayIndex;

/*!
 @property start_ms
 @abstract the start time of the beat in ms from the beginning of the bar.
 */
@property int start_ms;

@end


/*!
 @interface SSPData
 @abstract The play data information about the score required for playing it
 @discussion This can be used to drive a synthesizer (supplied for OS X and iOS only)
 or to generate a MIDI file using createMidiFile:
 */
@interface SSPData : NSObject

/*!
 @property rawplaydata
 @abstract the C play data
 */
@property (readonly) const sscore_playdata *rawplaydata;

/*!
 @property title
 @abstract the title of the score
 */
@property (readonly) NSString *title;

/*!
 @property numParts
 @abstract the number of parts in the score
 */
@property (readonly) int numParts;

/*!
 @property hasFirstBarAnacrusis
 @abstract true if the first bar does not contain the full number of beats
 */
@property (readonly) bool hasFirstBarAnacrusis;

/*!
 @property maxDynamic
 @abstract the maximum dynamic value on any note in the score
 */
@property (readonly) float maxDynamic;

/*!
 @property bars
 @abstract an array of SSPDBar
 */
@property (readonly) NSArray<SSPDBar*> *bars;

/*!
 @property loopBack
 @abstract if this is set we play in an infinite loop over the bars array
 */
@property (readonly) bool loopBack;

/*!
 @method createPlayDataFromScore:
 @abstract create and return the SSPData play data
 @param score the SSScore
 @param tempo an object implementing the SSUTempo protocol allowing the user to set the tempo while playing.
 @return the SSPData
 */
+(SSPData*)createPlayDataFromScore:(SSScore*)score tempo:(id<SSUTempo>)tempo;

/*!
 @method createSingleBarPlayData:
 @abstract create and return the SSPData play data for a single bar and single part only
 @param score the SSScore
 @param partIndex the part index
 @param barIndex the bar index
 @param tempo an object implementing the SSUTempo protocol allowing the user to set the tempo while playing.
 @return the SSPData
 */
+(SSPData*)createSingleBarPlayData:(SSScore*)score part:(int)partIndex bar:(int)barIndex tempo:(id<SSUTempo>)tempo;

/*!
 @method createSingleChordPlayData:
 @abstract create and return the SSPData play data for a single note or chord in the score
 @param score the SSScore
 @param partIndex the part index
 @param barIndex the bar index
 @param tempo an object implementing the SSUTempo protocol allowing the user to set the tempo while playing.
 @return the SSPData
 */
+(SSPData*)createSingleChordPlayData:(SSScore*)score part:(int)partIndex bar:(int)barIndex note:(sscore_item_handle)noteId;

/*!
 @method createPlayDataFromScore:tempo:withTiming:
 @abstract create and return the SSPData play data for synchronising to a defined array of beat timings
 @param score the SSScore
 @param tempo the tempo controller
 @param syncTiming must have size = the number of bars to play
 @return the SSPData
 */
+(SSPData*)createPlayDataFromScore:(SSScore*)score
							 tempo:(id<SSUTempo>)tempo
						withTiming:(SSPDSyncTiming*)syncTiming;

/*!
 @method setLoopStart: loopBackBar: numRepeats:
 @abstract create a play loop between 2 bar indexes
 @discussion licence playloop_capable is required to use this function
 @param startLoopBarIndex the index of the first bar in the loop
 @param loopBackBarIndex the index of the last bar in the loop
 @param numRepeats the number  of repeats (max 10)
 */
-(void)setLoopStart:(int)startLoopBarIndex loopBackBar:(int)loopBackBarIndex numRepeats:(int)numRepeats;

/*!
 @method clearLoop:
 @abstract clear any loop setup by setLoopStart: loopBackBar: numRepeats:
 */
-(void)clearLoop;

/*!
 @method createMidiFile
 @abstract create a MIDI file from this play data with the given full pathname
 @return any error
 */
-(enum sscore_error)createMidiFile:(NSString*)filePath;

/*!
 @method scaleTempoMidiFile
 @abstract write a new tempo value to the MIDI file so it will play at a different speed
 */
-(void)scaleTempoMidiFile:(NSString*)filePath scaling:(float)tempoScaling;

/*!
 @method seqIndexForBar
 @abstract from the current sequence index return the sequence index for the nearest instance of a bar with index barIndex
 If there are no repeats barIndex = seqIndex for all bars so this returns barIndex
 @param barIndex the bar index
 @param seqIndex the current sequence index
 @return the bar sequence index
 */
-(int)seqIndexForBar:(int)barIndex from:(int)seqIndex;

@end

#endif
