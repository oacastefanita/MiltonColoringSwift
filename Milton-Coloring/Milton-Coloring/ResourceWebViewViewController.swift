//
//  ResourceWebViewViewController.swift
//  MiltonStorybook
//
//  Created by Stefanita Oaca on 03.04.2024.
//

import Foundation
import WebKit
import UIKit

class ResourceWebViewViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var url: URL!
    @IBOutlet weak var webView: WKWebView!
    
    var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImage.backgroundColor = AssetsManager.sharedInstance.getResourcesBackgroundColor()
        self.backgroundImage.image = AssetsManager.sharedInstance.getResourcesBackgroundImage()
        
        // Load the URL into the web view
        if let url = url {
            // Create a URLRequest with custom headers
            var request = URLRequest(url: url)
            request.addValue("YourCustomHeaderValue", forHTTPHeaderField: "YourCustomHeaderKey")
            webView.navigationDelegate = self
            // Load the request
            webView.load(request)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadButtons(){
        if let button = AssetsManager.sharedInstance.getResourcesCloseButton(){
            closeButton = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
#if os(iOS)
            closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
#else
            closeButton.addTarget(self, action: #selector(onClose), for: .primaryActionTriggered)
#endif
        }
    }
    
    @objc func onClose() {
        SoundsController.sharedInstance.playMenuSound()
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Handle custom headers here if needed
        decisionHandler(.allow)
    }
}
