//
//  StudentLocation.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/5/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation
import UIKit

struct StudentLocation: Decodable {
    
    let objectID: String?
    let uniqueKey: String?
    let firstName: String
    let lastName: String
    let mapString: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let updatedAt: String?
    let createdAt: String?
    
}

extension StudentLocation: Equatable {
    static func ==(lhs: StudentLocation, rhs: StudentLocation) -> Bool {
        return lhs.uniqueKey == rhs.uniqueKey
    }
}

/* Convenience methods and variables for accessing and altering the collection of StudentLocations */

struct StudentLocationCollection {
    
    static var totalLocations: [StudentLocation] {
        return storage().locations
    }
    
    static func add(location: StudentLocation) {
        storage().locations.append(location)
    }
    
    static func sort() {
        
        var dateArray: [Date] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm.ssZ"
        
        for location in totalLocations {
            if let updatedAt = location.updatedAt {
                print(updatedAt)
//                print(formatter.date(from: updatedAt))
//                if let date = formatter.date(from: updatedAt) {
//                    print(date)
//                    dateArray.append(date)
//                }
            }
        }

        let sorted = dateArray.sorted(by: { $0.compare($1) == .orderedDescending })
        print(sorted)
    }
    
    static func count() -> Int {
        return storage().locations.count
    }
    
    static func storage() -> AppDelegate {
            let object = UIApplication.shared.delegate
            return object as! AppDelegate
    }
}
