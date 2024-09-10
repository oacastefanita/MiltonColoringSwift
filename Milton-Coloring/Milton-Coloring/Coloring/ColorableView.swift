//
//  ColorableView.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 12.08.2024.
//

import UIKit

let coloringStrokeSize: CGFloat = 20

class ColorableView: UIView {

    var lineArray: [[CGPoint]] = [[CGPoint]]()
    var currentColor: CGColor = UIColor.random.cgColor
    var coloringType: ColoringType = .crayon
    var isEmpty = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.clear
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let firstPoint = touch.location(in: self)
        
        if coloringType == .crayon{
            lineArray.append([CGPoint]())
            lineArray[lineArray.count - 1].append(firstPoint)
        }else{
            lineArray.append([CGPoint]())
            animateFillFromPoint(firstPoint)
        }
        
        setNeedsDisplay()
        isEmpty = false
    }
    
    func animateFillFromPoint(_ point: CGPoint){
        lineArray[lineArray.count - 1].append(point)
        setNeedsDisplay()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.lineArray.last?.count ?? 20 < 20{
                self.animateFillFromPoint(point)
            }else{
                
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        if coloringType == .crayon{
            lineArray[lineArray.count - 1].append(currentPoint)
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        if coloringType == .crayon{
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.white.cgColor)
            
            context?.setLineWidth(coloringStrokeSize)
            context?.setStrokeColor(currentColor)
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
        }else{
            let context = UIGraphicsGetCurrentContext()
            context?.clear(rect)
            context?.setFillColor(currentColor)
            
            for line in lineArray{
                for (index, point) in line.enumerated() {
                    let width = CGFloat(index + 1) * CGFloat(index + 1) * coloringStrokeSize / 2.6
                    context?.fillEllipse(in: CGRect(x: point.x - width / 2, y: point.y - width / 2, width: width, height: width))
                }
            }
        }
    }
}
