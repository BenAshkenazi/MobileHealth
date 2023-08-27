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
import error

class BottomSheetContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var avaTitle: UILabel!
    @IBOutlet var rangeTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var rangePicker: UIButton!
   // @IBOutlet var faqButton: UIButton!
    
    @IBOutlet var ShowClosedButton: UIButton!
    @IBOutlet weak var unitsListView: UITableView!
    
    var mobileUnits: [HealthUnit] = []
    
    var showClosedToggle = true
    var chosenRange = 0.0
    var cellColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
    
    weak var delegate: BottomSheetDelegate?

    var selectedDateAndTime: Date {
        return datePicker.date
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
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
        
        ShowClosedButton.backgroundColor = .white
        ShowClosedButton.layer.cornerRadius = 5.0
       

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        unitsListView.reloadData()
        
    }
    
    @IBAction func ShowClosedUnitsTapped(_ sender: Any) {
         updateShowClosedText()
        delegate?.didTapSearchButton(date: selectedDateAndTime, range: chosenRange, showClosed: showClosedToggle)
        showClosedToggle = !showClosedToggle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mobileUnits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitCell", for: indexPath)
        let unit = mobileUnits[indexPath.row]
        cell.textLabel?.text = unit.name
        cell.backgroundColor = cellColor

        // Set the selection style to none
        cell.selectionStyle = .none
       
        // You can customize the cell further as needed
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            
            // Highlight with the custom color
            cell.contentView.backgroundColor = UIColor(named: "LogoColor") // FFD4EE

            // Perform the segue and other necessary actions
            performSegue(withIdentifier: "showDetail", sender: self)

            // Delay the deselection and color revert by 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                tableView.deselectRow(at: indexPath, animated: true)
                cell.contentView.backgroundColor = self.cellColor// Original color
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
          
          showClosedToggle = false
          updateShowClosedText()
          if let delegate = delegate {
              delegate.didTapSearchButton(date: selectedDate, range: chosenRange, showClosed: showClosedToggle)
          } else {
              print("Delegate is nil")
          }
          
          
          searchButton.isEnabled = false
          let timer = Timer.scheduledTimer(withTimeInterval: 1.25, repeats: false) { timer in
              self.searchButton.isEnabled = true
          }
    }
    
    func updateShowClosedText(){
        if ShowClosedButton.titleLabel?.text == "Hide Closed Units" {
            showClosedToggle = false
        }else{
            showClosedToggle = true
        }
        if(showClosedToggle){
            ShowClosedButton.setTitle("Hide Closed Units", for: .normal)
        }else{
            ShowClosedButton.setTitle("Show Closed Units", for: .normal)
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
    
    func setupRangePicker(){
        //Sets chosen range equal to value within range picker
        let optionClosure = {(action: UIAction) in
            print(action.title)
            if(action.title == "Anywhere".localized){
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
            UIAction(title: "Anywhere".localized, state: .on, handler: optionClosure),
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
        
        // Height Constraint to make sure views fit in the top 30%
        let topViewHeight = self.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: topViewHeightMultiplier)
        topViewHeight.priority = .defaultHigh // Give priority to this constraint to prevent conflicts
        topViewHeight.isActive = true
    }

}



