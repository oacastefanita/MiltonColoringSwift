//
//  MiltonButton.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 10.01.2022.
//

import Foundation
import UIKit

class MiltonButton: NSObject{
    let pressed: UIImage
    let regular: UIImage
    let xPos: CGFloat
    let yPos: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    init(pressed: UIImage, regular: UIImage, xPos: CGFloat, yPos: CGFloat, width: CGFloat, height: CGFloat){
        self.pressed = pressed
        self.regular = regular
        self.xPos = xPos
        self.yPos = yPos
        self.width = width
        self.height = height
        super.init()

    }
    
    convenience init (dictionary: Dictionary<String, Any>, spriteSheets: [SpriteSheet]){
        var regular: UIImage?
        if let name = dictionary["Sprite"] as? String{
            for sheet in spriteSheets{
                if let found = sheet[name]{
                    regular = found
                    break
                }
            }
        }
        
        var pressed: UIImage?
        if let name = dictionary["SpritePressed"] as? String{
            for sheet in spriteSheets{
                if let found = sheet[name]{
                    pressed = found
                    break
                }
            }
        }
        
        var x, y: CGFloat?
        if let pos = dictionary["Position"] as? String{
            if let xPos = pos.components(separatedBy: ",").first, let yPos = pos.components(separatedBy: ",").last, let xDouble = Double(xPos), let yDouble = Double(yPos){
                x = CGFloat(xDouble)
                y = CGFloat(yDouble)
            }
        }
        
        var width, height: CGFloat?
        if let pos = dictionary["Scale"] as? String{
            if let xPos = pos.components(separatedBy: ",").first, let yPos = pos.components(separatedBy: ",").last, let xDouble = Double(xPos), let yDouble = Double(yPos){
                width = CGFloat(xDouble)
                height = CGFloat(yDouble)
            }
        }
        
        self.init(pressed: pressed ?? UIImage(), regular: regular ?? UIImage(), xPos: x ?? 0.0, yPos: y ?? 0.0, width: width ?? 0.0, height: height ?? 0.0)
    }
}

