//
//  SettingsViewController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 11.01.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    
    var musicButton: UIButton!
    var soundsButton: UIButton!
    var statisticsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImage.backgroundColor = AssetsManager.sharedInstance.getSettingsBackgroundColor()
        self.backgroundImage.image = AssetsManager.sharedInstance.getSettingsBackgroundImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadButtons()
    }
    
    func loadButtons(){
        if let button = AssetsManager.sharedInstance.getSettingsCloseButton(){
            let close = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
            close.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        }
        
        if let button = AssetsManager.sharedInstance.getSettingsMusicButton(){
            let result = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
            result.isSelected = !SoundsController.sharedInstance.musicOn
            result.addTarget(self, action: #selector(onMusic), for: .touchUpInside)
            musicButton = result
        }
        
        if let button = AssetsManager.sharedInstance.getSettingsSoundsButton(){
            let result = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
            result.isSelected = !SoundsController.sharedInstance.soundsOn
            result.addTarget(self, action: #selector(onSounds), for: .touchUpInside)
            soundsButton = result
        }
        
        if let button = AssetsManager.sharedInstance.getSettingsStatisticsButton(){
            let result = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
            result.addTarget(self, action: #selector(onStatistics), for: .touchUpInside)
            statisticsButton = result
        }
        
    }
    
    @objc func onClose() {
        SoundsController.sharedInstance.playMenuSound()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onHome() {
        SoundsController.sharedInstance.playMenuSound()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onSounds() {
        SoundsController.sharedInstance.playMenuSound()
        SoundsController.sharedInstance.changeSoundSetting()
        soundsButton.isSelected = !SoundsController.sharedInstance.soundsOn
    }
    
    @objc func onMusic() {
        SoundsController.sharedInstance.playMenuSound()
        SoundsController.sharedInstance.changeMusicSetting()
        musicButton.isSelected = !SoundsController.sharedInstance.musicOn
    }
    
    @objc func onStatistics() {
        SoundsController.sharedInstance.playMenuSound()
        self.performSegue(withIdentifier: "showStatistics", sender: self)
    }
}


