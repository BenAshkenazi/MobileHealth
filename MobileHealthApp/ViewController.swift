//
//  ViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 6/25/23.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import Network


protocol BottomSheetDelegate: AnyObject {
    func didTapSearchButton(date: Date, range: Double)
}

class ViewController: UIViewController, UIViewControllerTransitioningDelegate, CLLocationManagerDelegate, MKMapViewDelegate, BottomSheetDelegate, NetworkCheckObserver {
    
    func statusDidChange(status: NWPath.Status) {
        print("___")
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var locationButton: UIButton!
    var locationManager: CLLocationManager!
    
    var mobileUnits = [HealthUnit]()
    
    var bottomSheetViewController: BottomSheetContentViewController?

    let monitor = NWPathMonitor()

    var range = 0.0
    let screenSize: CGRect = UIScreen.main.bounds
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // let queue = DispatchQueue(label: "Monitor")
        //monitor.start(queue: queue)
                                                        
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        //may want to switch this back on later
        //mapView.userTrackingMode = .follow
        mapView.delegate = self
        locationManager.startUpdatingLocation()
        locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        setupLocationButtonAppearance()
        getDatabase()
        
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            if let title = annotation.title {
                // Present the SwiftUI sheet when the annotation is clicked
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                    // Customize the detailViewController with data from the selected annotation if needed
                    for unit in mobileUnits{
                        if(unit.name == title){
                            detailViewController.unit = unit
                        }
                    }
                    
                    detailViewController.modalPresentationStyle = .custom
                    detailViewController.transitioningDelegate = self
                    present(detailViewController, animated: true, completion: nil)
                    
                }
            }
            
        }
    }
    
    func updateLocationButtonIcon() {
        let centerCoordinate = mapView.centerCoordinate
        let userCoordinate = locationManager.location?.coordinate


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
        locationButton.layer.bounds.size.width = 40
        locationButton.layer.bounds.size.height = 40

    }
    

    func searchForOpenMobileUnits(on date: Date, range: Double) {
        var openUnits = mobileUnits.filter { $0.isOpen(on: date) }
        var openAndRanged = [HealthUnit]()

        
        if let userLocation = locationManager.location?.coordinate{
            for unit in openUnits{
                unit.isWithin(range: range, userLoc: userLocation, address: unit.address ?? "Failed"){ isWithinRange in
                    if(isWithinRange){
                        //print("Unit in range found")
                        openAndRanged.append(unit)

                    }else{
                        print("\(unit) out of range \(range)")

                    }
                    openUnits = openAndRanged
                }
            }
            
        }
        
        
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

                var userErrorMsg = "No mobile units are available at the selected time."
                
                var networkCheck = NetworkCheck.sharedInstance()
                
                if(self.mobileUnits.count < 1){
                    if networkCheck.currentStatus != .satisfied{
                        userErrorMsg = "Internet Connection Error. Please check your connection and try again."
                    }
                    networkCheck.addObserver(observer: self)
                }
                
                let alert = UIAlertController(title: "No Units Available", message: userErrorMsg, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            
            // Add annotations for each open mobile unit
            for unit in openUnits {
                unit.location { (coordinate) in
                    if let coordinate = coordinate {
                        //print(distanceInMiles(from: coordinate, to: coordinate))
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = unit.name
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }

    }
    
    func didTapSearchButton(date: Date, range: Double) {
        print("Search button pressed for date: \(date)")
        if(mobileUnits.count < 1){
            getDatabase()
        }
        searchForOpenMobileUnits(on: date, range: range)
    }
    
    func getDatabase(){
        let rootRef = Database.database().reference().child("1tccGgPzxsOegrepl329GJkQOYnGcWu2XhLYcgiB_iNE").child("Sheet1")
                rootRef.observeSingleEvent(of: .value) { [weak self] snapshot, error in
                    guard let self = self else {
                        return
                    }
                    
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    
                    if !snapshot.exists() {
                        print("No data found.")
                        return
                    }
                    
                    var units: [HealthUnit] = []
                    
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let dict = childSnapshot.value as? [String: Any] {
                                let newUnit = HealthUnit(
                                    rawId: dict["id"] as? String ?? "",
                                    rawMY: dict["Month and Year"] as? String ?? "",
                                    name: dict["MHU Name"] as? String ?? "",
                                    rawpartner: dict["Partner"] as? String ?? "",
                                    rawnumber: dict["Phone Number"] as? String ?? "",
                                    rawopen: dict["Opening"] as? String ?? "",
                                    rawclose: dict["Closing"] as? String ?? "",
                                    rawdays: dict["Days Open"] as? String ?? "",
                                    rawaddr: dict["Address"] as? String ?? "",
                                    comments: dict["Comments"] as? String ?? ""
                                )

                                units.append(newUnit)
                        }

                    }
                    mobileUnits = units
                }
        }
    
}
