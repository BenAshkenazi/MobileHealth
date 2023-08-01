//
//  MyCustomViewController.swift
//  MobileHealthApp
//
//  Created by Fawwaz Firdaus on 7/15/23.
//

import Foundation
import UIKit

class BottomSheetContentViewController: UIViewController {

    @IBOutlet var avaTitle: UILabel!
    @IBOutlet var rangeTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var rangePicker: UIButton!
    @IBOutlet var faqButton: UIButton!
    
    var chosenRange = 0.0
    
    weak var delegate: BottomSheetDelegate?

    var selectedDateAndTime: Date {
        return datePicker.date
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = .white
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
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        // Search functionality will be implemented here.
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
        //rangePicker.titleLabel?.font = .systemFont(ofSize: 30)
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
        
        // Search Button (Centered)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        searchButton.topAnchor.constraint(equalTo: rangePicker.bottomAnchor, constant: 32).isActive = true

        faqButton.translatesAutoresizingMaskIntoConstraints = false
        faqButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        faqButton.topAnchor.constraint(equalTo: rangePicker.bottomAnchor, constant: 32).isActive = true
        
        let buttonSpacing: CGFloat = 1.0
        faqButton.trailingAnchor.constraint(equalTo: avaTitle.leadingAnchor, constant: -buttonSpacing).isActive = true
        
        // Height Constraint to make sure views fit in the top 30%
        let topViewHeight = self.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: topViewHeightMultiplier)
        topViewHeight.priority = .defaultHigh // Give priority to this constraint to prevent conflicts
        topViewHeight.isActive = true
    }

}

