//
//  ColorableView.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 12.08.2024.
//

import UIKit

class ColorableView: UIView {

    var lineArray: [[CGPoint]] = [[CGPoint]]()
    var image: UIImage!
    
    private var imageMaskView = UIImageView()
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        self.image = image
        self.backgroundColor = UIColor.white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let firstPoint = touch.location(in: self)
        lineArray.append([CGPoint]())
        lineArray[lineArray.count - 1].append(firstPoint)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        lineArray[lineArray.count - 1].append(currentPoint)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        
        context?.setLineWidth(50)
        context?.setStrokeColor(UIColor.yellow.cgColor)
        context?.setLineCap(.round)
        
        for line in lineArray {
            guard let firstPoint = line.first else { continue }
            context?.beginPath()
            context?.move(to: firstPoint)
            for point in line.dropFirst() {
                context?.addLine(to: point)
            }
            context?.strokePath()
        }
        
        let mask = CALayer()
        mask.frame = rect
        mask.contents = image.cgImage!

        self.layer.mask = mask
        self.layer.masksToBounds = true
    }
}
