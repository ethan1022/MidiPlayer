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
    
    func convertFileWithUrl(_ url: URL) {

    }
    
    func setupMIDIPlayer() {
        if let midiURL = Bundle.main.url(forResource: "examMIDI", withExtension: "mid"),
            let soundFontURL = Bundle.main.url(forResource: "Stratocaster Light Overdrive.SF2", withExtension: nil) {
            do {

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
    
    func highPassFilterAction() {
        
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

