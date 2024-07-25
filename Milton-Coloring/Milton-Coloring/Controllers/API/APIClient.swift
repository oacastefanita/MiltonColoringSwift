//
//  APIClient.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 03.01.2022.
//

import UIKit

let API = APIClient.sharedInstance
let kBaseURL = "https://us-central1-milton-267410.cloudfunctions.net/"

class APIClient: Api {
    @objc public static let sharedInstance = APIClient()
 
    init() {
        super.init(baseURL: kBaseURL)
        
        completionHandlerLog = { (req, resp) in
            #if DEBUG
            print(req)
            print(resp)
            #endif
        }
    }
    
    func getURL(completionHandler:((Bool, [String:Any]?) -> Void)?) {
        doRequest("getColoringDev", method: .post, parameters: nil) { (success, data) in
            if success {
                completionHandler?(true,data)
            }
            else {
                completionHandler?(success,data)
            }
        }
    }
    
    func downloadFile(_ fromURL: String, progress:@escaping ((Float) -> Void), completionHandler: ((Bool, String) -> Void)?) {
        if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first, let name = fromURL.components(separatedBy: "/").last?.components(separatedBy: "?").first{
            let filePath = documentsPathString + "/" + name
            if let url = URL(string: filePath){
                print("DOWNLOAD PATH: " + filePath)
                downloadFile(fromURL, atPath: url.path, progress: progress,completionHandler: completionHandler)
            }
        }
    }
}
    
