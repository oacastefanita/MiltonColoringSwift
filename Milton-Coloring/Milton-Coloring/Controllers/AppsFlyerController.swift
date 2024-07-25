//
//  AppsflyerController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 17.02.2022.
//

import Foundation
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport
import UIKit

class AppsFlyerController:NSObject{
    public static let shared = AppsFlyerController()
    

    override init(){
        super.init()
        // Q7kjoJiEf2xvchatBgAic4
        AppsFlyerLib.shared().appsFlyerDevKey = "Q7kjoJiEf2xvchatBgAic4"
        AppsFlyerLib.shared().appleAppID = "1296911954"
    }
    
    func getAppsFlyerId() -> String{
        AppsFlyerLib.shared().getAppsFlyerUID()
    }
    
    func trackLogin(){
        AppsFlyerLib.shared().logEvent(AFEventLogin, withValues: nil)
    }
    
    func trackRegister(){
        AppsFlyerLib.shared().logEvent(AFEventCompleteRegistration, withValues: nil)
    }
    
    func trackStartTrial(){
        AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: nil)
    }
    
    func getIDFA() -> String? {
        // Check whether advertising tracking is enabled
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != ATTrackingManager.AuthorizationStatus.authorized  {
                return nil
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
                return nil
            }
        }

        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    func showIDFA(in viewController:UIViewController){
        if #available(iOS 14, *), !UserDefaults.standard.bool(forKey: "IDFAPrompt") {
            UserDefaults.standard.set(true, forKey: "IDFAPrompt")
            let alert = UIAlertController(title: "Get the most out of Milton", message:"We need this permission to ensure we can personalize your experience, but we don't store any data about you", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                AnalyticsController.shared.trackPermissionActivated(type: .att_access)
                AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
                ATTrackingManager.requestTrackingAuthorization { (status) in
                    if status == .authorized{
                        AnalyticsController.shared.trackPermissionAccepted(type: .att_access)
                        
                    }else if status == .denied{
                        AnalyticsController.shared.trackPermissionDenied(type: .att_access)
                    }
                    
                    AnalyticsController.shared.identifyIDFA()
                    AnalyticsController.shared.appsflyerCompleted = true
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: { action in
                AnalyticsController.shared.appsflyerCompleted = true
            }))
                            
            viewController.present(alert, animated: true, completion: nil)
        }else if(UserDefaults.standard.bool(forKey: "IDFAPrompt")){
            AnalyticsController.shared.identifyIDFA()
            AnalyticsController.shared.appsflyerCompleted = true
        }else{
            AnalyticsController.shared.appsflyerCompleted = true
        }
    }
    
}
