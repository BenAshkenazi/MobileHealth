//
//  MyCustomViewController.swift
//  MobileHealthApp
//
//  Created by Fawwaz Firdaus on 7/15/23.
//

import Foundation
import UIKit

class BottomSheetContentViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var rangePicker: UIButton!
    
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
        setupSearchButton()
        setupDatePicker()
        setupRangePicker()
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
    
    
}

