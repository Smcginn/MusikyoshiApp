//
//  Intonation.swift
//  SeeScoreIOS
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//

import Foundation

class Intonation : NSObject, SSFrequencyConverter
{
	enum Temperament {
		case Equal
		case Just
	}
	
	static let A4_freq = 440.0 // Hz
	static let A4_MIDI = 69
	static let A5_MIDI = 81

	// Just Intonation uses integer ratios for all intervals
	// Using figures from http://www.shawnboucke.com/blog/intonation-is-subjective
	static let kJustLookup : [Int : Double] = [
		69: 1.0,
		70: 16.0/15.0,
		71: 9.0/8.0,
		72: 6.0/5.0,
		73: 5.0/4.0,
		74: 4.0/3.0,
		75: 7.0/5.0,
		76: 3.0/2.0,
		77: 8.0/5.0,
		78: 5.0/3.0,
		79: 16.0/9.0,
		80: 15.0/8.0
	]
	
	public var temperament : Temperament

	init(temperament : Temperament)
	{
		self.temperament = temperament
		super.init()
	}
	
	// convert midi pitch to frequency using equal temperament
	func equalTemperedFrequency(_ midiPitch : Int32) -> Float
	{
		var octave = 0
		var scalePitch = Int(midiPitch)
		// move octave to get in range A4..G5s
		while scalePitch < Intonation.A4_MIDI
		{
			scalePitch += 12
			octave += 1
		}
		while scalePitch >= Intonation.A5_MIDI
		{
			scalePitch -= 12
			octave -= 1
		}
		assert(scalePitch >= Intonation.A4_MIDI && scalePitch < Intonation.A5_MIDI)
		let semitones = scalePitch - Intonation.A4_MIDI
		var freq = Intonation.A4_freq * pow(2.0, Double(semitones) / 12.0)
		while octave > 0
		{
			freq /= 2.0
			octave -= 1
		}
		while octave < 0
		{
			freq *= 2.0
			octave += 1
		}
		return Float(freq)
	}

	// convert midi pitch to frequency using just intonation
	func justFrequency(_ midiPitch : Int32) -> Float
	{
		var octave = 0
		var scalePitch = Int(midiPitch)
		// move octave to get in range A4..G5s
		while scalePitch < Intonation.A4_MIDI
		{
			scalePitch += 12
			octave += 1
		}
		while scalePitch >= Intonation.A5_MIDI
		{
			scalePitch -= 12
			octave -= 1
		}
		assert(scalePitch >= Intonation.A4_MIDI && scalePitch < Intonation.A5_MIDI)
		if let ratio = Intonation.kJustLookup[scalePitch]
		{
			var freq = Intonation.A4_freq * ratio
			while octave > 0
			{
				freq /= 2.0
				octave -= 1
			}
			while octave < 0
			{
				freq *= 2.0
				octave += 1
			}
			return Float(freq)
		}
		assert(false)
		return Float(Intonation.A4_freq)
	}
	
	func frequency(_ midiPitch : Int32) -> Float
	{
		switch temperament
		{
		case .Equal : return equalTemperedFrequency(midiPitch)
		case .Just : return justFrequency(midiPitch)
		}
	}
}
