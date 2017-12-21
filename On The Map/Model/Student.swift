//
//  Student.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/5/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation
import UIKit

struct Student: Decodable {
    
    let objectID: String?
    var uniqueKey: String?
    let firstName: String
    let lastName: String
    let mapString: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let updatedAt: String?
    let createdAt: String?
}

/* Convenience methods and variables for accessing and altering the collection of StudentLocations */

struct StudentLocationCollection {
    
    static var totalLocations: [Student] {
        return storage().locations
    }
    
    static func add(location: Student) {
        storage().locations.append(location)
    }
    
    static func count() -> Int {
        return storage().locations.count
    }
    
    static func storage() -> AppDelegate {
        let object = UIApplication.shared.delegate
        return object as! AppDelegate
    }
}
