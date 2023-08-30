//
//  LocationService.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/28/23.
//

import Foundation
import CoreLocation

class LocationService {
    var locationManager: CLLocationManager?
    
    init(){
        locationManager = CLLocationManager()
    }
    
    func askUserForLocation(){
         print("Unwinding value was called")
         locationManager?.requestWhenInUseAuthorization()
         locationManager?.startUpdatingLocation()
    }
    
    func getUserLocation() -> CLLocationCoordinate2D?{
        return locationManager?.location?.coordinate
    }
    
}
