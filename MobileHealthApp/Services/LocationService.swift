//
//  LocationService.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/28/23.
//

import CoreLocation

class LocationService {

    var locationManager: CLLocationManager?

    func askUserForLocation() {
        locationManager = CLLocationManager()
         locationManager?.requestWhenInUseAuthorization()
         locationManager?.startUpdatingLocation()
    }

    func getUserLocation() -> CLLocationCoordinate2D? {
        locationManager?.location?.coordinate
    }

}
