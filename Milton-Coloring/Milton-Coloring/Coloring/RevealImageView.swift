//
//  RevealImageView.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 26.08.2024.
//

import UIKit

class RevealImageView: UIImageView {
    
    private var maskPath = UIBezierPath()
    private var maskLayer: CAShapeLayer = CAShapeLayer()
    
    var lineArray: [[CGPoint]] = [[CGPoint]]()
    
    var coloringType: ColoringType = .crayon
    var isEmpty = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() -> Void {
        isUserInteractionEnabled = true
        
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = coloringStrokeSize
        maskLayer.lineCap = .round
        maskLayer.lineJoin = .round
        
        layer.mask = maskLayer
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = bounds
    }
    
    func animateFillFromPoint(_ point: CGPoint){
        lineArray[lineArray.count - 1].append(point)
        let width = CGFloat(lineArray.last?.count ?? 0) * CGFloat(lineArray.last?.count ?? 0) * coloringStrokeSize / 2.6
        let path = UIBezierPath(ovalIn: CGRect(x: point.x - width / 2, y: point.y - width / 2, width: width, height: width))
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.path = path.cgPath
        setNeedsDisplay()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.lineArray.last?.count ?? 20 < 20{
                self.animateFillFromPoint(point)
            }else{
                
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        if coloringType == .crayon{
            maskLayer.fillColor = UIColor.clear.cgColor
            
            maskPath.move(to: currentPoint)
        }else{
            lineArray.append([CGPoint]())
            animateFillFromPoint(currentPoint)
        }
        
        isEmpty = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        if coloringType == .crayon{
            maskPath.addLine(to: currentPoint)
            maskLayer.path = maskPath.cgPath
        }else{
            
        }
        
    }
    
}
