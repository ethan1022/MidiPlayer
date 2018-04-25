//
//  ViewController.swift
//  MidiPlayer
//
//  Created by Ethan on 2018/4/20.
//  Copyright © 2018年 EthanLab. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playTimeSlider: UISlider!
    @IBOutlet weak var outputView: UIView!
    var longPressGesture: UILongPressGestureRecognizer!
    
    var collectionDataArray : Array<String> = ["Audio High Pass Filter" , "Audio Low Pass Filter"]
    var midiPlayer : AVMIDIPlayer!
    var playTimer : Timer!
    var destinationUrl : URL?
    
//    let audioEngine = AVAudioEngine()
//    var sampler : AVAudioUnitMIDISynth!
//    let mixer = AVAudioMixerNode()
//    var sequencer : AVAudioSequencer!
//    var isExporting : Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMIDIPlayer()
        self.setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private Methods
    func setupUI() {
        self.playButton.layer.cornerRadius = 7
        self.playButton.layer.borderWidth = 1
        self.playButton.layer.borderColor = UIColor.black.cgColor
        self.playButton.clipsToBounds = true
        
        self.outputView.layer.cornerRadius = 7
        self.outputView.layer.borderWidth = 1
        self.outputView.layer.borderColor = UIColor.black.cgColor
        self.outputView.clipsToBounds = true
        
        self.longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPressGesture(_:)))
        self.collectionView.addGestureRecognizer(self.longPressGesture)
    }
    
    func convertFileWithUrl() {
        
        
    }
    
    func setupMIDIPlayer() {
        if let midiURL = Bundle.main.url(forResource: "examMIDI", withExtension: "mid"),
            let soundFontURL = Bundle.main.url(forResource: "StratocasterLightOverdrive.SF2", withExtension: nil) {
            do {
//                self.sampler = try AVAudioUnitMIDISynth(soundBankURL: soundFontURL)
//                self.audioEngine.attach(self.sampler)
//                let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
//                let mixer = self.audioEngine.mainMixerNode
//                mixer.outputVolume = 1.0
//                self.audioEngine.connect(self.sampler, to: mixer, format: audioFormat)
//                self.sequencer = AVAudioSequencer(audioEngine: self.audioEngine)
//                try self.sequencer.load(from: try Data.init(contentsOf: midiURL), options: [])
                
//                self.audioEngine.connect(self.playerNode, to: mixer, format: mixer.outputFormat(forBus: 0))
//                let file = try AVAudioFile(forReading: midiURL)
//                let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
//                try file.read(into: buffer!)
//                self.playerNode.scheduleBuffer(buffer!) {
//                    self.playerNode.stop()
//                }

                self.midiPlayer = try AVMIDIPlayer.init(contentsOf: midiURL, soundBankURL: soundFontURL)
                self.midiPlayer.prepareToPlay()
                
                self.playTimeSlider.minimumValue = 0.0
                self.playTimeSlider.maximumValue = Float(self.midiPlayer.duration)
                self.playTimeSlider.addTarget(self, action: #selector(changeMIDITimeStamp), for: UIControlEvents.valueChanged)
            }
            catch {
                
                print(error.localizedDescription)
                
            }
        }
    }
    
    
    
    func enablePlayTimer(_ enable:Bool) {
        if enable {
            self.playTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
        else {
            self.playTimer.invalidate()
        }
    }
    
    func tapEffectWithButton(_ button:UIButton, tapped:Bool) {
        if tapped {
            button.alpha = 0.5
        }
        else {
            button.alpha = 1.0
        }
    }
    
//    func startEngine() {
//
//        if self.audioEngine.isRunning {
//            print("audio engine already started")
//            return
//        }
//
//        do {
//            try self.audioEngine.start()
//            print("audio engine started")
//        } catch {
//            print("oops \(error)")
//            print("could not start audio engine")
//        }
//    }
//
    func setSessionPlayback() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
                                         with: AVAudioSessionCategoryOptions.mixWithOthers)
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try audioSession.setActive(true)
        } catch {
            print("couldn't set category \(error)")
        }
    }
    
    func highPassFilterAction() {
        if let midiURL = Bundle.main.url(forResource: "examMIDI", withExtension: "mid") {
            let whiteNoise = AKWhiteNoise(amplitude: 0.1)
            let filteredNoise = AKOperationEffect(whiteNoise) { whiteNoise, _ in
                let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
                return whiteNoise.highPassFilter(halfPowerPoint: halfPower)
            }
            
            do {
                let file = try AKAudioFile(forReading: midiURL)
                let player = try AKAudioPlayer(file: file)
                player.looping = true
                let filteredPlayer = AKOperationEffect(player) { player, _ in
                    let halfPower = AKOperation.sineWave(frequency: 0.2).scale(minimum: 12_000, maximum: 100)
                    return player.highPassFilter(halfPowerPoint: halfPower)
                }
                
                let mixer = AKDryWetMixer(filteredNoise, filteredPlayer, balance: 0.5)
                AudioKit.output = mixer
                
                self.setSessionPlayback()
                try AudioKit.start()
                whiteNoise.start()
                player.play()
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Selector Methods
    @objc func timerAction() {
        self.playTimeSlider.value = Float(self.midiPlayer.currentPosition)
        if self.midiPlayer.currentPosition >= self.midiPlayer.duration {
            self.midiPlayer.stop()
            self.midiPlayer.currentPosition = 0.0
            self.midiPlayer.play()
        }
    }
    
    @objc func changeMIDITimeStamp() {
        let value = self.playTimeSlider.value
        if self.midiPlayer.isPlaying {
            self.midiPlayer.stop()
            self.midiPlayer.currentPosition = Double(value)
            self.midiPlayer.play()
        }
        else {
            self.midiPlayer.currentPosition = Double(value)
        }
    }
    
    @objc func handleLongPressGesture(_ gesture : UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            guard let selectedCell = self.collectionView.indexPathForItem(at: self.longPressGesture.location(in: self.collectionView)) else {return}
            self.collectionView.beginInteractiveMovementForItem(at: selectedCell)
        case .changed:
            self.collectionView.updateInteractiveMovementTargetPosition(self.longPressGesture.location(in: self.collectionView))
        case .ended:
            self.collectionView.endInteractiveMovement()
            
        default:
            self.collectionView.cancelInteractiveMovement()
        }
    }

    //MARK: - On Click Methods
    @IBAction func onClickPlayButton(_ sender: Any) {
//        if self.sequencer.isPlaying {
//            self.sequencer.stop()
//        }
//        else {
//            self.setSessionPlayback()
//            self.startEngine()
//            self.sequencer.prepareToPlay()
//        }
//        if self.playerNode.isPlaying {
//            self.playerNode.stop()
//        }
//        else {
//            self.setSessionPlayback()
//            self.startEngine()
//            self.playerNode.play()
//        }
        if self.midiPlayer.isPlaying {
            self.midiPlayer.stop()
            self.enablePlayTimer(false)
            self.tapEffectWithButton(self.playButton, tapped: false)
        }
        else {
            self.midiPlayer.play()
            self.enablePlayTimer(true)
            self.tapEffectWithButton(self.playButton, tapped: true)
        }
    }
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceData = self.collectionDataArray[sourceIndexPath.row]
        self.collectionDataArray.remove(at: sourceIndexPath.row)
        self.collectionDataArray.insert(sourceData, at: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        switch cell.label.text {
        case "Audio High Pass Filter":
            print("Audio High Pass Filter")
            self.highPassFilterAction()
        case "Audio Low Pass Filter":
            print("Audio Low Pass Filter")
        default:
            print("default")
        }
    }
    
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! CollectionViewCell
        let text : String = self.collectionDataArray[indexPath.row]
        switch text {
        case "Audio High Pass Filter":
            cell.backgroundColor = UIColor.yellow
        case "Audio Low Pass Filter":
            cell.backgroundColor = UIColor.red
        default:
            cell.backgroundColor = UIColor.clear
        }
        cell.label.text = text
        cell.layer.cornerRadius = 7
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        cell.clipsToBounds = true
        
        return cell
    }
}

