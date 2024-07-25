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
            }
            completion(success)
        })
    }
}

class ColoringBookItem {
    var texture: UIImage?
    var position: CGPoint
    var size: CGSize
    var book: ColoringBook

    init(texture: UIImage?, position: CGPoint, size: CGSize, book: ColoringBook) {
        self.texture = texture
        self.position = position
        self.size = size
        self.book = book
    }
}
