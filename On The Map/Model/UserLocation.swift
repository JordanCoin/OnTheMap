//
//  UserLocation.swift
//  On The Map
//
//  Created by Jordan Jackson on 1/17/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import Foundation

struct UserLocation {
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    var createdAt: String
    var updatedAt: String
    
    // MARK: Initializers
    
    init(dictionary: [String: AnyObject]) {
        objectId = dictionary[Constants.ParseResponseKeys.objectID] as! String
        uniqueKey = dictionary[Constants.ParseResponseKeys.uniqueKey] as! String
        firstName = dictionary[Constants.ParseResponseKeys.firstName] as! String
        lastName = dictionary[Constants.ParseResponseKeys.lastName] as! String
        mapString = dictionary[Constants.ParseResponseKeys.mapString] as! String
        mediaURL = dictionary[Constants.ParseResponseKeys.mediaURL] as! String
        latitude = dictionary[Constants.ParseResponseKeys.latitude] as! Double
        longitude = dictionary[Constants.ParseResponseKeys.longitude] as! Double
        createdAt = dictionary[Constants.ParseResponseKeys.createdAt] as! String
        updatedAt = dictionary[Constants.ParseResponseKeys.updatedAt] as! String
        
    }
}
