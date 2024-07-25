//
//  Animation.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 26.01.2022.
//
import Foundation
import UIKit

class Animation{
    var onTopOfItem: Bool
    var positionX: CGFloat
    var positionY: CGFloat
    var width: CGFloat
    var height:CGFloat
    var actionRepeatCount:Int
    var duration:Float
    var sound:String
    
    var actionFrames:[UIImage]
    var spriteSheets: [SpriteSheet]
    
    init(){
        self.onTopOfItem = false
        self.positionX = CGFloat(0)
        self.positionY = CGFloat(0)
        self.width = CGFloat(0)
        self.height = CGFloat(0)
        self.actionRepeatCount = 0
        self.duration = 0
        self.sound = ""
        
        self.actionFrames = [UIImage]()
        self.spriteSheets = [SpriteSheet]()
    }
    
    init(onTopOfItem: Bool, positionX: CGFloat, positionY:CGFloat, width:CGFloat, height:CGFloat, actionRepeatCount:Int, duration:Float, sound:String, actionFrames:[UIImage], spriteSheets:[SpriteSheet]){
        self.onTopOfItem = onTopOfItem
        self.positionX = positionX
        self.positionY = positionY
        self.width = width
        self.height = height
        self.actionRepeatCount = actionRepeatCount
        self.duration = duration
        self.sound = sound
        
        self.actionFrames = [UIImage]()
        for actionFrame in actionFrames {
            let cropped = actionFrame.cropAlpha()
            self.actionFrames.append(cropped)
        }
        
        self.spriteSheets = spriteSheets
    }
    
    convenience init (dictionary: Dictionary<String, Any>, spriteSheets:[SpriteSheet]){
        var onTopOfItem = false
        if let value = dictionary["onTopOfItem"] as? Bool{
            onTopOfItem = value
        }else{
            
        }
        
        var positionX = CGFloat(0)
        if let value = dictionary["positionX"] as? String{
            positionX = value.cgFloatValue
        }else{
            
        }
        
        var positionY = CGFloat(0)
        if let value = dictionary["positionY"] as? String{
            positionY = value.cgFloatValue
        }else{
            
        }
        
        var width = CGFloat(0)
        if let value = dictionary["width"] as? String{
            width = value.cgFloatValue
        }else{
            
        }
        
        var height = CGFloat(0)
        if let value = dictionary["height"] as? String{
            height = value.cgFloatValue
        }else{
            
        }
        
        var actionRepeatCount: Int = 0
        if let value = dictionary["actionRepeatCount"] as? String{
            actionRepeatCount = Int(value.cgFloatValue)
        }else{
            actionRepeatCount = 3
        }
        
        var duration: Float = 3
        if let value = dictionary["duration"] as? Float{
            duration = value
        }else{
            duration = 3
        }
        
        var sound: String = ""
        if let value = dictionary["sound"] as? String{
            sound = value
        }
        
        var animationFrames = [UIImage]()
        if let framesArray = dictionary["actionFrames"] as? [String]{
            for frameName in framesArray{
                var frameImage = UIImage()
                for spriteSheet in spriteSheets{
                    if let image = spriteSheet[frameName]{
                        frameImage = image
                        break
                    }
                }
                animationFrames.append(frameImage)
            }
        }
        
        self.init(onTopOfItem: onTopOfItem, positionX: positionX, positionY: positionY, width: width, height: height, actionRepeatCount: actionRepeatCount, duration: duration, sound: sound, actionFrames: animationFrames, spriteSheets: spriteSheets)
    }
}

