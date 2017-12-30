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
    
    // MARK: Udacity Authentication (POST) Method
    
    func getSessionID(_ username: String, _ password: String, _ completionForSession: @escaping (_ sessionID: String?, _ errorString: String?) -> Void) {
        
        let jsonBody = "{\"\(Constants.JSONBodyKeys.Udacity)\": {\"\(Constants.JSONBodyKeys.Username)\": \"\(username)\", \"\(Constants.JSONBodyKeys.Password)\": \"\(password)\"}}"

        let _ = taskForUdacityPOST(Constants.Methods.UdacitySession, jsonBody: jsonBody) { (results, error) in
            
            guard (error == nil) else {
                completionForSession(nil, error)
                return
            }
            
            guard let results = results,
                let result = results[Constants.JSONResponseKeys.Account] as? [String:AnyObject],
                let sessionID = result[Constants.JSONResponseKeys.AccountKey] as? String
                else {
                    completionForSession(nil, error)
                    return
            }
            // we know we had a successful request if we get here
            completionForSession(sessionID, nil)
        }
    }
    
    // MARK: - POST Student Location Method
    func getStudentLocation(_ completionHandlerForGETStudentLoc: @escaping (_ result: Student?, _ errorString: String?) -> Void) {
        
        let _ = taskForGETMethod(Constants.Methods.ParseStudentLocation) { (results, error) in
            
            // check to see if there was an error returned
            guard (error == nil) else {
                completionHandlerForGETStudentLoc(nil, error)
                return
            }
            
            guard let results = results?[Constants.JSONResponseKeys.Results] as? [[String:AnyObject]] else {
                completionHandlerForGETStudentLoc(nil, error)
                return
            }
            
            // if there was no error we know we had a successful response
            let students = Student.studentsFromResults(results: results)
            
            completionHandlerForGETStudentLoc(students, nil)
        }
    }
    
    func getUdacityUserInfo(userID: String, completionHandlerGETUserInfo: @escaping (_ result: User?, _ errorString: String?) -> Void) {
        
        if let method = substituteKeyInMethod(Constants.Methods.UdacityPublicUserData, key: "user_id", value: userID) {
            
            let _ = taskForUdacityGETMethod(method) { (results, error) in
                
                // check to see if there was an error returned
                guard error == nil else {
                    completionHandlerGETUserInfo(nil, error)
                    return
                }
                
                guard let results = results,
                    let userInfo = results["user"] as? [String:AnyObject],
                    let firstName = userInfo[Constants.JSONResponseKeys.UdacityFirstName] as? String,
                    let lastName = userInfo[Constants.JSONResponseKeys.UdacityLastName] as? String
                    else {
                        completionHandlerGETUserInfo(nil, error)
                        return
                }
                
                // create a User object to be passed back via the completionHandler
                let user = User(firstName: firstName, lastName: lastName, userId: userID)
                completionHandlerGETUserInfo(user, nil)
            }
        }
    }
    
    // MARK: - POST Student Location Method
    func postStudentLocation(userId: String, firstName: String, lastName: String, mediaURL: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees, location: String, completionHandlerForPOSTStudentLoc: @escaping (_ result: Int?, _ errorString: String?) -> Void) {
        
        // create the jsonBody for the request and define the method to be used
        let jsonBody = "{\"\(Constants.JSONBodyKeys.UniqueKey)\": \"\(userId)\", \"\(Constants.JSONBodyKeys.FirstName)\": \"\(firstName)\", \"\(Constants.JSONBodyKeys.LastName)\": \"\(lastName)\",\"\(Constants.JSONBodyKeys.MapString)\": \"\(location)\", \"\(Constants.JSONBodyKeys.MediaURL)\": \"\(mediaURL)\",\"\(Constants.JSONBodyKeys.Latitude)\": \(latitude), \"\(Constants.JSONBodyKeys.Longitude)\": \(longitude)}"
        
        let _ = taskForPOSTMethod(Constants.Methods.ParseStudentLocation, jsonBody: jsonBody) { (result, error) in
            
            // check to see if there was an error returned
            guard (error == nil) else {
                completionHandlerForPOSTStudentLoc(nil, error)
                return
            }
            
            // if there was no error we know we had a successful response
            completionHandlerForPOSTStudentLoc(1, nil)
        }
    }
   
    // MARK: Udacity Authentication (DELETE) Method
    
    func logout(_ completionHandlerForSession: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
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
            
            guard (error == nil) else {
                completionHandlerForSession(false, "logout Error")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForSession(false, "Your request returned a status code other than 2xx!")
                return
            }
            
            let range = Range(5..<data!.count)
            guard let newData = data?.subdata(in: range) else {
                completionHandlerForSession(false, "No data was returned by the request!")
                return
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String : Any]
                
                guard let results = parsedData[Constants.JSONResponseKeys.Session] as? [String: Any] else { return }
                
                for id in results {
                    if id.key == Constants.JSONResponseKeys.SessionId {
                        completionHandlerForSession(true, nil)
                    }
                }
            } catch {
                completionHandlerForSession(false, "No Session avaliable")
                return
            }
        }
        task.resume()
        
    }
}
