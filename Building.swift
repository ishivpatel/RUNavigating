//
//  Building.swift
//  RUNavigating
//
//  Created by Shiv Patel on 5/3/17.
//  Copyright © 2017 Digital Scholarship Center. All rights reserved.
//

import UIKit

class Building {
    var name: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(name: String, latitude: Double, longitude: Double){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

