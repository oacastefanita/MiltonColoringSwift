//
//  Api.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 03.01.2022.
//

import UIKit
import Alamofire

class Api: NSObject {
    
    var baseURL:String
    var customHeaders:[String:String]?
    
    public var completionHandlerLog:((String, String) -> Void)!
    
    public init(baseURL:String) {
        self.baseURL = baseURL
        super.init()
    }
    
    private let manager: Alamofire.Session = {
           let configuration = URLSessionConfiguration.default
           configuration.requestCachePolicy = .useProtocolCachePolicy
           configuration.timeoutIntervalForRequest = 35
        let evaluator = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: ["test.recordphonecalls.co" : DisabledTrustEvaluator()])
           return Alamofire.Session(configuration: configuration, serverTrustManager: evaluator)
       }()

    
    func doRequest(_ url:String, method:HTTPMethod, parameters:[String : Any]!, completionHandler:((Bool, [String : Any]?) -> Void)?) {
        let headers: HTTPHeaders = [
            "Authorization": "Basic dngtZ2FtZTp5VzZGa3ZZSjZPeV4=",
            "Accept": "application/json"
        ]
        
        let encoding = JSONEncoding(options: JSONSerialization.WritingOptions.sortedKeys)

        manager.request("\(self.baseURL)\(url)", method: method, parameters: parameters, encoding: encoding, headers: headers).responseJSON { response in
            
            if response.data != nil {
                if let responseString = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue) as String? {
                    self.completionHandlerLog("\(method.rawValue) RESPONSE:\(self.baseURL + url) \(Date())", "BODY:\(responseString)")
                }
            }
            else {
                self.completionHandlerLog("\(method.rawValue) RESPONSE:\(self.baseURL + url) \(Date())", "BODY: ")
            }
            
            if let callback = completionHandler {
                switch response.result {
                case .success(let value):
                    do {
                        if let dict = value as? NSDictionary {
                            callback(true, dict as? [String : Any])
                        }
                        else if let array = value as? NSArray {
                            callback(true,["root":array])
                        }
                        else if response.response?.statusCode == 204 {
                            callback(true,["root":"success"])
                        }
                        else {
                            callback(false,["error":"Invalid data format received from server."])
                        }
                    }
                case .failure(_):
                    do {
                        let error = self.handleError(response.result)
                        self.completionHandlerLog("ERROR", "\(error["error"]!)")
                        callback(false, error)
                    }
                }
            }
        }
    }
    
    func downloadFile(_ fromURL:String, atPath:String, progress:((Float) -> Void)?, completionHandler:((Bool, String) -> Void)?) {
        let destination: DownloadRequest.Destination = { _, _ in
            let url = URL(fileURLWithPath: atPath)
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }

        manager.download(fromURL, to: destination).downloadProgress { downloaded in
            if progress != nil {
                progress!(Float(downloaded.fractionCompleted))
            }
        }.response { response in
            if response.error == nil {
                if completionHandler != nil {
                    print("DOWNLOAD COMPLETED AT PATH: " + atPath)
                    completionHandler!(true, atPath)
                }
            }
            else {
                if completionHandler != nil {
                    completionHandler!(false, response.error.debugDescription)
                }
            }
        }
    }
    
    
    func handleError(_ result:Result<Any,AFError>) -> [String : Any] {
        switch result {
        case .failure(let error):
            do {
                return ["error": error.localizedDescription]
            }
        case .success(_):
            do {
            
            }
        }
        return ["error":"unknowng error occured"]
    }
}
