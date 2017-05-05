//
//  MapTask.swift
//  RUNavigating
//
//  Created by dsc on 4/21/17.
//  Copyright © 2017 Digital Scholarship Center. All rights reserved.
//

import Foundation

class MapTasks: NSObject{
    

let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"

var lookupAddressResults: Dictionary<NSObject, AnyObject>!

var fetchedFormattedAddress: String!

var fetchedAddressLongitude: Double!

var fetchedAddressLatitude: Double!
    
    
    override init() {
        super.init()
    }

    
   
}
