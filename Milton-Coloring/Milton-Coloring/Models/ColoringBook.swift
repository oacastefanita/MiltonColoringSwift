//
//  ColoringBook.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 01.07.2024.
//

import Foundation
import UIKit

class ColoringBook {
    let icon: UIImage!
    var name: String
    var fileName: String
    var layersFileName: String
    var positionsFileName: String
    var items: [ColoringBookItem] = []
    
    var layersMetadata =  Dictionary<String, Any>()
    var spriteSheet: SpriteSheet?
    
    var purchaseId: String?
    var url: String?
    
    convenience init(dictionary: Dictionary<String, Any>){
        var name: String = ""
        if let value = dictionary["Name"] as? String{
            name = value
        }
        
        var fileName: String = ""
        if let value = dictionary["FileName"] as? String{
            fileName = value
        }
        
        var layersFileName: String = ""
        if let value = dictionary["Layers"] as? String{
            layersFileName = value
        }
        
        var positionsFileName: String = ""
        if let value = dictionary["Positions"] as? String{
            positionsFileName = value
        }
        
        self.init(name: name, fileName: fileName, layersFileName: layersFileName, positionsFileName: positionsFileName, purchaseId: nil)
    }

    init(name: String, fileName: String, layersFileName: String, positionsFileName: String, purchaseId: String?) {
        self.name = name
        self.fileName = fileName
        self.layersFileName = layersFileName
        self.positionsFileName = positionsFileName
        self.purchaseId = purchaseId
        self.spriteSheet = nil
        
        let iconFileURL = documentsDirectory.appendingPathComponent("Milton/coloringbooks/coloringBooks").appendingPathComponent(fileName).path()
        self.icon = UIImage(contentsOfFile: iconFileURL)
    }
    
    func loadBookData( completion: @escaping ((Bool) -> Void) ){
        SpriteSheet.createWith(name: self.layersFileName ?? "", path: documentsDirectory.appendingPathComponent("Milton/coloringbooks/coloringBooksLayers"), completion: { [weak self] success, spriteSheet in
            if success, let spritesheet = spriteSheet{
                self?.spriteSheet = spritesheet
                self?.loadColoringLayersData()
            }
            completion(success)
        })
    }
    
    
    
    func loadColoringLayersData(){
        let fileURL = documentsDirectory.appendingPathComponent("Milton/coloringbooks/coloringBooksLayers").appendingPathComponent(self.positionsFileName)
        guard let dict = NSDictionary(contentsOfFile: fileURL.path) else {
            return
        }
        guard let spriteSheet = spriteSheet else {
            return
        }
        
        layersMetadata = dict.swiftDictionary["frames"] as! [String: Any]
        
        for keyName in layersMetadata.keys{
            if let dict = layersMetadata[keyName] as? [String: Any], let positionsString = dict["frame"] as? String{
                let positionsArray = positionsString.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").components(separatedBy: ",")
                if positionsArray.count == 4{
                    let notZero = 0.00000001
                    let posX = (Double(positionsArray[0]) ?? notZero ) / AssetsManager.sharedInstance.coloringDesignSize.width
                    let posY = (Double(positionsArray[1]) ?? notZero ) / AssetsManager.sharedInstance.coloringDesignSize.height
                    let width = (Double(positionsArray[2]) ?? notZero ) / AssetsManager.sharedInstance.coloringDesignSize.width
                    let height = (Double(positionsArray[3]) ?? notZero ) / AssetsManager.sharedInstance.coloringDesignSize.height
                    
                    let item = ColoringBookItem(texture: spriteSheet[keyName], position: CGPoint(x: posX, y: posY), size: CGSize(width: width, height: height))
                    self.items.append(item)
                }
            }
        }
        
//        var posX = 1719.0 * 0.0 / AssetsManager.sharedInstance.coloringDesignSize.width
//        var posY = 1536.0 * 0.0 / AssetsManager.sharedInstance.coloringDesignSize.height
//        var width = 1719.0 * 0.25 / AssetsManager.sharedInstance.coloringDesignSize.width
//        var height = 1536.0 * 0.25 / AssetsManager.sharedInstance.coloringDesignSize.height
//
//        var item = ColoringBookItem(texture: UIImage(named: ""), position: CGPoint(x: posX, y: posY), size: CGSize(width: width, height: height))
//        self.items.append(item)
//        
//        posX = 1719.0 * 0.75 / AssetsManager.sharedInstance.coloringDesignSize.width
//        posY = 1536.0 * 0.75 / AssetsManager.sharedInstance.coloringDesignSize.height
//        width = 1719.0 * 0.25 / AssetsManager.sharedInstance.coloringDesignSize.width
//        height = 1536.0 * 0.25 / AssetsManager.sharedInstance.coloringDesignSize.height
//        
//        item = ColoringBookItem(texture: UIImage(named: ""), position: CGPoint(x: posX, y: posY), size: CGSize(width: width, height: height))
//        self.items.append(item)
    }
}

class ColoringBookItem {
    var texture: UIImage?
    var position: CGPoint
    var size: CGSize

    init(texture: UIImage?, position: CGPoint, size: CGSize) {
        self.texture = texture
        self.position = position
        self.size = size
    }
}
