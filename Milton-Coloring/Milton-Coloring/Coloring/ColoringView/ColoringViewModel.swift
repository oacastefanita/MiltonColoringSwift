//
//  ColoringViewModel.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 22.07.2024.
//

import SwiftUI

enum ColoringPanelType: Int{
    case regular = 0
    case patterns
    case dippers
}

class ColoringViewModel: ObservableObject {
    
    @Published var colorinPanelType:ColoringPanelType = .regular
    
    @Published var selectedCrayon: Int = 1
    @Published var selectedDipper: Int = -1
    
    @Published var backgroundImage: UIImage
    @Published var foregroundImage: UIImage
    @Published var eraserImage: UIImage
    @Published var regularButton: UIImage
    @Published var patternsButton: UIImage
    @Published var moreButton: UIImage
    @Published var doneButton: UIImage
    
    init() {
        backgroundImage = AssetsManager.sharedInstance.getColoringPanelBackgroundImage()
        foregroundImage = AssetsManager.sharedInstance.getColoringPanelForegroundImage()
        eraserImage = AssetsManager.sharedInstance.getColoringPanelEraserButtonImage()
        regularButton = AssetsManager.sharedInstance.getColoringPanelRegularButtonImage()
        patternsButton = AssetsManager.sharedInstance.getColoringPanelPatternButtonImage()
        moreButton = AssetsManager.sharedInstance.getColoringPanelMoreButtonImage()
        doneButton = AssetsManager.sharedInstance.getColoringPanelDoneButtonImage()
    }
    
    func getCrayons() -> [UIImage]{
        var images = [UIImage]()
        switch colorinPanelType {
        case .regular:
            for (index, color) in AssetsManager.sharedInstance.colorsList.enumerated(){
                images.append(AssetsManager.sharedInstance.getColoringPanelCrayonButtonImageFrom(color: color, pattern: nil))
            }
        case .patterns:
            for (index, pattern) in AssetsManager.sharedInstance.patternNames.enumerated(){
                images.append(AssetsManager.sharedInstance.getColoringPanelCrayonButtonImageFrom(color: nil, pattern: pattern))
            }
        case .dippers:
            for (index, color) in AssetsManager.sharedInstance.moreColorsList.enumerated(){
                
            }
        }
        return images
    }
    
    func getDippersCount() -> Int{
        return AssetsManager.sharedInstance.moreColorsList.count
    }
    
    func getDippers() -> [UIImage]{
        var images = [UIImage]()
        switch colorinPanelType {
        case .regular:
            for (index, color) in AssetsManager.sharedInstance.colorsList.enumerated(){
                images.append(AssetsManager.sharedInstance.getColoringPanelDipperButtonImageFrom(color: color, pattern: nil))
            }
        case .patterns:
            for (index, pattern) in AssetsManager.sharedInstance.patternNames.enumerated(){
                images.append(AssetsManager.sharedInstance.getColoringPanelDipperButtonImageFrom(color: nil, pattern: pattern))
            }
        case .dippers:
            for (index, color) in AssetsManager.sharedInstance.moreColorsList.enumerated(){
                images.append(AssetsManager.sharedInstance.getColoringPanelDipperButtonImageFrom(color: color, pattern: nil))
            }
        }
        
        return images
    }
    
    func changeMode(){
        switch colorinPanelType {
        case .regular:
            colorinPanelType = .patterns
            selectedCrayon = 1
            selectedDipper = -1
        case .patterns:
            colorinPanelType = .dippers
            selectedCrayon = 1
            selectedDipper = -1
        case .dippers:
            colorinPanelType = .regular
            selectedCrayon = -1
            selectedDipper = 0
        }
    }
    
    func selectedCrayon(_ index: Int){
        selectedCrayon = index
        selectedDipper = -1
    }
    
    func selectedDipper(_ index: Int){
        selectedCrayon = -1
        selectedDipper = index
    }
}
