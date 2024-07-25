//
//  ColoringPanel.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 11.07.2024.
//

import UIKit

class ColoringPanel: UIView{
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var foregroundImage: UIImageView!
    
    @IBOutlet weak var regularViewContainer: UIView!
    @IBOutlet weak var regularCrayonsView: UIStackView!
    @IBOutlet weak var regularDipperView: UIStackView!
    @IBOutlet weak var patternsViewContainer: UIView!
    @IBOutlet weak var patternsCrayonsView: UIStackView!
    @IBOutlet weak var patternsDipperView: UIStackView!
    @IBOutlet weak var moreViewContainer: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var normalButton: UIImageView!
    @IBOutlet weak var patternsButton: UIImageView!
    @IBOutlet weak var moreButton: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit(){
        let nib = UINib(nibName: String(describing: ColoringPanel.self), bundle: Bundle.main)

        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {fatalError("Unable to convert nib")}

        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(view)
        
//        self.backgroundImage.image = AssetsManager.sharedInstance.getColoringPanelBackgroundImage()
//        self.foregroundImage.image = AssetsManager.sharedInstance.getColoringPanelForegroundImage()
//        
//        self.doneButton.setImage(AssetsManager.sharedInstance.getColoringPanelDoneButtonImage(), for: .normal)
//        self.doneButton.setImage(AssetsManager.sharedInstance.getColoringPanelDoneButtonImagePressed(), for: .highlighted)
//        
//        if let eraser = AssetsManager.sharedInstance.getColoringPanelEraserButtonImage(), let eraserButton = regularCrayonsView.viewWithTag(-1) as? UIImageView{
//            eraserButton.image = eraser
//        }
//        
//        resetCrayons()
//        addTapGestureRecognizerToCrayons()
//        
//        for (index, color) in AssetsManager.sharedInstance.colorsList.enumerated(){
//            let image = AssetsManager.sharedInstance.getColoringPanelDipperButtonImageFrom(color: color, pattern: nil)
//            if let button = regularDipperView.viewWithTag(index + 1) as? UIImageView{
//                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dipperTapped(tapGestureRecognizer:)))
//                button.image = image
//                button.isUserInteractionEnabled = true
//                button.addGestureRecognizer(tapGestureRecognizer)
//            }
//        }
//        
//        self.normalButton.image = AssetsManager.sharedInstance.getColoringPanelNormalButtonImage()
//        self.patternsButton.image = AssetsManager.sharedInstance.getColoringPanelPatternButtonImage()
//        self.moreButton.image = AssetsManager.sharedInstance.getColoringPanelNormalButtonImage()
        
//        self.regularViewContainer.backgroundColor = .red
//        self.regularCrayonsView.backgroundColor = .blue
//        self.regularDipperView.backgroundColor = .yellow
    }
    
//    func addTapGestureRecognizerToCrayons(){
//        for (index, color) in AssetsManager.sharedInstance.colorsList.enumerated(){
//            let image = AssetsManager.sharedInstance.getColoringPanelCrayonButtonImageFrom(color: color, pattern: nil)
//            if let button = regularCrayonsView.viewWithTag(index + 1) as? UIImageView{
//                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(crayonTapped(tapGestureRecognizer:)))
//                button.isUserInteractionEnabled = true
//                button.addGestureRecognizer(tapGestureRecognizer)
//            }
//        }
//    }
//    
//    func resetCrayons(){
//        for (index, color) in AssetsManager.sharedInstance.colorsList.enumerated(){
//            let image = AssetsManager.sharedInstance.getColoringPanelCrayonButtonImageFrom(color: color, pattern: nil)
//            if let button = regularCrayonsView.viewWithTag(index + 1) as? UIImageView{
//                button.image = image.addLeftPadding(20)
//            }
//        }
//    }
//    
//    @objc func crayonTapped(tapGestureRecognizer: UITapGestureRecognizer){
//        let imageView = (tapGestureRecognizer.view as! UIImageView)
//        let tappedColor = AssetsManager.sharedInstance.colorsList[imageView.tag - 1]
//        
//        resetCrayons()
//        
//        UIView.animate(withDuration: 1, delay: 0.1,
//                    usingSpringWithDamping: 0.9, initialSpringVelocity: 1,
//                    options: [],
//                    animations: {
//                        imageView.image = imageView.image?.addLeftPadding(0)
//                    },
//                    completion: nil)
//    }
    
    @objc func dipperTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let tappedColor = AssetsManager.sharedInstance.colorsList[(tapGestureRecognizer.view as! UIImageView).tag - 1]

    }
    
    @IBAction func onDone(_ sender: UIButton) {
        
        SoundsController.sharedInstance.playMenuSound()
    }
    
    @IBAction func onChangeColors(_ sender: UIButton) {
        
        SoundsController.sharedInstance.playMenuSound()
    }
}
