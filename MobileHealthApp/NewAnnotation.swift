//
//  NewAnnotation.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/13/23.
//

import Foundation
import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var image: UIImage? = nil

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        //self.image
        super.init()
    }
}
