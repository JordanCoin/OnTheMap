//
//  MainTabBarController.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/16/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}
