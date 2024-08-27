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
        
        if currentPattern == nil{
            let newView = ColorableView(frame: CGRectZero)
            newView.currentColor = self.currentColor!.cgColor
            self.addConstrained(subview: newView)
        }else{
            let newView = RevealImageView(frame: CGRectZero)
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
}
