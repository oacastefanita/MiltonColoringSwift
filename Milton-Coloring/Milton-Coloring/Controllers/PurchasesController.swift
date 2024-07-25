//
//  PurchasesController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 17.02.2022.
//

import Foundation
//#if !targetEnvironment(macCatalyst)
import Purchases
//#elseif

//#endif
import Combine

enum OfferingIdentifiers:String{
    case def = "Default"
}

//#if !targetEnvironment(macCatalyst)
class PurchasesController: NSObject, PurchasesDelegate {
    var packages: [Purchases.Package] = []
    var purchaserInfo: Purchases.PurchaserInfo? = nil
    var hasPro: Bool = false
    
    var offerings: [String : Purchases.Offering] = [:]
    
    static let shared  = PurchasesController()
    
    func configure() {
        Purchases.debugLogsEnabled = true
        Purchases.automaticAppleSearchAdsAttributionCollection = true
        Purchases.configure(withAPIKey: "appl_hyfHoJbvuiqXOLhzkHQAkSAgMWY")
        Purchases.shared.delegate = self
        
        Purchases.shared.collectDeviceIdentifiers()
        Purchases.shared.setAppsflyerID(AppsFlyerController.shared.getAppsFlyerId())
                
        Purchases.shared.purchaserInfo { [weak self] (purchaserInfo, error) in
            if let purchaserInfo = purchaserInfo {
                self?.purchaserInfo = purchaserInfo
            }
        }
        Purchases.shared.offerings { [weak self] (offerings, error) in
            if let offerings = offerings {
                self?.offerings = offerings.all
                self?.packages = offerings.current?.availablePackages ?? []
                self?.setupPackagesForCurrentExperiment()
            }
        }
    }
     
    //each experiments has it's own offering which has separate packages
    func setupPackagesForCurrentExperiment(){
        self.packages = offerings[OfferingIdentifiers.def.rawValue]?.availablePackages ?? []
        print("Packages count:\(self.packages.count)")
        
        self.packages.sort {
            $0.packageType.rawValue < $1.packageType.rawValue
        }
    }
    
    func getPackageWithId(_ id: String) -> Purchases.Package?{
        for package in self.packages{
            if package.product.productIdentifier == id{
                return package
            }
        }
        
        return nil
    }
    
    func set(userId: String){
        print("REVENUECAT USER:\(userId)")
        Purchases.shared.logIn(userId) { [weak self] (purchaserInfo, created,error) in
            if let purchaserInfo = purchaserInfo {
                self?.purchaserInfo = purchaserInfo
            }
            if let error = error {
                print("Failed to identify user: \(error)")
            }
        }
        
    }
    
    func reset(){
        print("REVENUECAT USER RESET")
        Purchases.shared.logOut { [weak self] (purchaserInfo, _) in
            if let purchaserInfo = purchaserInfo {
                self?.purchaserInfo = purchaserInfo
            }
        }
    }
    
    override init() {
        super.init()
    }

    
    func purchase(package: Purchases.Package, onComplete: @escaping (Error?) -> ()) {
        Purchases.shared.purchasePackage(package) { [weak self] (transation, purchaserInfo, error, isCancelled)  in
            if let purchaserInfo = purchaserInfo {
                self?.purchaserInfo = purchaserInfo
            }
            onComplete(error)
        }
    }
    
    func restorePurchases(onComplete: @escaping (Error?) -> ()) {
        Purchases.shared.restoreTransactions { [weak self] (purchaserInfo, error) in
            if let purchaserInfo = purchaserInfo {
                self?.purchaserInfo = purchaserInfo
            }
            onComplete(error)
        }
    }
    
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        self.purchaserInfo = purchaserInfo
    }
    
    func purchases(_ purchases: Purchases, shouldPurchasePromoProduct product: SKProduct, defermentBlock makeDeferredPurchase: @escaping RCDeferredPromotionalPurchaseBlock) {
        makeDeferredPurchase { (transaction, info, error, cancelled) in
            
        }
    }
}
//#else
//class PurchasesController: NSObject{
//    static let shared  = PurchasesController()
//    
//    func configure() {
//    
//    }
//    func getPackageWithId(_ id: String) -> String?{
//        
//        return ""
//    }
//    
//    func purchase(package: String, onComplete: @escaping (Error?) -> ()) {
//        
//    }
//}
//
//#endif
