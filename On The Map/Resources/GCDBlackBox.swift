//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Jordan Jackson on 11/14/17.
//  Copyright © 2017 Jordan Jackson. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
