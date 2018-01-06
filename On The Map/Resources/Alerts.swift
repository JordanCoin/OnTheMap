//
//  Alerts.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/11/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation
import UIKit

struct Alerts {
    
    static func errorAlert(title: String, message: String, view: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        view.present(alert, animated: true, completion: nil)
    }
    
    enum ResponseError: Int, Error {
        
        case Unknown = 404
        case Unauthorized = 401
        
        var localizedDescription: String {
            
            switch self {
            case .Unknown:
                return NSLocalizedString("Check your internet connection, we couldn't connect to the server.", comment: "")
            case .Unauthorized:
                return NSLocalizedString("Your login credentials are invalid, please try again.", comment: "")
            }
        }
        
        var _code: Int { return self.rawValue }
    }
}
