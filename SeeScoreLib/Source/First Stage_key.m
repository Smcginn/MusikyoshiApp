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
// licence keys: draw, contents, play_data, synth, ios, id1
static const sscore_libkeytype skey = {"First Stage", {0X21225,0X0}, {0X403a7a7a,0X3f3f0087,0X8077d232,0X413bbf81,0X3999cf9c,0X36d6f592,0X210d284f,0X66d16b7c,0X37d54cec,0X3ee7cea0,0X64ae8aa3,0Xa9a0fb05,0X7f1006f8,0X7539c4f3,0Xbb06079c}};

// licence keys: contents, transpose, item_colour, multipart, ios, osx
//static const sscore_libkeytype skey = {"evaluation", {0X3494,0X0}, {0X41a8d1dd,0X326a25d8,0X6a66f439,0X56daa1c3,0X2bb235c1,0X1af29574,0X40e72850,0X807bd7a,0X2d66e3c5,0X342898b4,0X55416c2c,0Xe1913f9c,0X3a24e86e,0X4d17ab94,0X1eb7ca0e}};

const sscore_libkeytype *const sscore_libkey = &skey;
