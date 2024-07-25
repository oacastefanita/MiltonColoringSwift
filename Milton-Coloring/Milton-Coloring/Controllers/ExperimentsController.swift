//
//  ExperimentsController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 17.02.2022.
//

import Foundation
import UIKit
import DevCycle

enum ExperimentNames:String{
    case showIAP = "milton-games-show-iap"
}

enum ExperimentVariants:String{
    case control = "control"
    case on = "on"
    case off = "off"
}

class ExperimentsController:NSObject{
    public static let shared = ExperimentsController()
    
    var currentExperiments = Dictionary<String, Any>()
    var deviceId = ""
    
    var dvcClient: DVCClient?
    var dvcUser: DVCUser?

    override init(){
        super.init()
        setupDeviceId()
        getExperiments()
    }
    
    func getExperiments(){
        var key = "mobile-1315c97e-45eb-45db-a640-165093ccb8b9"// dev
#if DEBUG
        key = "mobile-1315c97e-45eb-45db-a640-165093ccb8b9"
#else
        key = "mobile-632977e8-fc77-4931-ac5c-0a3f007f228c"
#endif
        do{
            dvcUser = try DVCUser.builder().userId(deviceId).build()
            dvcClient = try DVCClient.builder().environmentKey(key).user(dvcUser!).build(){ err in
                if let error = err {
                    return print("Error initializing DVC: \(error)")
                }
                self.indentifyUser()
            }
        }catch{
            
        }
    }
    
    func indentifyUser(){
        do{
            try dvcClient!.identifyUser(user: dvcUser!) { err, variables in
                if let error = err {
                    return print("Error identifying User: \(error)")
                }
                self.setup(variables)
            }
        }catch{
            
        }
    }
    
    func setupDeviceId(){
        if let device = UserDefaults.standard.string(forKey: "DeviceID"){
            deviceId = device
        }else{
            deviceId = UUID().uuidString
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                deviceId = uuid
            }
            UserDefaults.standard.setValue(deviceId, forKey: "DeviceID")
        }
    }
    
    func setup(_ experiments: Dictionary<String, Variable>!){
        if experiments == nil{
            return
        }
        for key in experiments.keys{
            currentExperiments[key] = dvcClient?.variable(key: key, defaultValue: false).value
        }
        
        AnalyticsController.shared.experimentsCompleted = true
        AnalyticsController.shared.identifyExperiements(currentExperiments)
    }
    
    func showIAP() -> Bool{
        if let value = currentExperiments[ExperimentNames.showIAP.rawValue] as? Bool{
            UserDefaults.standard.setValue(value, forKey: ExperimentNames.showIAP.rawValue)
            return value
        }
        
        return UserDefaults.standard.bool(forKey: ExperimentNames.showIAP.rawValue)
    }
}
