//
//  Constants.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/4/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation

// MARK: Constants
extension Client {
    
    struct Constants {
        
        struct Udacity {
            static let AuthorizationURL = "https://www.udacity.com/api/session"
            static let ApiScheme = "https"
            static let ApiHost = "udacity.com/api/session"
            static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
        }
        
        struct Parse {
            static let ApiScheme = "https"
            static let ApiHost = "parse.udacity.com/parse/classes"
            
            static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
            static let baseURL = "https://parse.udacity.com/parse/classes"
            static let StudentLocation = "/StudentLocation"
        }
        
        struct ParseResponseKeys {
            static let objectID = "objectId"
            static let uniqueKey = "uniqueKey"
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let mapString = "mapString"
            static let mediaURL = "mediaURL"
            static let latitude = "latitude"
            static let longitude = "longitude"
            static let updatedAt = "updatedAt"
            static let createdAt = "createdAt"
        }
        
        struct ParameterKeys {
            static let ApiKey = "api_key"
            static let ID = "id"
            static let Session = "session"
            static let RequestToken = "request_token"
            static let Query = "query"
        }
    }
}
