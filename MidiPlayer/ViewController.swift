//
//  ViewController.swift
//  MidiPlayer
//
//  Created by Ethan on 2018/4/20.
//  Copyright © 2018年 EthanLab. All rights reserved.
//

import UIKit
import MIKMIDI
//import NVDSP
//import Novocaine

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playTimeSlider: UISlider!
    @IBOutlet weak var outputView: UIView!
    var longPressGesture: UILongPressGestureRecognizer!
    
    var collectionDataArray : Array<String> = ["Audio High Pass Filter" , "Audio Low Pass Filter"]
    var midiSequence : MIKMIDISequence?
    var midiSequencer : MIKMIDISequencer?
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
    
    func setupMIDIPlayer() {
        if let midiPath = Bundle.main.path(forResource: "examMIDI", ofType: "mid"),
            let midiData = NSData(contentsOfFile: midiPath) {
            do {
                self.midiSequence = try MIKMIDISequence.init(data: Data(referencing:midiData), error: ())
                self.midiSequencer = MIKMIDISequencer.init(sequence: self.midiSequence!)
                self.playTimeSlider.minimumValue = 0.0
                self.playTimeSlider.maximumValue = Float(self.midiSequence!.length)
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
    
    //MARK: - Selector Methods
    @objc func timerAction() {
        self.playTimeSlider.value = Float(self.midiSequencer!.currentTimeStamp)
        if self.midiSequencer!.currentTimeStamp == self.midiSequence!.length {
            self.midiSequencer!.stop()
            self.midiSequencer!.startPlayback()
        }
    }
    
    @objc func changeMIDITimeStamp() {
        let value = self.playTimeSlider.value
        if self.midiSequencer!.isPlaying {
            self.midiSequencer!.stop()
            self.midiSequencer!.startPlayback(atTimeStamp: MusicTimeStamp(value))
        }
        else {
            self.midiSequencer!.currentTimeStamp = MusicTimeStamp(value)
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
        if self.midiSequencer!.isPlaying {
            self.midiSequencer!.stop()
            self.enablePlayTimer(false)
            self.tapEffectWithButton(self.playButton, tapped: false)
        }
        else {
            self.midiSequencer!.startPlayback(atTimeStamp: self.midiSequencer!.currentTimeStamp)
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

