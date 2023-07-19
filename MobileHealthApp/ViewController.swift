//
//  ViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 6/25/23.
//

import UIKit
import MapKit
import CoreLocation

protocol BottomSheetDelegate: AnyObject {
    func didTapSearchButton(date: Date)
}

class ViewController: UIViewController, UIViewControllerTransitioningDelegate, CLLocationManagerDelegate, MKMapViewDelegate, BottomSheetDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var locationButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    var mobileUnits = [MobileUnit]()
    
    var bottomSheetViewController: BottomSheetContentViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        locationManager.startUpdatingLocation()
        locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        setupLocationButtonAppearance()
        
        let mobileUnit1 = MobileUnit(
            name: "Unit 1",
            address: "300 E Orange St, Tempe, AZ, USA",
            daysOpen: [2, 3, 4],  // Monday, Tuesday, Wednesday
            hourOpen: 9,
            hourClosed: 17,
            phoneNumber: "480-456-7890"
        )
                
        let mobileUnit2 = MobileUnit(
            name: "Unit 2",
            address: "1015 S Rural Rd, Tempe, AZ",
            daysOpen: [2, 3, 4, 5, 6],  // Monday to Friday
            hourOpen: 8,
            hourClosed: 18,
            phoneNumber: "098-765-4321"
        )
        
        mobileUnits = [mobileUnit1, mobileUnit2]
        
        bottomSheetViewController = BottomSheetContentViewController()
        bottomSheetViewController?.delegate = self
        //self.addChild(bottomSheetViewController)
        //bottomSheetViewController.didMove(toParent: self)

    }
        
    @IBAction func centerMapOnUserButtonTapped(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DispatchQueue.main.async {
            self.updateLocationButtonIcon()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            DispatchQueue.main.async {
                    self.updateLocationButtonIcon()
                }
        }
    }
    
    func updateLocationButtonIcon() {
        let centerCoordinate = mapView.centerCoordinate
        let userCoordinate = locationManager.location?.coordinate
        _ = CGSize(width: 15, height: 15)

        if let userCoordinate = userCoordinate {
            let distance = abs(centerCoordinate.latitude - userCoordinate.latitude) + abs(centerCoordinate.longitude - userCoordinate.longitude)
            
            if distance < 0.000000001 {
                locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
            } else {
                locationButton.setImage(UIImage(systemName: "location"), for: .normal)
            }
        }
    }
    
    func resizeImage(named name: String, to size: CGSize) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: min(size.width, size.height))
        return UIImage(systemName: name, withConfiguration: config)
    }
    
    func setupLocationButtonAppearance() {
        locationButton.layer.cornerRadius = locationButton.bounds.height / 4
        locationButton.layer.masksToBounds = true
        
        locationButton.layer.shadowColor = UIColor.black.cgColor
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        locationButton.layer.shadowRadius = 7
        locationButton.layer.shadowOpacity = 0.3
        locationButton.layer.masksToBounds = false
    }

    struct MobileUnit: Equatable {
        let name: String
        let address: String
        let daysOpen: [Int]
        let hourOpen: Int
        let hourClosed: Int
        let phoneNumber: String
        
        func location(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                guard let coordinate = placemarks?.first?.location?.coordinate else {
                    print("Failed to get location for address: \(self.address)")
                    completion(nil)
                    return
                }
                print("Got location for address: \(self.address)")
                completion(coordinate)
            }
        }
        
        func isOpen(on date: Date) -> Bool {
            let calendar = Calendar.current
            let day = calendar.component(.weekday, from: date)
            let hour = calendar.component(.hour, from: date)
            
            print("Checking if \(name) is open on day \(day) at hour \(hour)")
                    
            if !daysOpen.contains(day) || hour < hourOpen || hour > hourClosed {
                return false
            }
                    
            return true
        }

    }
    
    func searchForOpenMobileUnits(on date: Date) {
        let openUnits = mobileUnits.filter { $0.isOpen(on: date) }
        
        var points: [MKMapPoint] = []
        
        let dispatchGroup = DispatchGroup()
        
        for unit in openUnits {
            dispatchGroup.enter()
            
            unit.location { (coordinate) in
                if let coordinate = coordinate {
                    let point = MKMapPoint(coordinate)
                    points.append(point)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Remove all previous annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            if !openUnits.isEmpty {
                if let userLocation = self.locationManager.location?.coordinate {
                    let userPoint = MKMapPoint(userLocation)
                    points.append(userPoint)
                }
                
                let rect = points.reduce(MKMapRect.null) { (rect, point) -> MKMapRect in
                    return rect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
                }
                
                self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            } else {
                print("No open units found for the selected time.")
                // You can also provide a user-friendly alert or message here
                let alert = UIAlertController(title: "No Units Available", message: "No mobile units are available at the selected time.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            
            // Add annotations for each open mobile unit
            for unit in openUnits {
                unit.location { (coordinate) in
                    if let coordinate = coordinate {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = unit.name
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }

    }
    
    func didTapSearchButton(date: Date) {
         print("Search button pressed for date: \(date)")
         searchForOpenMobileUnits(on: date)
    }
    
}




