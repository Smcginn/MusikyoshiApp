//
//  sampledInstruments.m
//  FirstStage
//
//  Created by David S Reich on 13/05/2016.
//  Copyright © 2016 Musikyoshi. All rights reserved.
//

#include <SeeScoreLib/sscore_synth.h>

const sscore_sy_sampledinstrumentinfo kSampledInstrumentsInfo[] = {
    //	name,		baseFile,	extn,	lowestMidi, numFiles,	volume, attack_ms, decay_ms, overlap_ms, names,							pitch_offset, instrument family,					flags, extrasamples);
    {"Piano",	"Piano.mf", "m4a",		23,		86,			1.0,	4,			10,			10,			"piano,pianoforte,klavier",				0,	sscore_sy_instrumentfamily_hammeredstring,	0,		0,		{0}},
    //{"Violin",	"violin",	"m4a",		55,		44,			1.0,	150,		600,		480,		"violin,violon,violine,violino,geige",	0,	sscore_sy_instrumentfamily_bowedstring,		0,		0,		{0}},
    //{"Viola",	"viola",	"m4a",		48,		44,			1.0,	100,		600,		480,		"viola,viole,bratsche", 0, sscore_sy_instrumentfamily_bowedstring, 0,0, {0}},
    //{"Cello",	"cello",	"m4a",		36,		48,			1.0,	150,		600,		480,		"cello,\'cello,violoncello,violoncelle", 0, sscore_sy_instrumentfamily_bowedstring, 0,0, {0}},
    //{"Flute",	"Flute.nonvib.mf", "m4a",	59, 38,			1.0,	80,			200,		20,			"flute,flauto", 0, sscore_sy_instrumentfamily_woodwind, 0,0,  {0}},
    //{"Guitar", "guitar",	"m4a",		48,		24,			1.0,	4,			200,		10,			"guitar,guitare,gitarre,chitarra", 0, sscore_sy_instrumentfamily_pluckedstring, 0,0, {0}}
    {"Trumpet", "Trumpet.novib.mf",	"m4a",		52,		35,			1.0,	4,			20,		10,			"trumpet", 0, sscore_sy_instrumentfamily_brass, 0,0, {0}}
//    {"Trumpet", "Trumpet.novib.mf",	"m4a",		52,		35,			1.0,	4,			200,		10,			"trumpet", 0, sscore_sy_instrumentfamily_brass, 0,0, {0}}
};
const int kNumSampledInstruments = sizeof(kSampledInstrumentsInfo)/sizeof(*kSampledInstrumentsInfo);
const sscore_sy_sampledinstrumentinfo *pianoSampleInfo = &kSampledInstrumentsInfo[0];
const sscore_sy_sampledinstrumentinfo *trumpetSampleInfo = &kSampledInstrumentsInfo[1];

