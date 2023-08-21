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

let defaultKey = "TestFirst"

class ViewController: UIViewController, UIViewControllerTransitioningDelegate, CLLocationManagerDelegate, MKMapViewDelegate, BottomSheetDelegate, NetworkCheckObserver {
    //Debugger Function
    func statusDidChange(status: NWPath.Status) {
        print("_Internet Status Change_")
    }
    
    
    @IBOutlet var faqButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var tutorialButton: UIButton!
    
    var locationManager: CLLocationManager?
    
    var mobileUnits = [HealthUnit]()
    
    //declares search button area controller
    var bottomSheetViewController: BottomSheetContentViewController?
    
    
    //internet monitor
    let monitor = NWPathMonitor()

    //default range
    var range = 0.0
    //zooms only on entrance to the app
    var firstPress = true
    

    
    //gets screen bounds
    let screenSize: CGRect = UIScreen.main.bounds
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        getDatabase()
        
        setupButtonAppearances()
       
        bottomSheetViewController = BottomSheetContentViewController()
        bottomSheetViewController?.delegate = self


    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let tutorialWasViewed = UserDefaults.standard.bool(forKey: defaultKey)
        print("Value in tutorial was viewed: \(tutorialWasViewed)")
        if tutorialWasViewed {
            
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
            mapView.showsUserLocation = true
            
            mapView.delegate = self
            locationManager?.startUpdatingLocation()
            locationButton.setImage(UIImage(systemName: "location"), for: .normal)
            
        } else {
            print("Present the Segue")
            performSegue(withIdentifier: "showTutorialSegue", sender: self)
           
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTutorialSegue" {
            if let destinationVC = segue.destination as? TutorialViewController {
                destinationVC.delegate = self
            }
        }
    }
    
    @IBAction func centerMapOnUserButtonTapped(_ sender: Any) {
        if let userLocation = locationManager?.location?.coordinate {
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
            if(firstPress){
                mapView.setRegion(region, animated: true)
                firstPress = false
            }
            
            DispatchQueue.main.async {
                    self.updateLocationButtonIcon()
                }
        }
    }
    
    func updateLocationButtonIcon() {
        let centerCoordinate = mapView.centerCoordinate
        let userCoordinate = locationManager?.location?.coordinate


        if let userCoordinate = userCoordinate {
            let distance = abs(centerCoordinate.latitude - userCoordinate.latitude) + abs(centerCoordinate.longitude - userCoordinate.longitude)
            //If user is already centered, switches location button image
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
    
    func setupButtonAppearances() {
        locationButton.layer.cornerRadius = locationButton.bounds.height / 4
        locationButton.layer.masksToBounds = true
        locationButton.layer.shadowColor = UIColor.black.cgColor
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        locationButton.layer.shadowRadius = 7
        locationButton.layer.shadowOpacity = 0.3
        locationButton.layer.masksToBounds = false
        locationButton.layer.bounds.size.width = 40
        locationButton.layer.bounds.size.height = 40
        
        tutorialButton.layer.cornerRadius = tutorialButton.bounds.height / 4
        tutorialButton.layer.masksToBounds = true
        tutorialButton.layer.shadowColor = UIColor.black.cgColor
        tutorialButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        tutorialButton.layer.shadowRadius = 7
        tutorialButton.layer.shadowOpacity = 0.3
        tutorialButton.layer.masksToBounds = false
        tutorialButton.layer.bounds.size.width = 40
        tutorialButton.layer.bounds.size.height = 40
        
        faqButton.layer.cornerRadius = faqButton.bounds.height / 4
        faqButton.layer.masksToBounds = true
        faqButton.layer.shadowColor = UIColor.black.cgColor
        faqButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        faqButton.layer.shadowRadius = 15
        faqButton.layer.shadowOpacity = 0.3
        faqButton.layer.masksToBounds = false

    }
    
    

    func searchForOpenMobileUnits(on date: Date, range: Double) {
        
        var openUnits = [HealthUnit]()
        
        if let userLocation = locationManager?.location?.coordinate {
            var openUnits: [HealthUnit] = []
            let dispatchGroup = DispatchGroup()

            for unit in mobileUnits {
                dispatchGroup.enter()

                unit.isWithin(range: range, userLoc: userLocation, address: unit.address ?? "Failed") { isWithinRange in
                    // checks if the unit is within user-set range
                    if isWithinRange {
                        // verifies that the month and year are correct
                        if let monthYear = unit.MonthYear {
                            let calendar = Calendar.current
                            let searchedMonth = calendar.component(.month, from: date)
                            let searchedYear = calendar.component(.year, from: date)
                            let unitMonth = Int(monthYear.suffix(2)) ?? -1
                            let unitYear = Int(monthYear.prefix(4)) ?? -1
                            if searchedMonth == unitMonth && searchedYear == unitYear {
                                openUnits.append(unit)
                                // print("Count of Mobile units during: \(openAndRanged.count)")
                            } else {
                                print("Right Day, wrong month and/or Year")
                            }
                        } else {
                            print("Invalid Month/Year")
                        }
                    } else {
                        print("\(unit) out of range \(range)")
                    }

                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.processFoundUnits(openUnits: openUnits, date: date)
            }
        }
            
        }
    
    func processFoundUnits(openUnits: [HealthUnit], date: Date) {
        var closedButRanged = [HealthUnit]()
        var currentlyOpenUnits = [HealthUnit]()
        mobileUnits = openUnits
        print("This is the array 4: \(openUnits)")
        
        for unit in openUnits {
            if unit.isOpen(on: date) {
                currentlyOpenUnits.append(unit)
            } else {
                closedButRanged.append(unit)
            }
        }
        
        var openPoints: [MKMapPoint] = []
        var closedPoints: [MKMapPoint] = []
        
        let dispatchGroup = DispatchGroup()
        
        for unit in currentlyOpenUnits {
            dispatchGroup.enter()
            
            unit.location { (coordinate) in
                if let coordinate = coordinate {
                    let point = MKMapPoint(coordinate)
                    openPoints.append(point)
                }
                
                dispatchGroup.leave()
            }
        }
        
        for unit in closedButRanged {
            dispatchGroup.enter()
            
            unit.location { (coordinate) in
                if let coordinate = coordinate {
                    let point = MKMapPoint(coordinate)
                    closedPoints.append(point)
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.displayFoundUnits(currentlyOpenUnits: currentlyOpenUnits, oldOpenPoints: openPoints, closedButRanged: closedButRanged, closedPoints: closedPoints)
        }
    }
    
    
    func displayFoundUnits(currentlyOpenUnits: [HealthUnit], oldOpenPoints: [MKMapPoint], closedButRanged: [HealthUnit], closedPoints: [MKMapPoint]){
        
        var openPoints = oldOpenPoints
        
        
        // Remove all previous annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        //!currentlyOpenUnits.isEmpty  ||
        if !currentlyOpenUnits.isEmpty {
            if let userLocation = self.locationManager?.location?.coordinate {
                let userPoint = MKMapPoint(userLocation)
                openPoints.append(userPoint)
            }
        } else {
            print("No open units found for the selected time.")
            var userErrorMsg = "No open mobile units are available at the selected time or range."
            //checks network status if no mobile health units were found
            let networkCheck = NetworkCheck.sharedInstance()
            
            //if(self.mobileUnits.isEmpty){
            if networkCheck.currentStatus != .satisfied{
                //Changes pop-up alert text
                userErrorMsg = "Internet Connection Error. Please check your connection and try again."
            }else{
                print("Adding user location...")
                if let userLocation = self.locationManager?.location?.coordinate {
                    let userPoint = MKMapPoint(userLocation)
                    openPoints.append(userPoint)
                }
            }
            networkCheck.addObserver(observer: self)
            //}
            let alert = UIAlertController(title: "No Units Available", message: userErrorMsg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        // Add annotations for each open unit
        for openUnit in currentlyOpenUnits {
            openUnit.location { (coordinate) in
                if let coordinate = coordinate {
                    let marker = MyAnnotation(title: openUnit.name ?? "title", subtitle: "Open", coordinate: coordinate, prio: true)
                    
                    print("OPEN PLACED")
                    if let image = UIImage(named: "openPin") {
                        let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 35, height: 35))
                        marker.image = resizedImage
                        self.mapView.addAnnotation(marker)
                    }
                }
            }
        }
        
        var yOffset: CLLocationDegrees = 0.0 // Offset for spacing out closed units

        // Add annotations for each closed but ranged unit
        for closedUnit in closedButRanged {
            closedUnit.location { (coordinate) in
                if let coordinate = coordinate {
                    if self.isAnnotationAtCoordinate(coordinate) {
                        print("Overlap detected")
                        yOffset += 0.00005 // Adjust the yOffset to create spacing
                    }
                    
                    let adjustedCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude + yOffset, longitude: coordinate.longitude)
                    
                    let marker = MyAnnotation(title: closedUnit.name ?? "title", subtitle: "Closed", coordinate: adjustedCoordinate, prio: false)
                    
                    print("CLOSED PLACED")
                    if let image = UIImage(named: "closedPin") {
                        let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 35, height: 35))
                        marker.image = resizedImage
                        self.mapView.addAnnotation(marker)
                    }
                }
            }
        } 
        
        let rect: MKMapRect     
        if (currentlyOpenUnits.isEmpty) {
            
            if(closedPoints.isEmpty){
                print("Rect 1")
                rect = openPoints.reduce(MKMapRect.null) { (rect, point) -> MKMapRect in
                    return rect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
                }
            }else{
                print("Rect 2")
                rect = closedPoints.reduce(MKMapRect.null) { (rect, point) -> MKMapRect in
                    return rect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
                }
            }
           
            
        }else{
            print("Rect 3")
            rect = openPoints.reduce(MKMapRect.null) { (rect, point) -> MKMapRect in
                return rect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
            }
        }
        self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
    }
    
    func isAnnotationAtCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        for annotation in mapView.annotations {
            if annotation.coordinate.latitude == coordinate.latitude && annotation.coordinate.longitude == coordinate.longitude {
                return true
            }
        }
        return false
    }
    
    func didTapSearchButton(date: Date, range: Double) {
        print("Search button pressed for date: \(date)")
        if(mobileUnits.isEmpty){
            //Refreshes the database if the database is empty
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
                    //Gets data from Firebase and inits a mobile health unit class
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let dict = childSnapshot.value as? [String: Any] {
                                let newUnit = HealthUnit(
                                    rawId: dict["id"] as? String ?? "",
                                    rawMY: dict["Month and Year"] as? String ?? "",
                                    name: dict["MHU Name"] as? String ?? "",
                                    rawnumber: dict["Phone Number"] as? String ?? "",
                                    rawopen: dict["Opening"] as? String ?? "",
                                    rawclose: dict["Closing"] as? String ?? "",
                                    rawdays: dict["Days of the Month Open"] as? String ?? "",
                                    rawaddr: dict["Address"] as? String ?? "",
                                    comments: dict["Comments"] as? String ?? ""
                                )
                                units.append(newUnit)
                        }
                    }
                    mobileUnits = units
                }
        }
    
    
    //This half complete function will be used for changing pin style
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if let annotation = annotation as? MyAnnotation {
            let identifier = "identifier"
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.image = annotation.image //add this
            
            annotationView?.canShowCallout = true
            annotationView?.calloutOffset = CGPoint(x: -5, y: 5)
            /*if(annotation.openPrio){
                annotationView?.layer.zPosition = CGFloat.greatestFiniteMagnitude
            }*/
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //print("Button Press")
        if let annotation = view.annotation as? MyAnnotation {
            print("Annotation was an annotation")
            if let title = annotation.title {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                for unit in mobileUnits{
                    //matches annotation clicked to the corresponding unit in the array, and passes it
                    if(unit.name == title){
                        if let detailViewController = storyboard.instantiateViewController(withIdentifier: "BottomDetailViewController") as? BottomDetailViewController {
                            detailViewController.unit = unit
                            //presents Bottom Detail View Controller
                            let nav = UINavigationController(rootViewController: detailViewController)
                            nav.modalPresentationStyle = .pageSheet
                            if let sheet = nav.sheetPresentationController {
                                sheet.prefersGrabberVisible = true
                                sheet.detents = [ .large()]
                            }
                            present(nav, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension ViewController : TutorialDelegate {
    func didFinishUnwindSegue() {
        print("Unwinding value was called")
         locationManager = CLLocationManager()
         locationManager?.delegate = self
         locationManager?.requestWhenInUseAuthorization()
         mapView.showsUserLocation = true
         
         mapView.delegate = self
         locationManager?.startUpdatingLocation()
         locationButton.setImage(UIImage(systemName: "location"), for: .normal)
         
    }
    
}

extension ViewController :  UIViewControllerTransitioningDelegate {
    
}

extension ViewController : CLLocationManagerDelegate {
    
}

extension ViewController : MKMapViewDelegate {
    
}

extension ViewController : BottomSheetDelegate {
    
}

extension ViewController : NetworkCheckObserver {
    func statusDidChange(status: NWPath.Status) {
        print("_Internet Status Change_")
    }
}
