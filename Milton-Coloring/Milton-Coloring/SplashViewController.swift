//
//  SplashViewController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 06.01.2022.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet weak var loadedImage: UIImageView!
    
    @IBOutlet weak var downloadedTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadedTrailingConstraint.constant = self.view.frame.size.width
        
        startAssetsDownload()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsController.shared.identifyUserData()
        AnalyticsController.shared.trackAppOpened()
        ExperimentsController.shared.getExperiments()
        AppsFlyerController.shared.showIDFA(in: self)
    }
    
    func startAssetsDownload(){
        AssetsManager.sharedInstance.startAssetsDownload { normalizedPerc in
            self.downloadedTrailingConstraint.constant = self.view.frame.size.width - self.view.frame.size.width * CGFloat(normalizedPerc)
        } completionHandle: { success, errorString in
            if success{
                self.presentMainMenu()
            }else{
                self.presentAlertWithTitle(title: "Error", message: errorString, options: "Retry", completion: { index in
                    self.startAssetsDownload()
                })
                print("error")
            }
            
            return nil
        }
    }
    
    func presentMainMenu(){
        AssetsManager.sharedInstance.loadMenuResources(){ success in
            self.performSegue(withIdentifier: "MainMenuFromSplash", sender: self)
        }
        
    }
}
