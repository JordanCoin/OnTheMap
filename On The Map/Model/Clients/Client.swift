//
//  Client.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/4/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation
import UIKit

class Client: NSObject {
        
    // MARK: Properties
    
    static let sharedInstance = Client()
    let userKey = UserDefaults()
    var session = URLSession.shared
    var objectID: String? = nil
    
    // MARK: GET - Student Locations

    func taskForGETMethod(_ requestMethod: String, completionHandlerGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let url = "\(Constants.ParseURL)\(requestMethod)?\(Constants.ParameterKeys.Limit)=100&\(Constants.ParameterKeys.Order)=-\(Constants.ParameterKeys.UpdatedAt)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: Alerts.ResponseError.Unknown.localizedDescription)
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, httpStatusCode != 403 else {
                sendError(error: Alerts.ResponseError.Unauthorized.localizedDescription)
                return
            }
            
            guard httpStatusCode >= 200 && httpStatusCode <= 299 else {
                sendError(error: Alerts.ResponseError.Unknown.localizedDescription)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandlerGET)
        }
        task.resume()
        return task
    }
    
    // MARK: POST - Create a new student location
    
    func taskForPOSTMethod(_ requestMethod: String, jsonBody: String, completionHandlerPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ParseURL)\(requestMethod)")!)
        request.httpMethod = "POST"
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: .utf8)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: Alerts.ResponseError.Unknown.localizedDescription)
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, httpStatusCode != 403 else {
                sendError(error: Alerts.ResponseError.Unauthorized.localizedDescription)
                return
            }
            
            guard httpStatusCode >= 200 && httpStatusCode <= 299 else {
                sendError(error: Alerts.ResponseError.Unknown.localizedDescription)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "There was no data returned in the POST request")
                return
            }
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandlerPOST)
            
        }
        task.resume()
        return task
    }
    
    func taskForUdacityGETMethod(_ method: String, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(method)")!)
        
        let task = self.session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskForUdacityGETMethod", code: 1, userInfo: userInfo))
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(Alerts.ResponseError.Unknown.localizedDescription)
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    sendError(Alerts.ResponseError.Unknown.localizedDescription)
                    return
            }
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError("There was no data returned in the UDACITY GET request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForGET)
            
        }
        task.resume()
        return task
    }
    
    func taskForUdacityPOST(_ requestMethod: String, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(requestMethod)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: .utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(nil, NSError(domain: "taskForUdacityPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: Alerts.ResponseError.Unknown.localizedDescription)
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, httpStatusCode != 403 else {
                print("Error udacity post statusCode != 403")
                sendError(error: Alerts.ResponseError.Unauthorized.localizedDescription)
                return
            }
            
            guard httpStatusCode >= 200 && httpStatusCode <= 299 else {
                sendError(error: Alerts.ResponseError.Unauthorized.localizedDescription)
                print("Error udacity post statusCode == 200...299")
                return
            }
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError(error: "There was no data returned in the UDACITY SESSION request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)

            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        // start the request
        task.resume()
        return task
    }
    
    func taskForUdacityDELETESession(_ requestMethod: String, completionHandlerForSession: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(requestMethod)")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForSession(nil, NSError(domain: "taskForLOGOUTMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("error with logging out")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(Alerts.ResponseError.Unknown.localizedDescription)
                return
            }
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError("There was no data returned in the DELTE UDACITY SESSION request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            
            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionHandlerForSession)
        }
        task.resume()
        return task
    }
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    // method that takes in raw json and returns it in a usuable foundation object
    func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
}
