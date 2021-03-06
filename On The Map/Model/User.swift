//
//  User.swift
//  On The Map
//
//  Created by Jordan Jackson on 12/19/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation

struct User {
    
    let firstName: String
    let lastName: String
    let userId: String
    
    init(firstName: String, lastName: String, userId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.userId = userId
    }
}
