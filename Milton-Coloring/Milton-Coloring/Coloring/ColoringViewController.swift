//
//  ColoringViewController.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 11.07.2024.
//

import UIKit
import SwiftUI
import TouchDraw

class ColoringViewController: UIViewController {
    @IBOutlet weak var backgroundImage: PassThroughImageView!
    @IBOutlet weak var coloringPanelContainer: UIView!
    
    var coloringBook: ColoringBook!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initView()
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
        let childView = UIHostingController(rootView: ColoringPanelView(viewModel: ColoringPanelViewModel()))
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
    
    func addColorableView(using item:ColoringBookItem, superView: UIView) -> ColorableView{
        let aspect = AssetsManager.sharedInstance.coloringDesignSize.width / AssetsManager.sharedInstance.coloringDesignSize.height
        
        let subview = ColorableView(frame: CGRectZero, image: item.texture!)
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
}
