//
//  BottomSheetContentViewController.swift
//  MobileHealthApp
//
//  Created by Fawwaz Firdaus on 7/15/23.
//

import UIKit
import CoreLocation

class BottomContentViewController: UIViewController {

    @IBOutlet var avaTitle: UILabel!
    @IBOutlet var rangeTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var rangePicker: UIButton!
   // @IBOutlet var faqButton: UIButton!
    @IBOutlet var listLabel: UILabel!

    @IBOutlet var ShowClosedButton: UIButton!
    @IBOutlet weak var unitsListView: RestrictedUITableView!

    var databaseService: DatabaseService?
    var locationService: LocationService?

    var mobileUnits: [HealthUnit] = [] {
        didSet {
            print("This is the mobileunits.count \(mobileUnits.count)")
            openUnitsNextWeek = mobileUnits.filter { isOpenWithinNextWeek(unit: $0) }.sortedByAvailableDay()
            // sortUnitsByAvailableDay()
            unitsListView.reloadData()
        }
    }

    var openUnitsNextWeek: [HealthUnit] = [] {
        didSet {
            unitsListView.reloadData()
        }
    }
    var chosenRange = 0.0
    var showClosedToggle = true

    weak var delegate: BottomSheetDelegate?

    var currentDate = Date()
    // let calendar = Calendar.current
    let calendar = Calendar(identifier: .gregorian)
    var oneWeekLater: Date?

    var cellColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)

    var selectedDateAndTime: Date {
        datePicker.date
    }

    var userLocation: CLLocationCoordinate2D? {
        locationService?.getUserLocation()
    }
    // let locationManager = CLLocationManager()

    // let geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()
        ShowClosedButton.backgroundColor = .white
        ShowClosedButton.layer.cornerRadius = 5.0

        self.view.layer.cornerRadius = 25
        self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOffset = .init(width: 0, height: -2)
        self.view.layer.shadowRadius = 20
        self.view.layer.shadowOpacity = 0.5
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        // setupSearchButton()
        setupDatePicker()
        setupRangePicker()
        setupConstraints()

        unitsListView.dataSource = self
        unitsListView.delegate = self
        unitsListView.backgroundColor = cellColor
        unitsListView.layer.cornerRadius = 20
        unitsListView.layer.masksToBounds = true
        unitsListView.separatorStyle = .singleLine
        unitsListView.separatorColor = .black

        view.addSubview(unitsListView)
        unitsListView.register(UnitTableViewCell.self, forCellReuseIdentifier: "UnitCell")

        // mobileUnits = databaseService?.getUnfilteredList() ?? []
        databaseService?.fetchHealthUnits(completion: { healthUnits in
            self.mobileUnits = healthUnits
            self.setLocations()
        })
        filterByWeek()
        // Set the desired time zone to Phoenix, AZ
        let phoenixTimeZone = TimeZone(identifier: "America/Phoenix")!

        // Adjust the time zone of currentDate and oneWeekLater
        currentDate = currentDate.inTimeZone(phoenixTimeZone)
        // oneWeekLater = oneWeekLater?.inTimeZone(phoenixTimeZone)

        // oneWeekLater = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)
        oneWeekLater = calendar.date(byAdding: .day, value: 6, to: currentDate)
        // setupDates()
        // print("Current Date: \(currentDate)")
        // print("One Week Later: \(oneWeekLater)")
        // Now you can use `oneWeekLater` elsewhere in your class
        // print("Number of mobile units: \(mobileUnits.count)")
        // openUnitsNextWeek = mobileUnits.filter { isOpenWithinNextWeek(unit: $0) }
        // print("Number of units open next week: \(openUnitsNextWeek.count)")
        print("Current Date: \(currentDate)")
        // print("One Week Later: \(oneWeekLater)")

        // locationService?.askUserForLocation()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()

        unitsListView.delaysContentTouches = false

    }

    func setLocations() {
        // userLocation = locationService?.getUserLocation()
        if let userLocation  = userLocation {
            for unit in self.mobileUnits {
                unit.isWithin(range: 0.0, userLoc: userLocation, address: unit.address ?? "Failed") { _ in
                    print("For the next unit, prox is: \(unit.prox)")
                }
            }
        }
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

    @IBAction func showClosedUnitsTapped(_ sender: Any) {
       print("Kar: Closed units button tapped:\(showClosedToggle)")
       updateShowClosedText(searching: false)

       delegate?.didTapSearchButton(date: selectedDateAndTime, range: chosenRange, showClosed: showClosedToggle, centerOnUser: false)
       showClosedToggle = !showClosedToggle
   }

    func updateShowClosedText(searching: Bool) {
        if searching {
            ShowClosedButton.setTitle("Show Closed Units", for: .normal)
            showClosedToggle = false
        }else{
            if ShowClosedButton.titleLabel?.text == "Hide Closed Units" {
                ShowClosedButton.setTitle("Show Closed Units", for: .normal)
                showClosedToggle = false
            } else {
                ShowClosedButton.setTitle("Hide Closed Units", for: .normal)
                showClosedToggle = true
            }
        }
//        if !searching {
//            if ShowClosedButton.titleLabel?.text == "Hide Closed Units" {
//                showClosedToggle = false
//            } else {
//                showClosedToggle = true
//            }
//        }
//
//       if showClosedToggle {
//           ShowClosedButton.setTitle("Hide Closed Units", for: .normal)
//       } else {
//           ShowClosedButton.setTitle("Show Closed Units", for: .normal)
//       }
   }

    func filterByWeek() {

        let completeUnits = mobileUnits.filter { $0.isComplete() }
        print("Complete units count: \(completeUnits.count)") // Print the count of complete units
        // Sort the units by availableDay
        let sortedUnits = completeUnits.sortedByAvailableDay()
        // Update mobile units and reload table view
        self.mobileUnits = sortedUnits
        self.unitsListView.reloadData()
        print("Fetched mobile units count: \(mobileUnits.count)")
        print("Open units next week count: \(openUnitsNextWeek.count)")

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

        var availableDay: Int?

        for dayInt in days {
            // let unitDate = DateComponents(calendar: calendar, year: year, month: month, day: dayInt).date
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = dayInt
            let unitDate = calendar.date(from: components)

            if let unitDate = unitDate {
                print("Constructed date: \(unitDate), currentDate: \(currentDate), oneWeekLater: \(oneWeekLater!)") // Printing the dates being compared

                if unitDate >= currentDate && unitDate <= oneWeekLater! {
                    let weekday = calendar.component(.weekday, from: unitDate)
                    // availableDay = calendar.component(.weekday, from: unitDate)
                    let daysDifference = calendar.dateComponents([.day], from: currentDate, to: unitDate).day!
                    availableDay = 2 + (daysDifference + calendar.component(.weekday, from: currentDate)) % 7
                    if availableDay == 0 {
                        availableDay = 7
                    }
                    unit.availableDay = availableDay
                    print("Constructed date: \(unitDate), availableDay: \(availableDay!)")
                    // return true
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

        // return false
        return availableDay != nil
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        // Check for values set within range picker and date picker
        let selectedDate = datePicker.date
        // userLocation = locationService?.getUserLocation()
        print("This range was chosen \(chosenRange)")
        print("Search button tapped. Selected date and time: \(selectedDate)")

        updateShowClosedText(searching: true)
        if let delegate = delegate {
            delegate.didTapSearchButton(date: selectedDate, range: chosenRange, showClosed: false, centerOnUser: true)
        } else {
            print("Delegate is nil")
        }
    }

    func setupSearchButton() {
        searchButton.layer.cornerRadius = searchButton.frame.height / 2
        searchButton.clipsToBounds = true
    }

    func setupDatePicker() {
        datePicker.alpha = 1
        datePicker.layer.cornerRadius = 10
        datePicker.clipsToBounds = true

        datePicker.setValue(UIColor(named: "LogoColor"), forKeyPath: "textColor")
        datePicker.setValue(false, forKeyPath: "highlightsToday")
        datePicker.setValue(UIColor.white, forKey: "backgroundColor")
    }

    func setupRangePicker() {
        // Sets chosen range equal to value within range picker
        let optionClosure = {(action: UIAction) in
            print(action.title)
            if action.title == "Anywhere" {
                self.chosenRange = 0.0
            } else if action.title == "1 Mile" {
                self.chosenRange = 1.0
            } else if action.title == "5 Miles" {
                self.chosenRange = 5.0
            } else if action.title == "10 Miles" {
                self.chosenRange = 10.0
            } else if action.title == "15 Miles" {
                self.chosenRange = 15.0
            } else {
                self.chosenRange = 25.0
            }
        }

        rangePicker.menu = UIMenu(children: [
            UIAction(title: "Anywhere", state: .on, handler: optionClosure),
            UIAction(title: "1 Mile", state: .on, handler: optionClosure),
            UIAction(title: "5 Miles", handler: optionClosure),
            UIAction(title: "10 Miles", handler: optionClosure),
            UIAction(title: "15 Miles", handler: optionClosure),
            UIAction(title: "25 Miles", handler: optionClosure)
        ])

        rangePicker.showsMenuAsPrimaryAction = true
        rangePicker.changesSelectionAsPrimaryAction = true

    }

    func setupConstraints() {
        let topViewHeightMultiplier: CGFloat = 0.3

        self.view.translatesAutoresizingMaskIntoConstraints = false

        // Height Constraint to make sure views fit in the top 30%
        let topViewHeight = self.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: topViewHeightMultiplier)
        topViewHeight.priority = .defaultHigh // Give priority to this constraint to prevent conflicts
        topViewHeight.isActive = true

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

extension BottomContentViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openUnitsNextWeek.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitCell", for: indexPath) as! UnitTableViewCell
        let unit = openUnitsNextWeek[indexPath.row]
        cell.configure(with: unit)
        cell.backgroundColor = cellColor
        cell.selectionStyle = .none
        return cell
    }
}

extension BottomContentViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Perform the segue and other necessary actions
        setLocations()
        // unitsListView.reloadData()
        performSegue(withIdentifier: "showDetail", sender: self)

        // Delay the deselection and color revert by 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
