//
//  Student.swift
//  On The Map
//
//  Created by Jordan Jackson on 12/22/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation

struct Student {
    
    var objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let location: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    
    init() {
        objectId = ""
        uniqueKey = ""
        firstName = ""
        lastName = ""
        location = ""
        mediaURL = ""
        latitude = 0
        longitude = 0
    }
    
    init?(dictionary: [String:AnyObject]) {
        
        guard let objectId = dictionary[Constants.JSONResponseKeys.ObjectId] as? String,
            let uniqueKey = dictionary[Constants.JSONResponseKeys.UniqueKey] as? String,
            let firstName = dictionary[Constants.JSONResponseKeys.FirstName] as? String,
            let lastName = dictionary[Constants.JSONResponseKeys.LastName] as? String,
            let location = dictionary[Constants.JSONResponseKeys.MapString] as? String,
            let mediaURL = dictionary[Constants.JSONResponseKeys.MediaURL] as? String,
            let latitude = dictionary[Constants.JSONResponseKeys.Latitude] as? Double,
            let longitude = dictionary[Constants.JSONResponseKeys.Longitude] as? Double
            else {
                print("Uable to parse student dictionary. Check json input or parsing method")
                return nil
        }

        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func studentsFromResults(results: [[String: AnyObject]]) {
        
        for result in results {
            if let student = Student(dictionary: result) {
                print(student.location)
                StudentDataSource.sharedInstance.studentData.append(student)
//                print("Student array count: ", StudentDataSource.sharedInstance.studentData.count)
            }
        }
    }
}
