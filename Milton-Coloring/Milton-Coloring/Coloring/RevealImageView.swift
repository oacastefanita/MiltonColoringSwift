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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() -> Void {
        // default is false for UIImageView
        isUserInteractionEnabled = true
        // we only want to stroke the path, not fill it
        maskLayer.fillColor = UIColor.clear.cgColor
        // any color will work, as the mask uses the alpha value
        maskLayer.strokeColor = UIColor.white.cgColor
        // adjust drawing-line-width as desired
        maskLayer.lineWidth = coloringStrokeSize
        maskLayer.lineCap = .round
        maskLayer.lineJoin = .round
        // set the mask layer
        layer.mask = maskLayer
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        maskPath.move(to: currentPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        // add line to on maskPath
        maskPath.addLine(to: currentPoint)
        // update the mask layer path
        maskLayer.path = maskPath.cgPath
    }
    
}
