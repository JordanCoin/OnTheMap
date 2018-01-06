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
    
    func getSessionID(_ username: String, _ password: String, _ completionForSession: @escaping (_ sessionID: String?, _ errorString: String?) -> Void) {
        
        let jsonBody = "{\"\(Constants.JSONBodyKeys.Udacity)\": {\"\(Constants.JSONBodyKeys.Username)\": \"\(username)\", \"\(Constants.JSONBodyKeys.Password)\": \"\(password)\"}}"

        let _ = taskForUdacityPOST(Constants.Methods.UdacitySession, jsonBody: jsonBody) { (results, error) in
            
            guard let results = results,
                let result = results[Constants.JSONResponseKeys.Account] as? [String: AnyObject] else {
                    completionForSession(nil, error?.localizedDescription)
                    return
            }
            
            if let sessionID = result[Constants.JSONResponseKeys.AccountKey] as? String {
                // we know we had a successful request if we get here
                self.userKey.set(sessionID, forKey: "key")
                completionForSession(sessionID, nil)
                return
            } else {
                completionForSession(nil, error?.localizedDescription)

            }
        }
    }
    
    // MARK: - GET Student Location Method
    func getStudentLocation(_ completionHandlerForGETStudentLoc: @escaping (_ result: Student?, _ error: NSError?) -> Void) {
        
        let _ = taskForGETMethod(Constants.Methods.ParseStudentLocation) { (results, error) in
            
            // check to see if there was an error returned
            if let error = error {
                completionHandlerForGETStudentLoc(nil, error)
            } else {
                // if there was no error we know we had a successful response
                if let results = results?[Constants.JSONResponseKeys.Results] as? [[String:AnyObject]] {
                    let students = Student.studentsFromResults(results: results)
                    completionHandlerForGETStudentLoc(students, nil)
                } else {
                   completionHandlerForGETStudentLoc(nil, NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocationData"]))
                }
            }
        }
    }
    
    func getUdacityUserInfo(userID: String, completionHandlerGETUserInfo: @escaping (_ result: User?, _ errorString: String?) -> Void) {
        
        if let method = substituteKeyInMethod(Constants.Methods.UdacityPublicUserData, key: "user_id", value: userID) {
            
            let _ = taskForUdacityGETMethod(method) { (results, error) in
                
                // check to see if there was an error returned
                guard error == nil else {
                    completionHandlerGETUserInfo(nil, Alerts.ResponseError.Unauthorized.localizedDescription)
                    return
                }
                
                guard let results = results,
                    let userInfo = results["user"] as? [String:AnyObject],
                    let firstName = userInfo[Constants.JSONResponseKeys.UdacityFirstName] as? String,
                    let lastName = userInfo[Constants.JSONResponseKeys.UdacityLastName] as? String
                    else {
                        completionHandlerGETUserInfo(nil, Alerts.ResponseError.Unknown.localizedDescription)
                        return
                }
                
                // create a User object to be passed back via the completionHandler
                let user = User(firstName: firstName, lastName: lastName, userId: userID)
                completionHandlerGETUserInfo(user, nil)
            }
        }
    }
    
    // MARK: - POST Student Location Method
    func postStudentLocation(userId: String, firstName: String, lastName: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, location: String, completionHandlerForPOSTStudentLoc: @escaping (_ result: AnyObject?, _ errorString: String?) -> Void) {
        
        // create the jsonBody for the request and define the method to be used
        let jsonBody = "{\"\(Constants.JSONBodyKeys.UniqueKey)\": \"\(userId)\", \"\(Constants.JSONBodyKeys.FirstName)\": \"\(firstName)\", \"\(Constants.JSONBodyKeys.LastName)\": \"\(lastName)\",\"\(Constants.JSONBodyKeys.MapString)\": \"\(location)\", \"\(Constants.JSONBodyKeys.MediaURL)\": \"\(mediaURL)\",\"\(Constants.JSONBodyKeys.Latitude)\": \(latitude), \"\(Constants.JSONBodyKeys.Longitude)\": \(longitude)}"
        
        let _ = taskForPOSTMethod(Constants.Methods.ParseStudentLocation, jsonBody: jsonBody) { (result, error) in
            
            // check to see if there was an error returned
            guard (error == nil) else {
                completionHandlerForPOSTStudentLoc(nil, error?.localizedDescription)
                return
            }
            
            // if there was no error we know we had a successful response
            completionHandlerForPOSTStudentLoc(result, nil)
        }
    }
   
    // MARK: Udacity Authentication (DELETE) Method
    
    func logout(_ completionHandlerForSession: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForSession(false, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("error with logging out")
                completionHandlerForSession(false, error as NSError?)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForSession(false, Alerts.ResponseError.Unknown as NSError?)
                return
            }
            
            completionHandlerForSession(true, nil)
        }
        task.resume()
    }
    
}
