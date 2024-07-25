//
//  AnalyticsController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 17.02.2022.
//

import Foundation
import Segment
import AdSupport

enum UserTraits:String{
    case regPlatform = "Platform"
    case appsflyerId = "appsflyerId"
    case idfa = "idfa"
    case idfv = "idfv"
    case ip = "ip"
    case id = "id"
}

enum EventNames:String{
    case appOpened = "App Opened"
    
    //Permission
    case permissionsActivated = "Permissions - Prompt Activated"
    case permissionsAccepted = "Permissions - Accepted"
    case permissionsDenied = "Permissions - Denied"
}

enum EventProperties:String{
    case type = "type"
}

enum PremissionPrompTypes: String{
    case push = "push"
    case photo = "photo"
    case mic = "mic"
    case camera = "camera"
    case att_access = "att-access"
}

class AnalyticsEvent{
    let name:String
    let properties: [String: Any]?
    
    init(name: String, properties: [String: Any]?){
        self.name = name
        self.properties = properties
    }
}

class AnalyticsController:NSObject{
    
    public static let shared = AnalyticsController()
    var userID = ""
    
    private var storingAnalytics = true
    var appsflyerCompleted = false{
        didSet{
            if appsflyerCompleted && experimentsCompleted{
                startSendingEvents()
            }
        }
    }
    
    var experimentsCompleted = false{
        didSet{
            if appsflyerCompleted && experimentsCompleted{
                startSendingEvents()
            }
        }
    }
    
    var storedEvents = [AnalyticsEvent]()
    var storedTraits = [String: Any]()
    
    override init(){
        super.init()
    }
    
    func setup(){
        //Production key
        //ZyODWlMaQmNfIjm7rXD3BItxhCBmKiws
        
        //Dev key
        //ZyODWlMaQmNfIjm7rXD3BItxhCBmKiws
        
        #if DEBUG
        let configuration = AnalyticsConfiguration(writeKey: "ZyODWlMaQmNfIjm7rXD3BItxhCBmKiws")
        #else
        let configuration = AnalyticsConfiguration(writeKey: "ZyODWlMaQmNfIjm7rXD3BItxhCBmKiws")
        #endif
                
        configuration.enableAdvertisingTracking = true
        configuration.adSupportBlock = { () -> String in
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = true
        Analytics.setup(with: configuration)
    }
    
    private func identifyTraits(_ dict:Dictionary<String, Any>){
        if storingAnalytics{
            for key in dict.keys{
                storedTraits[key] = dict[key]
            }
        }else{
            Analytics.shared().identify(userID, traits: dict)
        }
    }
    
    func identifyUserData(){
        userID = ExperimentsController.shared.deviceId
        identifyTraits([UserTraits.id.rawValue : userID ,
                        UserTraits.regPlatform.rawValue : "iOS",
                        UserTraits.idfa.rawValue : AppsFlyerController.shared.getIDFA() ?? "",
                        UserTraits.idfv.rawValue : UIDevice.current.identifierForVendor?.uuidString ?? "" ,
                        UserTraits.appsflyerId.rawValue : AppsFlyerController.shared.getAppsFlyerId(),
                       ])
    }
    
    func identifyExperiements(_ dict:Dictionary<String, Any>){
        identifyTraits(dict)
    }
    
    func identifyIDFA(){
        identifyTraits([
            UserTraits.idfa.rawValue : AppsFlyerController.shared.getIDFA() ?? ""
                       ])
    }
    
    private func trackEvent(_ name: String, properties:[String:Any]){
        if storingAnalytics{
            addToEventsList(name, properties: properties)
        }else{
            Analytics.shared().track(name, properties: properties)
            print("TRACKED EVENT: \"\(name)\" WITH PROPERTIES:\n \"\(properties))\"")
        }
    }
    
    private func trackEvent(_ name: String){
        if storingAnalytics{
            addToEventsList(name, properties: nil)
        }else{
            Analytics.shared().track(name, properties: nil)
            print("TRACKED EVENT: \"\(name)\" ")
        }
    }
    
    private func addToEventsList(_ name: String, properties:[String:Any]? ){
        let event = AnalyticsEvent(name: name, properties: properties)
        storedEvents.append(event)
    }
    
    private func startSendingEvents(){
        setup()
        storingAnalytics = false
        
        for event in storedEvents{
            Analytics.shared().track(event.name, properties: event.properties)
            print("TRACKED EVENT: \"\(event.name)\" WITH PROPERTIES:\n \"\(event.properties))\"")
        }
        storedEvents = [AnalyticsEvent]()
        
        Analytics.shared().identify(userID)
        Analytics.shared().identify(userID, traits: storedTraits)
        storedTraits = [String: Any]()
    }
    
    func trackAppOpened(){
        trackEvent(EventNames.appOpened.rawValue)
    }
    
    func trackPermissionActivated(type:PremissionPrompTypes){
        trackEvent(EventNames.permissionsActivated.rawValue, properties:
                    [EventProperties.type.rawValue: type.rawValue
                    ])
    }
    
    func trackPermissionDenied(type:PremissionPrompTypes){
        trackEvent(EventNames.permissionsDenied.rawValue, properties:
                    [EventProperties.type.rawValue: type.rawValue
                    ])
    }
    
    func trackPermissionAccepted(type:PremissionPrompTypes){
        trackEvent(EventNames.permissionsAccepted.rawValue, properties:
                    [EventProperties.type.rawValue: type.rawValue
                    ])
    }
    
}
