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
    //Debugger Function
    func statusDidChange(status: NWPath.Status) {
        print("_Internet Status Change_")
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var faqButton: UIButton!
    
    var locationManager: CLLocationManager!
    
    var mobileUnits = [HealthUnit]()
    
    //declares search button area controller
    var bottomSheetViewController: BottomSheetContentViewController?
    
    
    //internet monitor
    let monitor = NWPathMonitor()

    //default range
    var range = 0.0
    //zooms only on first entrance to the app
    var firstPress = true
    
    //gets screen bounds
    let screenSize: CGRect = UIScreen.main.bounds

    var selectedAnnotationView: MKAnnotationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

                                                        
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
        setupFAQButtonAppearance()
        getDatabase()
        
        
        bottomSheetViewController = BottomSheetContentViewController()
        bottomSheetViewController?.delegate = self

        //potential code for initial search upon start up, move to loading bar view
        //searchForOpenMobileUnits(on: <#T##Date#>, range: <#T##Double#>)
        //self.addChild(bottomSheetViewController)
        //bottomSheetViewController.didMove(toParent: self)

    }
        
    @IBAction func centerMapOnUserButtonTapped(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
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
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Store the selected annotation view
        selectedAnnotationView = view

        // Animate to the bigger size
        UIView.animate(withDuration: 0.2) {
            self.selectedAnnotationView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            self.showDetailViewController() // Call the method to present the detail view controller
        }
    }

    func showDetailViewController() {
        if let annotation = selectedAnnotationView?.annotation as? MKPointAnnotation {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            for unit in mobileUnits {
                if unit.name == annotation.title {
                    if let detailViewController = storyboard.instantiateViewController(withIdentifier: "BottomDetailViewController") as? BottomDetailViewController {
                        detailViewController.delegate = self // Set delegate here
                        detailViewController.unit = unit
                        let nav = UINavigationController(rootViewController: detailViewController)
                        nav.modalPresentationStyle = .pageSheet
                        if let sheet = nav.sheetPresentationController {
                            sheet.detents = [.medium(), .large()]
                        }
                        // Set the delegate to handle dismissal
                        nav.presentationController?.delegate = self
                        present(nav, animated: true)
                    }
                }
            }
        }
    }

    func updateLocationButtonIcon() {
        let centerCoordinate = mapView.centerCoordinate
        let userCoordinate = locationManager.location?.coordinate


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
    
    func setupFAQButtonAppearance() {
        faqButton.layer.cornerRadius = faqButton.bounds.height / 4
        faqButton.layer.masksToBounds = true
        faqButton.layer.shadowColor = UIColor.black.cgColor
        faqButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        faqButton.layer.shadowRadius = 7
        faqButton.layer.shadowOpacity = 0.3
        faqButton.layer.masksToBounds = false
        faqButton.layer.bounds.size.width = 40
        faqButton.layer.bounds.size.height = 40

    }
    

    func searchForOpenMobileUnits(on date: Date, range: Double) {
        //removes units not open on the right day
        var openUnits = mobileUnits.filter { $0.isOpen(on: date) }
        
        //creates empty health unit array for appending
        var openAndRanged = [HealthUnit]()
        
        if let userLocation = locationManager.location?.coordinate{
            for unit in openUnits{
                unit.isWithin(range: range, userLoc: userLocation, address: unit.address ?? "Failed"){ isWithinRange in
                    //checks if the unit is within user-set range
                    if(isWithinRange){
                        //verifies that the month and year are correct
                        if let monthYear = unit.MonthYear{
                            let calendar = Calendar.current
                            let searchedMonth = calendar.component(.month, from: date)
                            let searchedYear = calendar.component(.year, from: date)
                            let unitMonth = Int(monthYear.suffix(2)) ?? -1
                            let unitYear = Int(monthYear.prefix(4)) ?? -1
                            if(searchedMonth == unitMonth && searchedYear == unitYear){
                                openAndRanged.append(unit)
                            }else{
                                print("Right Day, wrong month and/or Year")
                            }
                            
                        }else{
                            print("Invalid Month/Year")
                        }
                        

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
                
                let bottomSheetHeight = UIScreen.main.bounds.height * 0.8
                if let windowSafeAreaBottomInset = self.view.window?.safeAreaInsets.bottom {
                    let initialOffset = 200 + windowSafeAreaBottomInset
                    let visibleBottomSheetHeight = bottomSheetHeight - initialOffset
                    
                    let rect = points.reduce(MKMapRect.null) { (rect, point) -> MKMapRect in
                        return rect.union(MKMapRect(origin: point, size: MKMapSize(width: 0, height: 0)))
                    }
                    
                    self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: visibleBottomSheetHeight, right: 50), animated: true)
                }
            } else {
                print("No open units found for the selected time.")


                var userErrorMsg = "No mobile units are available at the selected time."
                //checks network status if no mobile health units were found
                let networkCheck = NetworkCheck.sharedInstance()
                
                if(self.mobileUnits.isEmpty){
                    if networkCheck.currentStatus != .satisfied{
                        //Changes pop-up alert text
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
                        //Adds annotations to map
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
    
}

extension ViewController: BottomDetailViewControllerDelegate {
   func didDismissDetailViewController() {
       if let selectedAnnotation = mapView.selectedAnnotations.first {
           mapView.deselectAnnotation(selectedAnnotation, animated: true)
       }
       UIView.animate(withDuration: 0.1) {
           self.selectedAnnotationView?.transform = CGAffineTransform.identity
       }
   }
}

extension ViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        didDismissDetailViewController()
    }
}

//Old BottomDetailViewController presentation logic
 /*
  if let detailViewController = {
      // Customize the detailViewController with data from the selected annotation if needed
      detailViewController.unit = unit
      detailViewController.modalPresentationStyle = .custom
      detailViewController.transitioningDelegate = self
      present(detailViewController, animated: true, completion: nil)
      
  }
 if let detailViewController = storyboard.instantiateViewController(withIdentifier: "BottomDetailViewController") as? BottomDetailViewController {
     // Customize the detailViewController with data from the selected annotation if needed
      let bottomDetailVC = BottomDetailViewController()
      bottomDetailVC.modalPresentationStyle = .custom
      bottomDetailVC.transitioningDelegate = presentationManager

      // Set the healthUnit property before presenting the BottomDetailViewController
      //print(bottomDetailVC.unit?.name ?? "Unfound")

      present(bottomDetailVC, animated: true, completion: nil)
     
     detailViewController.modalPresentationStyle = .custom
     detailViewController.transitioningDelegate = self
     present(detailViewController, animated: true, completion: nil)
     
 }*/
