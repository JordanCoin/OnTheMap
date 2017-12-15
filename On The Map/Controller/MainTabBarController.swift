//
//  MainTabBarController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/16/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var sessionID: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func completeLogout() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutTouched(_ sender: Any) {
        Client.sharedInstance().logout({ (success, error) in
            if success {
                performUIUpdatesOnMain {
                    self.completeLogout()
                }
            }
        })
    }
    
    @IBAction func refreshTouched(_ sender: Any) {
        // PUT method to refresh and reload map and table
        
        // If success, reload table and maps
        
        // If fails, display alert
        let alert = Alerts.errorAlert(title: "Check your network!", message: "Could not load Data")
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addTouched(_ sender: Any) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "LocationNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
    
}
