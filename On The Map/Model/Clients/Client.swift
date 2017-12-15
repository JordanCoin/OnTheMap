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
    var sessionID: String? = nil
    var latitude: Double! = nil
    var longitude: Double! = nil
    var link: String! = nil
    
    // MARK: GET - Student Locations

    func taskForGETMethod(_ sessionID: String?, _ requestMethod: String, handler: @escaping (_ success: Bool, _ errorString: String) -> Void) {
        
        var request = URLRequest(url: URL(string: requestMethod)!)
            
        request.addValue(Constants.Parse.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Parse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                handler(false, "There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                handler(false, "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                handler(false, "No data was returned by the request!")
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
                        let students = try decoder.decode(StudentLocation.self, from: studentData)
                        StudentLocationCollection.add(location: students)
                        handler(true, "Could not parse \(studentData)")
                    }
                }
            } catch {
                handler(false, "Could not parse \(data)")
                return
            }
            
        }
        task.resume()
    }
    
    // MARK: POST - Create a new student location
    
    func taskForPOSTMethod(_ sessionID: String, _ latitude: Double, _ longitude: Double, _ link: String, handler: @escaping (_ success: Bool, _ errorString: String) -> Void) {
        
        var request = URLRequest(url: URL(string: "\(Constants.Parse.baseURL)\(Constants.Parse.StudentLocation)")!)
        request.httpMethod = "POST"
        request.addValue(Constants.Parse.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.Parse.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(sessionID)\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"\(link)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                handler(false, "There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                handler(false, "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                handler(false, "No data was returned by the request!")
                return
            }
            print(String(data: data, encoding: .utf8)!)
        }
        task.resume()
    }
    
    // MARK: PUT - Update existing student locations
    
    func updateLocations() {
    }
    
    private func URLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Client.Constants.Parse.ApiScheme
        components.host = Client.Constants.Parse.ApiHost
//        components.path
//        components.path = Client.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
}
