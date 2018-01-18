//
//  StudentDataSource.swift
//  On The Map
//
//  Created by Jordan Jackson on 1/16/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import Foundation

class StudentDataSource {
    static var sharedInstance = StudentDataSource()
    var studentData = [Student]()
    private init() {}
}
