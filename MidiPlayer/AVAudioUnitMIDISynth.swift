//
//  AVAudioUnitMIDISynth.swift
//  MidiPlayer
//
//  Created by Ethan on 2018/4/25.
//  Copyright © 2018年 EthanLab. All rights reserved.
//

import Foundation
import AVFoundation

enum MyError: Error {
    case runtimeError(String)
}

class AVAudioUnitMIDISynth: AVAudioUnitMIDIInstrument {
    
    init(soundBankURL: URL) throws {
        let description = AudioComponentDescription(
            componentType: kAudioUnitType_MusicDevice,
            componentSubType: kAudioUnitSubType_MIDISynth,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0)
        
        super.init(audioComponentDescription: description)
        
        var bankURL = soundBankURL
        
        let status = AudioUnitSetProperty(
            self.audioUnit,
            AudioUnitPropertyID(kMusicDeviceProperty_SoundBankURL),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &bankURL,
            UInt32(MemoryLayout<URL>.size))
        
        if status != OSStatus(noErr) {
            throw MyError.runtimeError("\(status)")
        }
    }
    
    func setPreload(enabled: Bool) throws {
        guard let engine = self.engine else {
            throw MyError.runtimeError("Synth must be connected to an engine.")
        }
        if !engine.isRunning {
            throw MyError.runtimeError("Engine must be running.")
        }
        
        var enabledBit = enabled ? UInt32(1) : UInt32(0)
        
        let status = AudioUnitSetProperty(
            self.audioUnit,
            AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &enabledBit,
            UInt32(MemoryLayout<UInt32>.size))
        if status != noErr {
            throw MyError.runtimeError("\(status)")
        }
    }
}
