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
        
        let request = URLRequest(url: URL(string: Constants.SignUpURL)!)
        performUIUpdatesOnMain {
            self.webView.load(request)
        }
    }
    
    @IBAction func doneTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
