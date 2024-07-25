//
//  InAppPurchases.swift
//  MiltonPuzzles
//
//  Created by Marius Avram on 2/24/22.
//

import UIKit
import Zip

class InAppPurchases: NSObject {
    static let shared  = InAppPurchases()
    
    let purchasesSubpath = "Milton/InAppPurchases/"
    let purchasesFileName = "InAppPurchases.plist"
        
    func load() {
        if ExperimentsController.shared.showIAP(){
            let fileURL = documentsDirectory.appendingPathComponent(purchasesSubpath + purchasesFileName)
            guard let dict = NSDictionary(contentsOfFile: fileURL.path) else {
                return
            }
            if let puzzlesDict = dict["ColoringBooks"] as? [[String:Any]] {
                for dict in puzzlesDict {
                    let puzzle = ColoringBook(dictionary: dict)
                    AssetsManager.sharedInstance.coloringBooks.append(puzzle)
                }
            }
        }
    }
    
    func bookLocked(_ book: ColoringBook) -> Bool {
        return false
        var isDirectory : ObjCBool = true
        let destPath = documentsDirectory.path + "/Milton/coloringbooks/\(book.name)"
        if FileManager.default.fileExists(atPath: destPath, isDirectory: &isDirectory){
            return false
        }
        return true
    }
    
    func downloadBook(book:ColoringBook, completionHandle:((Bool, String) -> Void)?) {
        if !bookLocked(book) {
            completionHandle?(true,"already downloaded")
            return
        }
        if let id = book.purchaseId, var package = PurchasesController.shared.getPackageWithId(id){
            PurchasesController.shared.purchase(package: package, onComplete: {error in
                if error != nil{
                    completionHandle?(false, "Pruchase failed")
                }else{
                    let destPath = documentsDirectory.path + "/Milton/coloringbooks/"
                    if let url = book.url {
                        APIClient.sharedInstance.downloadFile(url, progress: {progress in
                        }, completionHandler: {downloadSuccess, path in
                            if downloadSuccess{
                                if let pathURL = URL(string: path) {
                                    do {
                                       
                                        try Zip.unzipFile(pathURL, destination: URL(fileURLWithPath: destPath), overwrite: true, password: "654321", progress: { (progress) -> () in
                                            print(progress)
                                            if progress == 1{
                                                if let completion = completionHandle{
                                                    completion(true, "Success")
                                                }
                                            }
                                        }, fileOutputHandler: {(file) -> () in
                                            
                                        }) // Unzip

                                    }
                                    catch {
                                        completionHandle?(false, "Uzip Failed")
                                    }
                                }
                            }else{
                                completionHandle?(false, "Download failed")
                            }
                        })
                    }
                }
            })
        }
    }
}
