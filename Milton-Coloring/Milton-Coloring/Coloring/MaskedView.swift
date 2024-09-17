//
//  MaskedView.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 27.08.2024.
//

import UIKit

enum ColoringType: Int{
    case crayon = 0
    case dippers
}

class MaskedView: UIView {
    
    var currentPattern: UIColor? = nil
    var currentColor: UIColor? = nil
    var currentType: ColoringType = .crayon
    
    var maskImage: UIImage!
    
    var coloredImages = [RevealImageView]()
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        maskImage = image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func coloringSelectionChanged(type: ColoringType, color:UIColor?, pattern:UIColor? ){
        self.currentType = type
        self.currentColor = color
        self.currentPattern = pattern
        
        for view in self.subviews{
            if let colorable = view as? ColorableView, colorable.isEmpty{
                colorable.removeFromSuperview()
            }else if let reveal = view as? RevealImageView, reveal.isEmpty{
                reveal.removeFromSuperview()
            }
        }
        
        if currentPattern == nil{
            let newView = ColorableView(frame: CGRectZero)
            newView.currentColor = self.currentColor!.cgColor
            newView.coloringType = type
            self.addConstrained(subview: newView)
        }else{
            let newView = RevealImageView(frame: CGRectZero)
            newView.coloringType = type
            newView.backgroundColor = pattern
            self.addConstrained(subview: newView)
        }
    }
    
    override func draw(_ rect: CGRect) {
        let mask = CALayer()
        mask.frame = rect
        mask.contents = maskImage.cgImage!

        self.layer.mask = mask
        self.layer.masksToBounds = true
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Convert the touch point to the coordinate system of the mask image
        let maskBounds = self.bounds
        let maskSize = maskImage.size
        
        let scaleX = maskSize.width / maskBounds.width
        let scaleY = maskSize.height / maskBounds.height
        
        let pointInMask = CGPoint(x: point.x * scaleX, y: point.y * scaleY)
        
        // Check if the point is within the mask image's bounds
        if pointInMask.x < 0 || pointInMask.x >= maskImage.size.width || pointInMask.y < 0 || pointInMask.y >= maskImage.size.height {
            return false
        }
        
        // Get the pixel data of the mask image at the touch point
        guard let cgImage = maskImage.cgImage,
              let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data else {
            return false
        }
        
        let data = CFDataGetBytePtr(pixelData)
        
        let bytesPerRow = cgImage.bytesPerRow
        let numberOfComponents = cgImage.bitsPerPixel / 8
        
        let x = Int(pointInMask.x)
        let y = Int(pointInMask.y)
        
        let pixelIndex = y * bytesPerRow + x * numberOfComponents
        
        // The alpha component is usually the last component in the pixel data
        let alpha = data?[pixelIndex + 3] ?? 0
        
        // If alpha is greater than 0, the touch is within the mask
        return alpha > 0
    }

}
