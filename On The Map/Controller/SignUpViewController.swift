//
//  SignUpViewController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/9/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit
import WebKit

class SignUpViewController: UIViewController, UIWebViewDelegate, WKUIDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadWebView(URL(string: Constants.SignUpURL)!) { (success, savedData, errorString) in
            if success {
                Client.sharedInstance().webLogin(savedData, { (success, errorString, sessionID) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alert = Alerts.errorAlert(title: "Error creating account!", message: errorString)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    // Load Web View
    
    func loadWebView(_ url: URL, _ completion: @escaping (_ success: Bool, _ data: Data, _ errorString: String?) -> Void) {

        webView.uiDelegate = self
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            if error == nil {
                performUIUpdatesOnMain {
                    self.webView.load(request)
                    completion(true, data, error?.localizedDescription)
                }
            }
            
            
            // MARK: - Method to log in from web view request to Udacity API.
        }
        task.resume()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    @IBAction func doneTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
