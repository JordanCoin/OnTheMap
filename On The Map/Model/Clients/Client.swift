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
    
    var session = URLSession.shared
//    var sessionID: String? = nil
    var latitude: Double! = nil
    var longitude: Double! = nil
    var firstName: String! = nil
    var lastName: String! = nil
    
    // MARK: GET - Student Locations

    func taskForGETMethod(_ requestMethod: String, completionHandlerGET: @escaping (_ success: Bool, _ errorString: String) -> Void) {
        
        let url = "\(Constants.ParseURL)\(requestMethod)?\(Constants.ParameterKeys.Limit)=100&\(Constants.ParameterKeys.Order)=-\(Constants.ParameterKeys.UpdatedAt)"
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                completionHandlerGET(false, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: "There was an error with the GET request \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                guard let results = parsedData["results"] as? [[String: Any]] else { return }

                let decoder = JSONDecoder()
                
                for locations in results {
                    
                    if (locations["uniqueKey"] as? String) != nil {
                        let studentData = try JSONSerialization.data(withJSONObject: locations, options: .prettyPrinted)
                        let students = try decoder.decode(Student.self, from: studentData)
                        StudentLocationCollection.add(location: students)
                        completionHandlerGET(true, "Could not parse \(studentData)")
                    }
                }
            } catch {
                completionHandlerGET(false, "Could not parse \(data)")
                return
            }
            
        }
        task.resume()
    }
    
    // MARK: POST - Create a new student location
    
    func taskForPOSTMethod(_ requestMethod: String, jsonBody: String, completionHandlerPOST: @escaping (_ result: AnyObject?, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ParseURL)\(requestMethod)")!)
        request.httpMethod = "POST"
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: .utf8)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                completionHandlerPOST(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: "There was an error with your POST request \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "The request did not return a valid 2xx httpStatusCode for the POST")
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
    }
    
    // MARK: PUT - Update existing student locations
    
    func taskForPUTMethod(_ requestMethod: String, jsonBody: String, completionHandlerPUT: @escaping (_ result: AnyObject?, _ errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.ParseURL)\(requestMethod)")!)
        request.httpMethod = "PUT"
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: .utf8)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                completionHandlerPUT(nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError(error: "There was an error with your POST request \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "The request did not return a valid 2xx httpStatusCode for the POST")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError(error: "There was no data returned in the POST request")
                return
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                guard let results = parsedData["results"] as? [[String: Any]] else { return }
                
                let decoder = JSONDecoder()
                
                for locations in results {
                    
                    if (locations["uniqueKey"] as? String) != nil {
                        let studentData = try JSONSerialization.data(withJSONObject: locations, options: .prettyPrinted)
                        let students = try decoder.decode(Student.self, from: studentData)
                        StudentLocationCollection.add(location: students)
                        completionHandlerPUT(nil, "Could not parse \(studentData)")
                    }
                }
            } catch {
                completionHandlerPUT(nil, "Could not parse \(data)")
                return
            }
            
        }
        task.resume()
    }
    
    func taskForUdacityGETMethod(_ method: String, completionForUdacityGET: @escaping (_ result: AnyObject?, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(method)")!)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                completionForUdacityGET(nil, error)
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: "There was an error with the UDACITY GET request \(error!)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    sendError(error: "The request did not return a valid 2xx httpStatusCode for the udacity GET request")
                    return
            }
            
            // make sure there was actual data returned
            guard let data = data else {
                sendError(error: "There was no data returned in the UDACITY GET request")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)

            self.convertDataWithCompletionHandler(data: newData, completionHandlerForConvertData: completionForUdacityGET)
        }
        
        task.resume()
        return task
    }
    
    func taskForUdacityPOST(_ requestMethod: String, jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ stringError: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "\(Constants.UdacityURL)\(requestMethod)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: .utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                completionHandlerForPOST(nil, error)
            }
            
            // was there an error returned in the response
            guard (error == nil) else {
                sendError(error: "\(error!.localizedDescription)")
                return
            }
            
            // make sure we got a successfull 2xx response from the request
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode,
                httpStatusCode >= 200 && httpStatusCode <= 299 else {
                    sendError(error: "The request did not return a valid 2xx httpStatusCode for the udacity POST request")
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
    
    // substitute the key for the value that is contained within the method name
    func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    // method that takes in raw json and returns it in a usuable foundation object
    func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ errorString: String?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            completionHandlerForConvertData(nil, error.localizedDescription)
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
}
