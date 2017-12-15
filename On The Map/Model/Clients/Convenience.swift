//
//  Convenience.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/16/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import UIKit
import Foundation

extension Client {
    
    // MARK: Udacity Authentication (POST) Method
    
    func getSessionID(_ email: String, _ password: String, _ completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard (error == nil) else {
                completionHandlerForSession(false, nil, "Login Failed (Session ID).")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForSession(false, nil, "Your request returned a status code other than 2xx!")
                return
            }
            
            let range = Range(5..<data!.count)
            guard let newData = data?.subdata(in: range) else {
                completionHandlerForSession(false, nil, "No data was returned by the request!")
                return
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String : Any]
                
                guard let results = parsedData[Constants.ParameterKeys.Session] as? [String: Any] else { return }
                
                for id in results {
                    var sessionID = String()
                    if id.key == Constants.ParameterKeys.ID {
                        sessionID.append(id.value as! String)
                        completionHandlerForSession(true, sessionID, nil)
                    }
                }
            } catch {
                completionHandlerForSession(false, nil, "No sessionID found!")
                return
            }
        }
        task.resume()
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
                completionHandlerForSession(false, "Login Failed (Session ID).")
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
                
                guard let results = parsedData[Constants.ParameterKeys.Session] as? [String: Any] else { return }
                
                for id in results {
                    if id.key == Constants.ParameterKeys.ID {
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
    
    // MARK: - Authentication Web Login Method
    
    func webLogin( _ data: Data, _ completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) {
        
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
            
            guard let results = parsedData[Constants.ParameterKeys.Session] as? [String: Any] else { return }
            
            for id in results {
                var sessionID = String()
                if id.key == Constants.ParameterKeys.ID {
                    sessionID.append(id.value as! String)
                    completionHandlerForSession(true, sessionID, nil)
                }
            }
        } catch {
            completionHandlerForSession(false, nil, "No sessionID found!")
            return
        }
    }
}
