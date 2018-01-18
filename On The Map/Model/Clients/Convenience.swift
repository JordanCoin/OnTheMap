//
//  Convenience.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/16/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit
import Foundation
import MapKit

extension Client {
    
    // MARK: Udacity Login Authentication (POST) Method
    
    func getUserId(_ username: String, _ password: String, _ completionForSession: @escaping (_ userId: String?, _ errorString: String?) -> Void) {
        
        let jsonBody = "{\"\(Constants.JSONBodyKeys.Udacity)\": {\"\(Constants.JSONBodyKeys.Username)\": \"\(username)\", \"\(Constants.JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        let _ = taskForUdacityPOST(Constants.Methods.UdacitySession, jsonBody: jsonBody) { (results, error) in
            
            guard let results = results,
                let result = results[Constants.JSONResponseKeys.Account] as? [String: AnyObject] else {
                    completionForSession(nil, error?.localizedDescription)
                    return
            }
            
            if let userId = result[Constants.JSONResponseKeys.AccountKey] as? String {
                // we know we had a successful request if we get here
                self.userKey.set(userId, forKey: "key")
                completionForSession(userId, nil)
                return
            } else {
                completionForSession(nil, error?.localizedDescription)
            }
        }
    }
    
    // MARK: Udacity GET User Info Method
    func getUdacityUserInfo(userId: String, completionHandlerGETUserInfo: @escaping (_ result: User?, _ errorString: String?) -> Void) {
        
        if let method = substituteKeyInMethod(Constants.Methods.UdacityPublicUserData, key: "user_id", value: userId) {
            
            let _ = taskForUdacityGETMethod(method) { (results, error) in
                
                // check to see if there was an error returned
                guard error == nil else {
                    completionHandlerGETUserInfo(nil, Alerts.ResponseError.Unauthorized.localizedDescription)
                    return
                }
                
                guard let results = results,
                    let userInfo = results["user"] as? [String: AnyObject],
                    let firstName = userInfo[Constants.JSONResponseKeys.UdacityFirstName] as? String,
                    let lastName = userInfo[Constants.JSONResponseKeys.UdacityLastName] as? String
                    else {
                        completionHandlerGETUserInfo(nil, Alerts.ResponseError.Unknown.localizedDescription)
                        return
                }
                
                DispatchQueue.main.async {
                    // create a User object to be passed back via the completionHandler
                    let user = User(firstName: firstName, lastName: lastName, userId: userId)
                    completionHandlerGETUserInfo(user, nil)
                }
            }
        }
    }
    
    // MARK: - GET Student Location Method
    func getStudentLocation(_ completionHandlerForGETStudentLoc: @escaping (_ results: [[String: AnyObject]]?, _ error: NSError?) -> Void) {
        
        let _ = taskForGETMethod(Constants.Methods.ParseStudentLocation) { (results, error) in
            
            // check to see if there was an error returned
            if let error = error {
                completionHandlerForGETStudentLoc(nil, error)
            } else {
                
                // if there was no error we know we had a successful response
                guard let result = results?[Constants.JSONResponseKeys.Results] as? [[String: AnyObject]] else { return }
                
                completionHandlerForGETStudentLoc(result, nil)
            }
        }
    }
    
    // MARK: - POST Student Location Method
    func postStudentLocation(userId: String, firstName: String, lastName: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, location: String, completionHandlerForPOSTStudentLoc: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        // create the jsonBody for the request and define the method to be used
        let jsonBody = "{\"\(Constants.JSONBodyKeys.UniqueKey)\": \"\(userId)\", \"\(Constants.JSONBodyKeys.FirstName)\": \"\(firstName)\", \"\(Constants.JSONBodyKeys.LastName)\": \"\(lastName)\",\"\(Constants.JSONBodyKeys.MapString)\": \"\(location)\", \"\(Constants.JSONBodyKeys.MediaURL)\": \"\(mediaURL)\",\"\(Constants.JSONBodyKeys.Latitude)\": \(latitude), \"\(Constants.JSONBodyKeys.Longitude)\": \(longitude)}"
        
        let _ = taskForPOSTMethod(Constants.Methods.ParseStudentLocation, jsonBody: jsonBody) { (results, error) in
            
            // check to see if there was an error returned
            guard (error == nil) else {
                completionHandlerForPOSTStudentLoc(nil, error)
                return
            }
            completionHandlerForPOSTStudentLoc(1, nil)
        }
    }
   
    // MARK: Udacity Authentication (DELETE) Method
    func logout(_ completionHandlerForSession: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        let _ = taskForUdacityDELETESession(Constants.Methods.UdacitySession) { (results, error)
            in
            
            guard (error == nil) else {
                completionHandlerForSession(nil, error)
                return
            }
            
            self.userKey.removeObject(forKey: "key")
            completionHandlerForSession(1, nil)
        }
    }
    
}
