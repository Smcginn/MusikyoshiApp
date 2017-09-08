//
//  sampledInstruments.h
//  FirstStage
//
//  Created by David S Reich on 13/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

#ifndef sampledInstruments_h
#define sampledInstruments_h

//extern const sscore_sy_sampledinstrumentinfo kSampledInstrumentsInfo[];
//
//extern const int kNumSampledInstruments;
//extern const sscore_sy_sampledinstrumentinfo *pianoSampleInfo;
////extern const sscore_sy_sampledinstrumentinfo *trumpetSampleInfo;
////extern const sscore_sy_sampledinstrumentinfo *trumpetMinus2SampleInfo;

#import <SeeScoreLib/SeeScoreLib.h>

extern const int kNumSampledInstruments;
extern int getNumSampledInstruments();
extern sscore_sy_sampledinstrumentinfo getSampledInstrumentInfoForIndex(int index);

extern const int kNumSynthesizedInstruments;
extern sscore_sy_synthesizedinstrumentinfo getSynthesizedInstrumentInfoForIndex(int index);

#endif /* sampledInstruments_h */
