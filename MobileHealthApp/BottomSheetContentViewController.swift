//
//  BottomSheetContentViewController.swift
//  MobileHealthApp
//
//  Created by Fawwaz Firdaus on 7/15/23.
//

import Foundation
import UIKit
import Firebase
import FirebaseCore
import CoreLocation

protocol TableViewControllerDelegate: AnyObject {
    func tableViewDidBeginScrolling()
    func tableViewDidEndScrolling()
}

class BottomSheetContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIScrollViewDelegate {

    @IBOutlet var avaTitle: UILabel!
    @IBOutlet var rangeTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var rangePicker: UIButton!
   // @IBOutlet var faqButton: UIButton!
    @IBOutlet var listLabel: UILabel!
    
    @IBOutlet weak var unitsListView: UITableView!
    
    //var mobileUnits: [HealthUnit] = []
    var mobileUnits: [HealthUnit] = [] {
        didSet {
            openUnitsNextWeek = mobileUnits.filter { isOpenWithinNextWeek(unit: $0) }.sortedByAvailableDay()
            //sortUnitsByAvailableDay()
            unitsListView.reloadData()
        }
    }

    var openUnitsNextWeek: [HealthUnit] = []
    var chosenRange = 0.0
    
    weak var delegate: BottomSheetDelegate?
    
    var currentDate = Date()
    //let calendar = Calendar.current
    let calendar = Calendar(identifier: .gregorian)
    var oneWeekLater: Date?
    
    var selectedDateAndTime: Date {
        return datePicker.date
    }
    
    var userLocation: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    let geocoder = CLGeocoder()
    
    weak var tableDelegate: TableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
        self.view.layer.cornerRadius = 25
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOffset = .init(width: 0, height: -2)
        self.view.layer.shadowRadius = 20
        self.view.layer.shadowOpacity = 0.5
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        //setupSearchButton()
        setupDatePicker()
        setupRangePicker()
        setupConstraints()
        
        unitsListView.dataSource = self
        unitsListView.delegate = self
        unitsListView.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
        unitsListView.layer.cornerRadius = 20
        unitsListView.layer.masksToBounds = true
        unitsListView.separatorStyle = .singleLine
        unitsListView.separatorColor = .black
        
        view.addSubview(unitsListView)
        unitsListView.register(UnitTableViewCell.self, forCellReuseIdentifier: "UnitCell")
        getDatabase()
        
        // Set the desired time zone to Phoenix, AZ
        let phoenixTimeZone = TimeZone(identifier: "America/Phoenix")!

        // Adjust the time zone of currentDate and oneWeekLater
        currentDate = currentDate.inTimeZone(phoenixTimeZone)
        //oneWeekLater = oneWeekLater?.inTimeZone(phoenixTimeZone)
        
        //oneWeekLater = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)
        oneWeekLater = calendar.date(byAdding: .day, value: 6, to: currentDate)
        //setupDates()
        //print("Current Date: \(currentDate)")
        //print("One Week Later: \(oneWeekLater)")
        // Now you can use `oneWeekLater` elsewhere in your class
        //print("Number of mobile units: \(mobileUnits.count)")
        //openUnitsNextWeek = mobileUnits.filter { isOpenWithinNextWeek(unit: $0) }
        //print("Number of units open next week: \(openUnitsNextWeek.count)")
        print("Current Date: \(currentDate)")
        //print("One Week Later: \(oneWeekLater)")
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openUnitsNextWeek.count
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitCell", for: indexPath) as! UnitTableViewCell
//        let unit = mobileUnits[indexPath.row]
//        //cell.textLabel?.text = unit.name
//        cell.configure(with: unit)
//        cell.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
//
//        // Set the selection style to none
//        cell.selectionStyle = .none
//
//        // You can customize the cell further as needed
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitCell", for: indexPath) as! UnitTableViewCell
        let unit = openUnitsNextWeek[indexPath.row]
        cell.configure(with: unit)
        cell.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
        cell.selectionStyle = .none
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) {
//
//            // Highlight with the custom color
//            cell.contentView.backgroundColor = UIColor(red: 255 / 255.0, green: 212 / 255.0, blue: 238 / 255.0, alpha: 1.0) // FFD4EE
//
//            // Perform the segue and other necessary actions
//            performSegue(withIdentifier: "showDetail", sender: self)
//
//            // Delay the deselection and color revert by 1 second
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                tableView.deselectRow(at: indexPath, animated: true)
//                cell.contentView.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0) // Original color
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform the segue and other necessary actions
        performSegue(withIdentifier: "showDetail", sender: self)

        // Delay the deselection and color revert by 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let destinationVC = segue.destination as? BottomDetailViewController,
           let selectedIndexPath = unitsListView.indexPathForSelectedRow {
            let selectedUnit = openUnitsNextWeek[selectedIndexPath.row] // Use mobileUnits instead of units
            destinationVC.unit = selectedUnit
            destinationVC.userLocation = userLocation
        }
    }

    func getDatabase() {
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
            // Gets data from Firebase and inits a mobile health unit class
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
                    print("Unit: \(String(describing: newUnit.name)), Complete: \(newUnit.isComplete())") // Print each unit and whether it's complete
                    newUnit.calculateDistanceFromUserLocation(userLoc: userLocation) { success in
                        if success {
                            // Reload your table view data here
                            DispatchQueue.main.async {
                                self.unitsListView.reloadData()
                            }
                        }
                    }
                    units.append(newUnit)
                }
            }

            let completeUnits = units.filter { $0.isComplete() }
            print("Complete units count: \(completeUnits.count)") // Print the count of complete units
            // Sort the units by availableDay
            let sortedUnits = completeUnits.sortedByAvailableDay()
            // Update mobile units and reload table view
            self.mobileUnits = sortedUnits
            //self.unitsListView.reloadData()
            print("Fetched mobile units count: \(mobileUnits.count)")
            print("Open units next week count: \(openUnitsNextWeek.count)")
        }
    }
    
    func isOpenWithinNextWeek(unit: HealthUnit) -> Bool {
        print("Checking unit: \(String(describing: unit.name))") // Printing the unit being checked

        guard let monthYearString = unit.MonthYear else {
            print("MonthYear is nil for unit: \(unit)")
            return false
        }

        let monthYearComponents = monthYearString.split(separator: "-")
        guard monthYearComponents.count == 2,
              let month = Int(monthYearComponents[1]),
              let year = Int(monthYearComponents[0]) else {
            print("Error parsing: \(monthYearString)")
            return false
        }
        
        print("Parsed month: \(month) and year: \(year)") // Printing parsed month and year

        let days = unit.daysAsIntegers

        print("Days for unit: \(days)") // Printing the list of days
        
        var availableDay: Int? = nil

        for dayInt in days {
            //let unitDate = DateComponents(calendar: calendar, year: year, month: month, day: dayInt).date
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = dayInt
            let unitDate = calendar.date(from: components)
            
            if let unitDate = unitDate {
                print("Constructed date: \(unitDate), currentDate: \(currentDate), oneWeekLater: \(oneWeekLater!)") // Printing the dates being compared
                
                if unitDate >= currentDate && unitDate <= oneWeekLater! {
                    let weekday = calendar.component(.weekday, from: unitDate)
                    //availableDay = calendar.component(.weekday, from: unitDate)
                    let daysDifference = calendar.dateComponents([.day], from: currentDate, to: unitDate).day!
                    availableDay = 2 + (daysDifference + calendar.component(.weekday, from: currentDate)) % 7
                    if availableDay == 0 {
                        availableDay = 7
                    }
                    unit.availableDay = availableDay
                    print("Constructed date: \(unitDate), availableDay: \(availableDay!)")
                    //return true
                    break
                }
            } else {
                print("Failed to construct date for day: \(dayInt)")
            }
        }
        
        // Save the available day if found
        if let availableDay = availableDay {
            // Here you can use the 'availableDay' integer as needed
            print("Available day: \(availableDay)")
        }

        //return false
        return availableDay != nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last?.coordinate else {
            return
        }

        // Update your userLocation property with the real-time location
        self.userLocation = userLocation

        // Perform any additional actions that require the updated user location
        getDatabase()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    // Inside your scrollViewWillBeginDragging method
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableDelegate?.tableViewDidBeginScrolling()
    }
    
    // Inside your scrollViewDidEndDragging method
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        tableDelegate?.tableViewDidEndScrolling()
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        // Check for values set within range picker and date picker
        let selectedDate = datePicker.date
        
        print("This range was chosen \(chosenRange)")
        print("Search button tapped. Selected date and time: \(selectedDate)")
        
        if let delegate = delegate {
            delegate.didTapSearchButton(date: selectedDate, range: chosenRange)
        } else {
            print("Delegate is nil")
        }
    }
    
    func setupSearchButton() {
        searchButton.layer.cornerRadius = searchButton.frame.height / 2
        searchButton.clipsToBounds = true
    }
    
    func setupDatePicker() {
        datePicker.alpha = 0.8
        datePicker.layer.cornerRadius = 10
        datePicker.setValue(UIColor.black, forKeyPath: "textColor")
        datePicker.setValue(false, forKeyPath: "highlightsToday")
        datePicker.clipsToBounds = true
    }
    
    func setupRangePicker(){
        //Sets chosen range equal to value within range picker
        let optionClosure = {(action: UIAction) in
            print(action.title)
            if(action.title == "Anywhere"){
                self.chosenRange = 0.0
            }else if(action.title == "1 Mile"){
                self.chosenRange = 1.0
            }else if(action.title == "5 Miles"){
                self.chosenRange = 5.0
            }else if(action.title == "10 Miles"){
                self.chosenRange = 10.0
            }else if(action.title == "15 Miles"){
                self.chosenRange = 15.0
            }else{
                self.chosenRange = 25.0
            }
        }
        
        
        rangePicker.menu = UIMenu(children: [
            UIAction(title: "Anywhere", state: .on, handler: optionClosure),
            UIAction(title: "1 Mile", state: .on, handler: optionClosure),
            UIAction(title: "5 Miles", handler: optionClosure),
            UIAction(title: "10 Miles", handler: optionClosure),
            UIAction(title: "15 Miles", handler: optionClosure),
            UIAction(title: "25 Miles", handler: optionClosure),
        ])
        
        rangePicker.showsMenuAsPrimaryAction = true
        rangePicker.changesSelectionAsPrimaryAction = true

    }
    
    func setupConstraints() {
        let topViewHeightMultiplier: CGFloat = 0.3
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Ava Title (Top Left)
        avaTitle.translatesAutoresizingMaskIntoConstraints = false
        avaTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16).isActive = true
        avaTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        
        // Date Picker (Below Ava Title)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: avaTitle.bottomAnchor, constant: 8).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        //datePicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        
        // Range Title (Top Right)
        rangeTitle.translatesAutoresizingMaskIntoConstraints = false
        rangeTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32).isActive = true
        rangeTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        
        // Range Picker (Below Range Title)
        rangePicker.translatesAutoresizingMaskIntoConstraints = false
        rangePicker.topAnchor.constraint(equalTo: rangeTitle.bottomAnchor, constant: 8).isActive = true
        rangePicker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        
        let screenWidth = UIScreen.main.bounds.width
        
        // Search Button (Centered)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        searchButton.topAnchor.constraint(equalTo: rangePicker.bottomAnchor, constant: 32).isActive = true
        //searchButton.widthAnchor.constraint(lessThanOrEqualToConstant: screenWidth*0.30).isActive = true
        
        /*faqButton.translatesAutoresizingMaskIntoConstraints = false
        faqButton.topAnchor.constraint(equalTo: rangePicker.bottomAnchor, constant: 32).isActive = true
        faqButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        faqButton.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10).isActive = true
        let maxWidth = screenWidth * 0.25
        faqButton.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true*/
        
        // Height Constraint to make sure views fit in the top 30%
        let topViewHeight = self.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: topViewHeightMultiplier)
        topViewHeight.priority = .defaultHigh // Give priority to this constraint to prevent conflicts
        topViewHeight.isActive = true
        
        unitsListView.translatesAutoresizingMaskIntoConstraints = false
        unitsListView.topAnchor.constraint(equalTo: listLabel.bottomAnchor, constant: 16).isActive = true
        unitsListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        unitsListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        unitsListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16).isActive = true
        
        unitsListView.translatesAutoresizingMaskIntoConstraints = false
            
        NSLayoutConstraint.activate([
            unitsListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 170),
            unitsListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            unitsListView.topAnchor.constraint(equalTo: view.topAnchor, constant: 280),
            unitsListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])

    }
    

}

extension Array where Element == HealthUnit {
    func sortedByAvailableDay() -> [HealthUnit] {
        return self.sorted { (unit1, unit2) -> Bool in
            return unit1.availableDay ?? 0 < unit2.availableDay ?? 0
        }
    }
}

extension Date {
    func inTimeZone(_ timeZone: TimeZone) -> Date {
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents(in: timeZone, from: self)
        return calendar.date(from: currentComponents) ?? self
    }
}

