//
//  PlaybackInstrumentViewController.swift
//  FirstStage
//
//  Created by Scott Freshour on 12/31/18.
//  Copyright © 2018 Musikyoshi. All rights reserved.
//
//    Base class for LongTonesVC and TuneExerciseVC.
//
//    Implements the Sampled Instrument object needed for "Play this for me"
//    functionality, and all the protocols needed to support this.
//
//    All of this was originally in TuneExerciseVC, then copied to LongTonesVC,
//    and now refactored to this base class.
//

import Foundation

let kTuneExerciseVC = 0
let kLongTonesVC    = 1

class PlaybackInstrumentViewController: UIViewController, SSSyControls,  SSSynthParameterControls, SSFrequencyConverter {
    
    // For LongTonesVC:    set true (always)
    // For TuneExerciseVC: set true for "Play For Me", false for "Listening"
    var playingSynth = false

    var whichVC = kTuneExerciseVC
    
    
    // Metronome support
    var metronomeOn = false
    
    ///////////////////////////////////////////////
    // New SF
    var sampledInstrumentIds = [UInt]()
    var synthesizedInstrumentIds = [UInt]()
    var metronomeInstrumentIds = [UInt]()
    static let kMaxInstruments = 10
    private var synthVoice = SSSynthVoice.Sampled
    private static  let kDefaultRiseFallSamples = 4
    private var waveformSymmetryValue = Float(0.5)
    private var waveformRiseFallValue = kDefaultRiseFallSamples // samples in rise/fall of square
    
    var synth: SSSynth?
    var partIndex: Int32 = 0    // needed in LTVC
    
    //////////////////////////////////////////////////////////////////////
    // MARK:- SSSynthParameterControls Protocol Methods
    
    func waveform() -> sscore_sy_synthesizedinstrument_waveform
    {
        switch synthVoice
        {
        case .Sine : return sscore_sy_sine
        case .Square : return sscore_sy_square
        case .Triangle : return sscore_sy_triangle
        default: return sscore_sy_sine
        }
    }
    
    func waveformSymmetry() -> Float
    {
        return waveformSymmetryValue
    }
    
    public func waveformRiseFall() -> Int32 {
        return Int32(waveformRiseFallValue)
    }
    
    // IMPORTANT: These SampledInstrumentsInfos are appended (with the exception
    //            of Piano) in the order of the defined kInst_nnn defs.
    // Don't stray from this, either here or by altering kInst_nnn defs order.
    var kSampledInstrumentsInfo : [SSSampledInstrumentInfo] {
        get {
            var rval = [SSSampledInstrumentInfo]()
            rval.append(SSSampledInstrumentInfo(
                "Trumpet",
                base_filename: "Trumpet.novib.mf",
                extension: "m4a",
                base_midipitch: 52,
                numfiles: 35,
                volume: Float(1.0),
                attack_time_ms: 2,
                decay_time_ms: 10,
                overlap_time_ms: 1,
                alternativenames: "trumpet",
                pitch_offset: 0,
                family: sscore_sy_instrumentfamily_brass,
                flags: 0,
                samplesflags: 0))
            rval.append(SSSampledInstrumentInfo(
                "Trombone",
                base_filename: "TenorTrombone",
                extension: "m4a",
                base_midipitch: 39,
                numfiles: 34,
                volume: Float(1.0),
                attack_time_ms: 2,
                decay_time_ms: 10,
                overlap_time_ms: 1,
                alternativenames: "trombone",
                pitch_offset: 0,
                family: sscore_sy_instrumentfamily_brass,
                flags: 0,
                samplesflags: 0))
            rval.append(SSSampledInstrumentInfo(
                "Euphonium",
                base_filename: "TenorTrombone",
                extension: "m4a",
                base_midipitch: 39,
                numfiles: 34,
                volume: Float(1.0),
                attack_time_ms: 2,
                decay_time_ms: 10,
                overlap_time_ms: 1,
                alternativenames: "euphonium",
                pitch_offset: 0,
                family: sscore_sy_instrumentfamily_brass,
                flags: 0,
                samplesflags: 0))
            rval.append(SSSampledInstrumentInfo(
                "FrenchHorn",
                base_filename: "Horn.mf",
                extension: "m4a",
                base_midipitch: 34,
                numfiles: 44,
                volume: Float(1.0),
                attack_time_ms: 2,
                decay_time_ms: 10,
                overlap_time_ms: 1,
                alternativenames: "frenchhorn",
                pitch_offset: 0,
                family: sscore_sy_instrumentfamily_brass,
                flags: 0,
                samplesflags: 0))
            rval.append(SSSampledInstrumentInfo(
                "Tuba",
                base_filename: "tuba",
                extension: "mp3",
                base_midipitch: 27,
                numfiles: 39,
                volume: Float(1.0),
                attack_time_ms: 2,
                decay_time_ms: 10,
                overlap_time_ms: 1,
                alternativenames: "tuba",
                pitch_offset: 0,
                family: sscore_sy_instrumentfamily_brass,
                flags: 0,
                samplesflags: 0))
            
            rval.append(SSSampledInstrumentInfo("Piano", base_filename: "Piano.mf", extension: "m4a", base_midipitch: 23, numfiles: 86, volume: Float(1.0), attack_time_ms: 4, decay_time_ms: 10, overlap_time_ms: 10, alternativenames: "piano,pianoforte,klavier", pitch_offset: 0, family: sscore_sy_instrumentfamily_hammeredstring, flags: 0, samplesflags: 0))
            //rval.append(SSSampledInstrumentInfo("MidiPercussion", base_filename: "Drum", extension: "mp3", base_midipitch: 35, numfiles: 47, volume: Float(1.0), attack_time_ms: 4, decay_time_ms: 10, overlap_time_ms: 10, alternativenames: "percussion,MidiPercussion", pitch_offset: 0, family: sscore_sy_instrumentfamily_midi_percussion, flags: sscore_sy_suppressrmscompensation_flag, samplesflags: 0))
            return rval
        }
    }
    
    var kSynthesizedInstrumentsInfo : [SSSynthesizedInstrumentInfo] {
        get {
            var rval = [SSSynthesizedInstrumentInfo]()
            rval.append(SSSynthesizedInstrumentInfo("Tick", volume: Float(1.0), type:sscore_sy_tick1, attack_time_ms:4, decay_time_ms:20, flags:0, frequencyConv: nil, parameters: nil))
            rval.append(SSSynthesizedInstrumentInfo("Waveform", volume: Float(1.0), type:sscore_sy_pitched_waveform_instrument, attack_time_ms:4, decay_time_ms:20, flags:0, frequencyConv: self, parameters: self))
            return rval
        }
    }

    //////////////////////////////////////////////////////////////////////
    // MARK:- SSSyControls Protocol Methods
    func partEnabled(_ partIndex: Int32) -> Bool {
        return partIndex == self.partIndex
    }
    
    func partInstrument(_ partIndex: Int32) -> UInt32 {
        if synthVoice == SSSynthVoice.Sampled {
            return UInt32(instrumentForPart(partIndex : Int(partIndex)))
        } else if !synthesizedInstrumentIds.isEmpty {
            return UInt32(synthesizedInstrumentIds[0])
        }
        
        return 0 // instrumentId
    }
    
    func instrumentForPart(partIndex : Int) -> UInt
    {
        guard !sampledInstrumentIds.isEmpty else { return 0 }
        var index = 0

        if whichVC == kTuneExerciseVC {
            if getCurrentStudentInstrument() == kInst_Trumpet &&
               sampledInstrumentIds.count > 0 {
                index = kInst_Trumpet
            } else if sampledInstrumentIds.count >= kInst_Piano+1 {
                index  = kInst_Piano
            }
        } else {  // whichVC == kLongTonesVC
            if sampledInstrumentIds.count > 1 {
                let currInstIdx = getCurrentStudentInstrument()
                if currInstIdx >= 0 && currInstIdx < sampledInstrumentIds.count {
                    // index = UserDefaults.standard.bool(forKey: Constants.Settings.PlayTrumpet) ? 1 : 0
                    index = currInstIdx
                }
            }
        }
        
        return sampledInstrumentIds[index]
    }
    
    func partVolume(_ partIndex: Int32) -> Float {
        if playingSynth {
            return 1.0
        } else {
            return 0.0
        }
        // return 1.0
    }
    
    func metronomeEnabled() -> Bool {
        return metronomeOn
    }
    
    func metronomeInstrument() -> UInt32 {
        if !metronomeOn {
            return 0
        }
        
        if metronomeInstrumentIds.isEmpty {
            return 0
        }
        
        return  UInt32(metronomeInstrumentIds[0])
    }
    
    func metronomeVolume() -> Float {
        if !metronomeOn {
            return 0
        } else {
            return 1.5
        }
    }
    
    //@end

    
    //////////////////////////////////////////////////////////////////////
    // MARK:- SSFrequencyConverter Protocol Methods
    public func frequency(_ midiPitch: Int32) -> Float {
        return intonation.frequency(midiPitch)
    }
    
    private let intonation = Intonation(temperament: Intonation.Temperament.Equal)

}
