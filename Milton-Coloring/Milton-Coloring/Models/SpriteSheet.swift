//
//  SpriteSheet.swift
//  MiltonStorybook
//
//  Created by Stefanita Oaca on 08.01.2022.
//

import Foundation
import UIKit

class SpriteSheet{
    var images = Dictionary<String, UIImage>()
    
    subscript(name:String) -> UIImage? {
        get {
            return images[name]
        }
        set(newElm) {
            images[name] = newElm
        }
    }
    
    static func createWith(name:String, path: URL, completion: @escaping ((Bool, SpriteSheet?) -> Void)) {
        let newSpriteSheet = SpriteSheet()
        
        let folderPath = path.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: folderPath.path){
            print("found a folder")
            do{
                let files = try FileManager.default.contentsOfDirectory(atPath: folderPath.path)
                for file in files {
                    newSpriteSheet.images[file] = UIImage(contentsOfFile: folderPath.appendingPathComponent(file).path)
                }
            }catch{
                
            }
            DispatchQueue.main.async {
                completion(true, newSpriteSheet)
            }
        }else{
            var fileURL = path.appendingPathComponent(name + ".png")
            guard let image = UIImage(contentsOfFile: fileURL.path) else {
                DispatchQueue.main.async {
                    completion(true, newSpriteSheet)
                }
                return
            }
            
            fileURL = path.appendingPathComponent(name + ".plist")
            guard let dict = NSDictionary(contentsOfFile: fileURL.path) else {
                DispatchQueue.main.async {
                    completion(true, newSpriteSheet)
                }
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                if let frames = dict["frames"] as? Dictionary<String, Any>{
                    for key in frames.keys{
                        if let frame = frames[key] as? Dictionary<String, Any>{
                            if let textureRect = frame["textureRect"] as? String, let rotated = frame["textureRotated"] as? Bool{
                                let rect = newSpriteSheet.getRectFromString(textureRect, rotated: rotated)
                                print(rect)
                                var cropped = newSpriteSheet.cropImage(imageToCrop: image, toRect: rect)
                                if rotated{
                                    cropped = cropped.rotate(radians: -.pi/2)!
                                }
                                newSpriteSheet.images[key] = cropped
                            }else if let textureRect = frame["frame"] as? String, let rotated = frame["rotated"] as? Bool{
                                let rect = newSpriteSheet.getRectFromString(textureRect, rotated: rotated)
                                print(rect)
                                var cropped = newSpriteSheet.cropImage(imageToCrop: image, toRect: rect)
                                if rotated{
                                    cropped = cropped.rotate(radians: -.pi/2)!
                                }
                                newSpriteSheet.images[key] = cropped
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        completion(true, newSpriteSheet)
                    }
                }else{
                    DispatchQueue.main.async {
                        completion(false, newSpriteSheet)
                    }
                }
            }
        }
    }
    
    func getRectFromString(_ string: String, rotated: Bool) -> CGRect{
        let numbers = string.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").components(separatedBy: ",")
        if rotated{
            return CGRect(x: Double(numbers[0])!, y: Double(numbers[1])!, width: Double(numbers[3])!, height: Double(numbers[2])! )
        }else{
            return CGRect(x: Double(numbers[0])!, y: Double(numbers[1])!, width: Double(numbers[2])!, height: Double(numbers[3])! )
        }
    }
    
    func cropImage(imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
}
