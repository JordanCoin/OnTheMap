//
//  Alerts.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/11/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation
import UIKit

func errorAlert(title: String, message: String, view: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    view.present(alert, animated: true, completion: nil)
}
