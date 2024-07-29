//
//  ColoringViewController.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 11.07.2024.
//

import UIKit
import SwiftUI

class ColoringViewController: UIViewController {
    @IBOutlet weak var backgroundImage: UIImageView!
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
        self.backgroundImage.backgroundColor = .white
        self.backgroundImage.image = coloringBook.icon
        
        loadButtons()
        addColoringPanel()
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
}
