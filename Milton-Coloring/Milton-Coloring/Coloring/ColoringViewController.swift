//
//  ColoringViewController.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 11.07.2024.
//

import UIKit
import SwiftUI
import TouchDraw

class ColoringViewController: UIViewController, ColoringPanelDelegate {
    @IBOutlet weak var backgroundImage: PassThroughImageView!
    @IBOutlet weak var coloringPanelContainer: UIView!
    
    var coloringBook: ColoringBook!
    
    var startDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDate = Date()
        StatisticsController.shared.addEvent(StatisticEntry(eventType: .bookStarted))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        StatisticsController.shared.addEvent(StatisticEntry(eventType: .bookClosed, duration: Date().timeIntervalSince(startDate)))
    }
    
    func initView(){
        addColoringLayers()
        
        self.backgroundImage.backgroundColor = .clear
        self.backgroundImage.image = coloringBook.icon
        self.view.bringSubviewToFront(self.backgroundImage)
        
        addColoringPanel()
        loadButtons()
    }
        
    func addColoringPanel(){
        let childView = UIHostingController(rootView: ColoringPanelView(viewModel: ColoringPanelViewModel(delegate: self)))
        addChild(childView)
        childView.view.frame = coloringPanelContainer.bounds
        coloringPanelContainer.addConstrained(subview: childView.view)
        childView.didMove(toParent: self)
    }
    
    func loadButtons(){
        if let button = AssetsManager.sharedInstance.getMainMenuCloseButton(){
            let close = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
            close.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        }
    }
    
    @objc func onClose() {
        SoundsController.sharedInstance.playMenuSound()
        self.navigationController?.popViewController(animated: true)
    }
    
    func addColoringLayers() {
        for (index, item) in coloringBook.items.enumerated(){
            let subview = addColorableView(using: item, superView: self.view)
        }
    }
    
    func addColorableView(using item:ColoringBookItem, superView: UIView) -> MaskedView{
        let aspect = AssetsManager.sharedInstance.coloringDesignSize.width / AssetsManager.sharedInstance.coloringDesignSize.height
        
//        let subview = ColorableView(frame: CGRectZero, image: item.texture!)
//        let subview = RevealImageView(frame: CGRectZero)
//        subview.backgroundColor = AssetsManager.sharedInstance.getPatternColor(named: "clouds")
        
        let subview = MaskedView(frame: CGRectZero, image: item.texture!)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.isUserInteractionEnabled = true
        
        superView.addSubview(subview)
        let x = self.view.frame.size.height * aspect * item.position.x
        let y = self.view.frame.size.height * item.position.y
        let w = self.view.frame.size.height * aspect * item.size.width
        let h = self.view.frame.size.height * item.size.height
                
        subview.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: x).isActive = true
        subview.topAnchor.constraint(equalTo: superView.topAnchor, constant: y).isActive = true

        subview.widthAnchor.constraint(equalToConstant: w).isActive = true
        subview.heightAnchor.constraint(equalToConstant: h).isActive = true
        
        return subview
    }
    
    func didChangeColoringSelection(type: ColoringType, color: UIColor?, pattern: UIColor?) {
        for view in self.view.subviews{
            (view as? MaskedView)?.coloringSelectionChanged(type: type, color: color, pattern: pattern)
        }
    }
}
