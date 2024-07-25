//
//  SoundsController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 11.01.2022.
//

import Foundation
import AVFoundation

class SoundsController: NSObject {
    @objc public static let sharedInstance = SoundsController()
    
    public private(set) var soundsOn = true
    public private(set) var musicOn = true
    
    var backgroundAudioPlayer: AVAudioPlayer?
    var soundAudioPlayer: AVAudioPlayer?
    override init() {
        super.init()
        loadSavedSettings()
    }
    
    func loadSavedSettings(){
        soundsOn = UserDefaults.standard.bool(forKey: "soundsOn")
        musicOn = UserDefaults.standard.bool(forKey: "musicOn")
        print("Music: \(musicOn) Sounds: \(soundsOn)")
    }
    
    func saveSettings(){
        UserDefaults.standard.set(soundsOn, forKey: "soundsOn")
        UserDefaults.standard.set(musicOn, forKey: "musicOn")
        print("Music: \(musicOn) Sounds: \(soundsOn)")
    }
    
    func checkAndPlayBackgroundMusic(){
        if musicOn{
            let backgroundMusic = AssetsManager.sharedInstance.getBackgroundMusicPath()
            do {
                backgroundAudioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = backgroundAudioPlayer else { return }
                audioPlayer.numberOfLoops = -1 // for infinite times
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }else{
            backgroundAudioPlayer?.stop()
        }
    }
    
    func playMenuSound(){
        if soundsOn {
            let sound = AssetsManager.sharedInstance.getMenuSoundPath()
            do {
                soundAudioPlayer = try AVAudioPlayer(contentsOf:sound as URL)
                guard let audioPlayer = soundAudioPlayer else { return }
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
    func changeSoundSetting(){
        soundsOn = !soundsOn
        saveSettings()
    }
    
    func changeMusicSetting(){
        musicOn = !musicOn
        checkAndPlayBackgroundMusic()
        saveSettings()
    }
    
}

