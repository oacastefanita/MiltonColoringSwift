//
//  AssetsManager.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 03.01.2022.
//

import Foundation
import CommonCrypto
import Zip
import simd
import SpriteKit
import SwiftUI

let documentsDirectory = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]

class AssetsManager: NSObject {
    @objc public static let sharedInstance = AssetsManager()
    
    let backgroundsFolderSubpath = "Milton/menus/background/"
    
    var menusMetadata =  Dictionary<String, Any>()
    var menuSpriteSheets = [SpriteSheet]()
    
    var booksMetadata =  Dictionary<String, Any>()
    var coloringBooks = [ColoringBook]()
    
    let coloringDesignSize = CGSize(width: 1719.0, height: 1536.0)
    
    //MARK: Download
    func loadFileFromLocalPath(_ localFilePath: String) ->Data? {
        return try? Data(contentsOf: URL(fileURLWithPath: localFilePath))
    }
    
    func startAssetsDownload(downloadProgressHandler:((Float) -> Void)?, completionHandle:((Bool, String) -> Void?)?){
        APIClient.sharedInstance.getURL(){ success, response in
            let lastTime = UserDefaults.standard.integer(forKey: "time")
            if success{
                if let serverReponse = response, let url = serverReponse["url"] as? String, let time = serverReponse["time"] as? Int, let checksum = serverReponse["checksum"] as? String{
                    if (lastTime != time){
                        APIClient.sharedInstance.downloadFile(url, progress: {progress in
                            if let progressHandler = downloadProgressHandler{
                                progressHandler(progress)
                            }
                        }, completionHandler: {downloadSuccess, path in
                            if downloadSuccess{
                                print(self.loadFileFromLocalPath(path)?.sha256())
                                let ignoreSHA = false
                                
                                if let data = self.loadFileFromLocalPath(path),data.sha256() == checksum || ignoreSHA, var pathURL = URL(string: path){
                                    do {
                                        
                                        try Zip.unzipFile(pathURL, destination: documentsDirectory, overwrite: true, password: "654321", progress: { (progress) -> () in
                                            print(progress)
                                            if progress == 1{
                                                UserDefaults.standard.set(time, forKey: "time")
                                                if let completion = completionHandle{
                                                    completion(true, "Success")
                                                }
                                            }
                                        }, fileOutputHandler: {(file) -> () in
                                            
                                        }) // Unzip
                                        
                                    }
                                    catch {
                                        // unzip failed
                                        if lastTime != 0{
                                            if let completion = completionHandle{
                                                completion(true, "Uzip Failed")
                                            }
                                        }else{
                                            if let completion = completionHandle{
                                                completion(false, "Uzip Failed")
                                            }
                                        }
                                    }
                                }else{
                                    // sha failed
                                    if lastTime != 0{
                                        if let completion = completionHandle{
                                            completion(true, "SHA Failed")
                                        }
                                    }else{
                                        if let completion = completionHandle{
                                            completion(false, "SHA Failed")
                                        }
                                    }
                                }
                            }else if lastTime != 0{
                                if let completion = completionHandle{
                                    completion(true, "File Failed")
                                }
                            }else{
                                if let completion = completionHandle{
                                    completion(false, "File Failed")
                                }
                            }
                        })
                    }else{
                        //already downloaded
                        if let completion = completionHandle{
                            completion(true, "File already downloaded")
                        }
                    }
                }else{
                    //response incorrect
                    if lastTime != 0{
                        if let completion = completionHandle{
                            completion(true, "Incorrect response")
                        }
                    }else{
                        if let completion = completionHandle{
                            completion(false, "Incorrect response")
                        }
                    }
                }
            }else{
                //response failed
                if lastTime != 0{
                    if let completion = completionHandle{
                        completion(true, "Response failed")
                    }
                }else{
                    if let completion = completionHandle{
                        completion(false, "Response failed")
                    }
                }
            }
        }
    }
    
    func createButton(using mitonButton:MiltonButton, superView: UIView, fillView: Bool = false) -> UIButton{
        let button = UIButton()
        button.setImage(mitonButton.regular, for: .normal)
        button.setImage(mitonButton.pressed, for: .selected)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(button)
        
        let size = CGSize(width: superView.frame.size.height * (4/3), height: superView.frame.size.height)
        let padding = (superView.frame.size.width - size.width ) / 2
        let width = mitonButton.width * size.width
        let height = mitonButton.height * size.height
        let posX = padding + mitonButton.xPos * size.width - width / 2
        let posY = ( 1 - mitonButton.yPos) * size.height - width / 2
        
        if fillView{
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0),
                button.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0),
                button.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0),
                button.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0)
            ])
        }else{
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: superView.topAnchor, constant: posY),
                button.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: posX),
                button.widthAnchor.constraint(equalToConstant: width),
                button.heightAnchor.constraint(equalToConstant: height)
            ])
        }
        
        return button
    }
    
    func getSidePadding(from superView: UIView) -> CGFloat{
        let size = CGSize(width: superView.frame.size.height * (4/3), height: superView.frame.size.height)
        let padding = (superView.frame.size.width - size.width ) / 2
        return padding
    }
    
    func getAspectRatioViewSize(from superView: UIView) -> CGSize{
        let size = CGSize(width: superView.frame.size.height * (4/3), height: superView.frame.size.height)
        return size
    }
    
    
    //MARK: Puzzles
    //    var menuSpriteSheet: SpriteSheet!
    func loadColoringMetadata(){
        let fileURL = documentsDirectory.appendingPathComponent("Milton/coloringbooks/ColoringBooks.plist")
        guard let dict = NSDictionary(contentsOfFile: fileURL.path) else {
            return
        }
        
        booksMetadata = dict.swiftDictionary
    }

    //MARK: Translations
    var translations = [Translation]()
    var selectedTranslation: Translation!
    func loadTranslations(){
        let fileURL = documentsDirectory.appendingPathComponent("Milton/coloringbooks/Translations.plist")
        guard let dict = NSDictionary(contentsOfFile: fileURL.path) else {
            return
        }
        translations = [Translation]()
        if let translationsArray = dict["Translations"] as? Array< Dictionary<String, Any> >{
            for dict in translationsArray{
                let translation = Translation(dictionary: dict)
                translations.append(translation)
                
                if translation.id == "1"{
                    selectedTranslation = translation
                }
            }
            if selectedTranslation == nil, let first = translations.first{
                selectedTranslation = first
            }
        }
    }
    
    //MARK: Main Menu
    func loadMenuMetadata(){
        let fileURL = documentsDirectory.appendingPathComponent("Milton/menus/MenusMetadata.plist")
        guard let dict = NSDictionary(contentsOfFile: fileURL.path) else {
            return
        }
        
        menusMetadata = dict.swiftDictionary
    }
    
    func loadMenuResources( completion: @escaping ((Bool) -> Void) ){
        loadTranslations()
        loadMenuMetadata()
        loadColoringMetadata()
        loadColorginPanel()
        
        menuSpriteSheets = [SpriteSheet]()
        SpriteSheet.createWith(name: "coloringBook", path: documentsDirectory.appendingPathComponent("Milton/coloringbooks"), completion: { success, menuSpriteSheet in
            if success{
                if let assets = self.booksMetadata["ColoringBooks"] as? Array< Dictionary<String, Any> >{
                    self.coloringBooks = [ColoringBook]()
                    for dict in assets{
                        let book = ColoringBook(dictionary: dict)
                        self.coloringBooks.append(book)
                    }
                }
                if let assets = self.menusMetadata["Assets"] as? Array<String>{
                    var completed = 0
                    for var assetName in assets{
                        SpriteSheet.createWith(name: assetName, path: documentsDirectory.appendingPathComponent("Milton/menus"), completion: { success, loadedMenuSpriteSheet in
                            if success{
                                self.menuSpriteSheets.append(loadedMenuSpriteSheet!)
                                completed = completed + 1
                                if completed == assets.count{
                                    completion(true)
                                }
                            }else{
                                completion(false)
                            }
                        })
                        
                    }
                }
                
                
            }else{
                completion(false)
            }
        })
    }
    
    func getMainMenuBackgroundImage() -> UIImage{
        if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let name = home["BackgroundImage"] as? String{
            let path = documentsDirectory.path + "/" + backgroundsFolderSubpath + name
            if let image = UIImage(contentsOfFile: path){
                return image
            }
        }
        
        return UIImage()
    }
    
    func getMainMenuLockedImage() -> UIImage{
        if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let name = home["LockedImage"] as? String{
            let path = documentsDirectory.path + "/" + backgroundsFolderSubpath + name
            if let image = UIImage(contentsOfFile: path){
                return image
            }
        }
        
        return UIImage()
    }
    
    func getMainMenuBackgroundColor() -> UIColor{
        if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let rgba = home["BackgroundColor"] as? String, rgba.components(separatedBy: ",").count == 4{
            let comps = rgba.components(separatedBy: ",")
            return UIColor(red: Double(comps[0])! / 255.0, green: Double(comps[1])! / 255.0, blue: Double(comps[2])! / 255.0, alpha: Double(comps[3])! / 255.0)
        }else if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let hex = home["BackgroundColor"] as? String, let color = UIColor(hexString: hex){
            return color
        }
        
        return UIColor.clear
    }
    
    func getMainMenuSettingsButton() -> MiltonButton?{
        if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let settingsButton = home["SettingsButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: settingsButton, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getMainMenuCloseButton() -> MiltonButton?{
        if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let settingsButton = home["CloseButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: settingsButton, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getBookMenuButton() -> MiltonButton?{
        if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let button = home["BookPlaceholder"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    //MARK: Settings
    func getSettingsBackgroundColor() -> UIColor{
        if let home = menusMetadata["Settings"] as? Dictionary<String, Any>, let rgba = home["BackgroundColor"] as? String, rgba.components(separatedBy: ",").count == 4{
            let comps = rgba.components(separatedBy: ",")
            return UIColor(red: Double(comps[0])! / 255.0, green: Double(comps[1])! / 255.0, blue: Double(comps[2])! / 255.0, alpha: Double(comps[3])! / 255.0)
        }else if let home = menusMetadata["Settings"] as? Dictionary<String, Any>, let hex = home["BackgroundColor"] as? String, let color = UIColor(hexString: hex){
            return color
        }
        
        return UIColor.clear
    }
    
    func getSettingsBackgroundImage() -> UIImage{
        if let settings = menusMetadata["Settings"] as? Dictionary<String, Any>, let name = settings["BackgroundImage"] as? String{
            let path = documentsDirectory.path + "/" + backgroundsFolderSubpath + name
            if let image = UIImage(contentsOfFile: path){
                return image
            }
        }
        
        return UIImage()
    }
    
    func getSettingsCloseButton() -> MiltonButton?{
        if let root = menusMetadata["Settings"] as? Dictionary<String, Any>, let button = root["CloseButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getSettingsHomeButton() -> MiltonButton?{
        if let root = menusMetadata["Settings"] as? Dictionary<String, Any>, let button = root["HomeButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getSettingsSoundsButton() -> MiltonButton?{
        if let root = menusMetadata["Settings"] as? Dictionary<String, Any>, let button = root["SoundButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getSettingsMusicButton() -> MiltonButton?{
        if let root = menusMetadata["Settings"] as? Dictionary<String, Any>, let button = root["MusicButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getSettingsStatisticsButton() -> MiltonButton?{
        if let root = menusMetadata["Settings"] as? Dictionary<String, Any>, let button = root["StatisticsButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getMainMenuResourcesButton() -> MiltonButton?{
        if let home = menusMetadata["Home"] as? Dictionary<String, Any>, let settingsButton = home["ResourcesButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: settingsButton, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    //MARK: Statistics
    func getStatisticsFontColor() -> UIColor{
        if let home = menusMetadata["Statistics"] as? Dictionary<String, Any>, let rgba = home["FontColor"] as? String, rgba.components(separatedBy: ",").count == 4{
            let comps = rgba.components(separatedBy: ",")
            return UIColor(red: Double(comps[0])! / 255.0, green: Double(comps[1])! / 255.0, blue: Double(comps[2])! / 255.0, alpha: Double(comps[3])! / 255.0)
        }else if let home = menusMetadata["Statistics"] as? Dictionary<String, Any>, let hex = home["FontColor"] as? String, let color = UIColor(hexString: hex){
            return color
        }
        
        return UIColor.clear
    }
    
    func getStatisticsBackgroundColor() -> UIColor{
        if let home = menusMetadata["Statistics"] as? Dictionary<String, Any>, let rgba = home["BackgroundColor"] as? String, rgba.components(separatedBy: ",").count == 4{
            let comps = rgba.components(separatedBy: ",")
            return UIColor(red: Double(comps[0])! / 255.0, green: Double(comps[1])! / 255.0, blue: Double(comps[2])! / 255.0, alpha: Double(comps[3])! / 255.0)
        }else if let home = menusMetadata["Statistics"] as? Dictionary<String, Any>, let hex = home["BackgroundColor"] as? String, let color = UIColor(hexString: hex){
            return color
        }
        
        return UIColor.clear
    }
    
    func getStatisticsBackgroundImage() -> UIImage{
        if let home = menusMetadata["Statistics"] as? Dictionary<String, Any>, let name = home["BackgroundImage"] as? String{
            let path = documentsDirectory.path + "/" + backgroundsFolderSubpath + name
            if let image = UIImage(contentsOfFile: path){
                return image
            }
        }
        
        return UIImage()
    }
    
    func getStatisticsCloseButton() -> MiltonButton?{
        if let root = menusMetadata["Statistics"] as? Dictionary<String, Any>, let button = root["CloseButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    //MARK: Resources
    func getResourcesFontColor() -> UIColor{
        if let home = menusMetadata["Resources"] as? Dictionary<String, Any>, let rgba = home["FontColor"] as? String, rgba.components(separatedBy: ",").count == 4{
            let comps = rgba.components(separatedBy: ",")
            return UIColor(red: Double(comps[0])! / 255.0, green: Double(comps[1])! / 255.0, blue: Double(comps[2])! / 255.0, alpha: Double(comps[3])! / 255.0)
        }else if let home = menusMetadata["Resources"] as? Dictionary<String, Any>, let hex = home["FontColor"] as? String, let color = UIColor(hexString: hex){
            return color
        }
        
        return UIColor.clear
    }
    
    func getResourcesBackgroundColor() -> UIColor{
        if let home = menusMetadata["Resources"] as? Dictionary<String, Any>, let rgba = home["BackgroundColor"] as? String, rgba.components(separatedBy: ",").count == 4{
            let comps = rgba.components(separatedBy: ",")
            return UIColor(red: Double(comps[0])! / 255.0, green: Double(comps[1])! / 255.0, blue: Double(comps[2])! / 255.0, alpha: Double(comps[3])! / 255.0)
        }else if let home = menusMetadata["Resources"] as? Dictionary<String, Any>, let hex = home["BackgroundColor"] as? String, let color = UIColor(hexString: hex){
            return color
        }
        
        return UIColor.clear
    }
    
    func getResourcesBackgroundImage() -> UIImage{
        if let home = menusMetadata["Resources"] as? Dictionary<String, Any>, let name = home["BackgroundImage"] as? String{
            let path = documentsDirectory.path + "/" + backgroundsFolderSubpath + name
            if let image = UIImage(contentsOfFile: path){
                return image
            }
        }
        
        return UIImage()
    }
    
    func getResourcesCloseButton() -> MiltonButton?{
        if let root = menusMetadata["Resources"] as? Dictionary<String, Any>, let button = root["CloseButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    //MARK: Sounds
    func getBackgroundMusicPath() -> URL{
        let fileURL = documentsDirectory.appendingPathComponent("Milton/menus/music/BackgroundMusic.wav")
        return fileURL
    }
    
    func getMenuSoundPath() -> URL{
        let fileURL = documentsDirectory.appendingPathComponent("Milton/menus/sounds/MenuSound.wav")
        return fileURL
    }
    
    //MARK: ColoringPanel
    var patterns: [UIImage] = []
    var patternNames: [String] = []
    var coloringPanelSpriteSheet: SpriteSheet!
    
    let colorsList: [UIColor] = [
        UIColor(red: 224.0/255.0, green: 46.0/255.0, blue: 146.0/255.0, alpha: 1.0),
        UIColor(red: 167.0/255.0, green: 46.0/255.0, blue: 224.0/255.0, alpha: 1.0),
        UIColor(red: 28.0/255.0, green: 142.0/255.0, blue: 238.0/255.0, alpha: 1.0),
        UIColor(red: 87.0/255.0, green: 214.0/255.0, blue: 25.0/255.0, alpha: 1.0),
        UIColor(red: 238.0/255.0, green: 197.0/255.0, blue: 33.0/255.0, alpha: 1.0),
        UIColor(red: 237.0/255.0, green: 128.0/255.0, blue: 40.0/255.0, alpha: 1.0),
        UIColor(red: 224.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)
    ]

    let moreColorsList: [UIColor] = [
        UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0),
        UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0),
        UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0),
        UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0),
        UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0),
        UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0),
        UIColor(red: 255.0/255.0, green: 128.0/255.0, blue: 0.0/255.0, alpha: 1.0),
        UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 128.0/255.0, alpha: 1.0),
        UIColor(red: 0.0/255.0, green: 255.0/255.0, blue: 128.0/255.0, alpha: 1.0),
        UIColor(red: 128.0/255.0, green: 255.0/255.0, blue: 0.0/255.0, alpha: 1.0),
        UIColor(red: 0.0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0),
        UIColor(red: 128.0/255.0, green: 0.0/255.0, blue: 255.0/255.0, alpha: 1.0),
        UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0),
        UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    ]
    
    func loadColorginPanel(){
        loadColoringPanelSpriteSheet()
        loadPatterns()
    }
    
    func loadColoringPanelSpriteSheet(){
        SpriteSheet.createWith(name: "coloringBook", path: documentsDirectory.appendingPathComponent("Milton/coloringbooks"), completion: { success, spriteSheet in
            if success, let spriteSheet = spriteSheet{
                self.coloringPanelSpriteSheet = spriteSheet
            }
        })
    }
    
    func loadPatterns(){
        let path = documentsDirectory.appendingPathComponent("/Milton/coloringbooks/patterns/")
        
        let fileManager = FileManager.default
        do{
            let files = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: [])
            for file in files {
                let patternName = file.lastPathComponent.replacingOccurrences(of: "pattern_", with: "").replacingOccurrences(of: ".png", with: "")
                patternNames.append(file.lastPathComponent)
                if let image = UIImage(contentsOfFile: file.path()){
                    patterns.append(image)
                }
            }
        }catch{
            
        }
    }
    
    func getColoringPanelBackgroundImage() -> UIImage{
        if let found = self.coloringPanelSpriteSheet["right_panel.png"]{
            return found
        }
        
        return UIImage()
    }
    
    func getColoringPanelForegroundImage() -> UIImage{
        if let found = self.coloringPanelSpriteSheet["over_crayons_panel.png"]{
            return found
        }
        
        return UIImage()
    }
    
    func getColoringPanelCloseButton() -> MiltonButton?{
        if let root = menusMetadata["Home"] as? Dictionary<String, Any>, let button = root["CloseButton"] as? Dictionary<String, Any>{
            return MiltonButton(dictionary: button, spriteSheets: menuSpriteSheets)
        }
        
        return nil
    }
    
    func getColoringPanelDoneButtonImage() -> UIImage{
        if let found = self.coloringPanelSpriteSheet["closeColoring.png"]{
            return found
        }
        return UIImage()
    }
    
    func getColoringPanelCrayonButtonImageFrom(color: UIColor?, pattern: String?) -> UIImage {
        let textureTop = coloringPanelSpriteSheet["crayon_overlay.png"]!
        var textureBase = coloringPanelSpriteSheet["crayon.png"]!
        
        var crayonColor = color ?? UIColor.clear
        

        if let pattern = pattern {
            textureBase = coloringPanelSpriteSheet["crayon_\(pattern)"]!
        }else{
            textureBase = coloringPanelSpriteSheet["crayon.png"]!.tinted(with: color!)!
        }
        
        let texture = textureBase.mergeWith(topImage: textureTop)
        
        return texture
    }
    
    func getColoringPanelDipperButtonImageFrom(color: UIColor?, pattern: String?) -> UIImage {
        let textureTop = coloringPanelSpriteSheet["dipper_overlay.png"]!
        var textureBase = coloringPanelSpriteSheet["dipper.png"]!
        
        var crayonColor = color ?? UIColor.clear
        

        if let pattern = pattern {
            textureBase = coloringPanelSpriteSheet["dipper_\(pattern)"]!
        }else{
            textureBase = coloringPanelSpriteSheet["dipper.png"]!.tinted(with: color!)!
        }
        
        let texture = textureBase.mergeWith(topImage: textureTop)
        
        return texture
    }
    
    func getColoringPanelEraserButtonImage() -> UIImage{
        if let found = self.coloringPanelSpriteSheet["eraser.png"]{
            return found
        }
        return UIImage()
    }
    
    func getColoringPanelPatternButtonImage() -> UIImage{
        if let found = self.coloringPanelSpriteSheet["pattern_mode.png"]{
            return found
        }
        return UIImage()
    }
    
    func getColoringPanelRegularButtonImage() -> UIImage{
        if let found = self.coloringPanelSpriteSheet["color_mode.png"]{
            return found
        }
        return UIImage()
    }
    func getColoringPanelMoreButtonImage() -> UIImage{
        if let found = self.coloringPanelSpriteSheet["color_mode.png"]{
            return found
        }
        return UIImage()
    }
}
