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

class BottomSheetContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var avaTitle: UILabel!
    @IBOutlet var rangeTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var rangePicker: UIButton!
   // @IBOutlet var faqButton: UIButton!
    
    @IBOutlet weak var unitsListView: UITableView!
    
    var mobileUnits: [HealthUnit] = []
    
    var chosenRange = 0.0
    
    weak var delegate: BottomSheetDelegate?

    var selectedDateAndTime: Date {
        return datePicker.date
    }

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
        
        unitsListView.register(UnitTableViewCell.self, forCellReuseIdentifier: "UnitCell")
        getDatabase()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileUnits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitCell", for: indexPath)
        let unit = mobileUnits[indexPath.row]
        cell.textLabel?.text = unit.name
        cell.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)

        // Set the selection style to none
        cell.selectionStyle = .none

        // You can customize the cell further as needed
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            
            // Highlight with the custom color
            cell.contentView.backgroundColor = UIColor(red: 255 / 255.0, green: 212 / 255.0, blue: 238 / 255.0, alpha: 1.0) // FFD4EE

            // Perform the segue and other necessary actions
            performSegue(withIdentifier: "showDetail", sender: self)

            // Delay the deselection and color revert by 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tableView.deselectRow(at: indexPath, animated: true)
                cell.contentView.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0) // Original color
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let destinationVC = segue.destination as? BottomDetailViewController,
           let selectedIndexPath = unitsListView.indexPathForSelectedRow {
            let selectedUnit = mobileUnits[selectedIndexPath.row] // Use mobileUnits instead of units
            destinationVC.unit = selectedUnit
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
                    units.append(newUnit)
                }
            }
            
            let completeUnits = units.filter { $0.isComplete() }
            print("Complete units count: \(completeUnits.count)") // Print the count of complete units
            // Update mobile units and reload table view
            self.mobileUnits = completeUnits
            self.unitsListView.reloadData()
        }
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
    }

}



