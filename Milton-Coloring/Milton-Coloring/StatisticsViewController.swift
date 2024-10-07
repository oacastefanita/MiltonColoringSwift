//
//  StatisticsViewController.swift
//  MiltonStorybook
//
//  Created by Stefanita Oaca on 23.01.2024.
//

import Foundation
import UIKit

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var lblStatistics: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImage.backgroundColor = AssetsManager.sharedInstance.getStatisticsBackgroundColor()
        self.backgroundImage.image = AssetsManager.sharedInstance.getStatisticsBackgroundImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lblStatistics.textColor = AssetsManager.sharedInstance.getStatisticsFontColor()
        lblStatistics.text = "Your child has entered \(StatisticsController.shared.numberOfSessions) coloring books \n The total time spent coloring is \(StatisticsController.shared.totalSessionDurationInMin) mins averaging \(StatisticsController.shared.averageSessionDurationInMin) mins per book"
        loadButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func loadButtons(){
        if let button = AssetsManager.sharedInstance.getStatisticsCloseButton(){
            let settings = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
#if os(iOS)
            settings.addTarget(self, action: #selector(onClose), for: .touchUpInside)
#else
            settings.addTarget(self, action: #selector(onClose), for: .primaryActionTriggered)
#endif
        }
    }
    
    @objc func onClose() {
        SoundsController.sharedInstance.playMenuSound()
        self.navigationController?.popViewController(animated: true)
    }
}
