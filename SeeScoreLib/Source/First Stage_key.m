/**
 * SeeScore For iOS and OS X
 * Dolphin Computing http://www.dolphin-com.co.uk
 */

/* SeeScoreLib Key for First Stage

 IMPORTANT! This file is for First Stage only.
 It must be used only for the application for which it is licensed,
 and must not be released to any other individual or company.

 Please keep it safe, and make sure you don't post it online or email it.
 Keep it in a separate folder from your source code, so that when you backup the code
 or store it in a source management system, the key is not included.
 */

#include "SeeScoreLib/sscore.h"

// // TRANTRANTRAN
// New key, as of 12/4/18:    (now includes transpose)
// licence keys: draw, contents, transpose, play_data, synth, ios, id1, embed_id
//static const sscore_libkeytype skey = {"PlayTunes", {0Xa1235,0X0}, {0X69ce74c7,0X7154eb15,0Xc1aa6527,0X7e15e9d3,0X50aa5c50,0Xf4f13dca,0X6092b18f,0X3ec754d1,0X5c0618a6,0X1091858a,0X41d62f85,0X9151034c,0X54c9e687,0X133dd48e,0X1f5a9d4b}};


// New key, as of 9/20/18:
// licence keys: draw, contents, play_data, synth, ios, id1, embed_id
static const sscore_libkeytype skey = {"PlayTunes", {0Xa1225,0X0}, {0X3f8f742a,0X631391ff,0Xca155687,0X19d62f2a,0X3cb27ba6,0X355fcc6a,0X69d3ee6b,0X58c9e914,0X45261f36,0X2fe54d96,0X7748cb6a,0X24fdd9dc,0X4c22d954,0X3ea40d9,0Xade51e8b}};


// New key, as of 9/12/18:
// licence keys: draw, contents, play_data, synth, ios, id0, embed_id
//static const sscore_libkeytype skey = {"PlayTunes", {0X91225,0X0}, {0X1e85cd42,0X6266b7b5,0X48db5687,0X45a6fe8b,0X56917b66,0Xd991cc6a,0X693c91f0,0X791598a,0Xfa671f36,0X578d76e7,0X8796499,0X9430d9dc,0X59bb7d27,0X2415b977,0Xb8011e8b}};

// Before 9/18/18, the key was:
// licence keys: draw, contents, play_data, synth, ios, id1
//static const sscore_libkeytype skey = {"First Stage", {0X21225,0X0}, {0X403a7a7a,0X3f3f0087,0X8077d232,0X413bbf81,0X3999cf9c,0X36d6f592,0X210d284f,0X66d16b7c,0X37d54cec,0X3ee7cea0,0X64ae8aa3,0Xa9a0fb05,0X7f1006f8,0X7539c4f3,0Xbb06079c}};

// licence keys: contents, transpose, item_colour, multipart, ios, osx
//static const sscore_libkeytype skey = {"evaluation", {0X3494,0X0}, {0X41a8d1dd,0X326a25d8,0X6a66f439,0X56daa1c3,0X2bb235c1,0X1af29574,0X40e72850,0X807bd7a,0X2d66e3c5,0X342898b4,0X55416c2c,0Xe1913f9c,0X3a24e86e,0X4d17ab94,0X1eb7ca0e}};

const sscore_libkeytype *const sscore_libkey = &skey;
