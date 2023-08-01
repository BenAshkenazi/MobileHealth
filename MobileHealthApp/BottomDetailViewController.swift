//
//  BottomDetailViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/31/23.
//

import Foundation
import UIKit

class BottomDetailViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var unit: HealthUnit?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var mapsButton: UIButton!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var faqButton: UIButton!
    @IBOutlet var proxTitle: UILabel!
    @IBOutlet var proxLabel: UILabel!
    @IBOutlet var surveyButton: UIButton!
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var daysLabel: UILabel!
    
    @IBOutlet var hoursTitle: UILabel!
    
    @IBOutlet var daysTitle: UILabel!
    @IBOutlet var Line1: UIImageView!
    @IBOutlet var Line2: UIImageView!
    @IBOutlet var Line3: UIImageView!
    
    weak var delegate: BottomSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        setUpProximity()
        setUpHours()
        setUpDays()
        setUpConstraints()
    
        
    
    }
    
    func setUpTitle(){
        if let name = unit?.name{
                nameLabel.text = name
        }
    }
    
    func setUpProximity(){
        var proxText = "User Location not found"
        proxTitle.text = ""
        if var proxVal = unit?.prox{
            proxVal = round(proxVal * 100) / 100.0
            print("The unit is this far away: \(proxVal)")
            if(proxVal != -1.0){
                proxTitle.text = "Distance:"
                proxText = "\(proxVal) miles"
            }
        }
        proxLabel.text = proxText
    }
    
    func setUpHours(){
        if let open = unit?.open{
            if var close = unit?.close{
                if var firstHour = Int(close.prefix(2)){
                    if(firstHour > 12){
                        firstHour-=12
                        close = "\(firstHour):\(close.suffix(2))"
                    }
                }
                hoursTitle.text = "Hours:"
                hoursLabel.text = "\(open) AM - \(close) PM"
            }
        }
    }
    
    func setUpDays(){
        var daysTxt = ""
        
        if let days = unit?.days, let monthYear = unit?.MonthYear {
            print("This is the first letter of the month \(monthYear.suffix(1))")
            var monthString = monthYear.suffix(2)
            let monthNum = Int(monthString) ?? -1
            
            if monthNum == -1 || monthNum < 10 {
                monthString = monthYear.suffix(1)
            }
            
            let dayCount = days.count-1
            for (index, day) in days.enumerated() {
                if index == dayCount {
                    daysTxt += "\(monthString)/\(day ?? 0)"
                }else if(index % 4 == 0 && index != 0){
                    daysTxt += "\(monthString)/\(day ?? 0),\n"
                }else {
                    daysTxt += "\(monthString)/\(day ?? 0),  "
                }
            }
        }
        daysTitle.text = "Days available this month:"
        daysLabel.text = daysTxt
    }
    
    func setUpConstraints(){
        // Disable the automatic translation of constraints into Autoresizing Masks
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        mapsButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.translatesAutoresizingMaskIntoConstraints = false
        faqButton.translatesAutoresizingMaskIntoConstraints = false
        proxLabel.translatesAutoresizingMaskIntoConstraints = false
        surveyButton.translatesAutoresizingMaskIntoConstraints = false
        hoursLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        Line1.translatesAutoresizingMaskIntoConstraints = false
        Line2.translatesAutoresizingMaskIntoConstraints = false
        Line3.translatesAutoresizingMaskIntoConstraints = false
        proxTitle.translatesAutoresizingMaskIntoConstraints = false
        hoursTitle.translatesAutoresizingMaskIntoConstraints = false
        daysTitle.translatesAutoresizingMaskIntoConstraints = false
        // Set up constraints for all the elements
        NSLayoutConstraint.activate([
            // Constraints for nameLabel
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),

            // Constraints for dismissButton
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            dismissButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),

            // Constraints for mapsButton, callButton, faqButton, and surveyButton
           mapsButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
           mapsButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),

           callButton.topAnchor.constraint(equalTo: mapsButton.topAnchor),
           callButton.leadingAnchor.constraint(equalTo: mapsButton.trailingAnchor, constant: 8),

           faqButton.topAnchor.constraint(equalTo: mapsButton.topAnchor),
           faqButton.leadingAnchor.constraint(equalTo: callButton.trailingAnchor, constant: 8),

           surveyButton.topAnchor.constraint(equalTo: mapsButton.topAnchor),
           surveyButton.leadingAnchor.constraint(equalTo: faqButton.trailingAnchor, constant: 8),
           surveyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            Line1.topAnchor.constraint(equalTo: mapsButton.bottomAnchor, constant: 1),
            Line1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            Line1.heightAnchor.constraint(equalToConstant: 25.0),
            
            proxTitle.topAnchor.constraint(equalTo: Line1.bottomAnchor, constant: 1),
            proxTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Constraints for proxLabel
            proxLabel.topAnchor.constraint(equalTo: proxTitle.bottomAnchor, constant: 10),
            proxLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor), //middle of screen
            //proxLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),

            Line2.topAnchor.constraint(equalTo: proxLabel.bottomAnchor, constant: 4),
            Line2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            Line2.heightAnchor.constraint(equalToConstant: 25.0),

            hoursTitle.topAnchor.constraint(equalTo: Line2.bottomAnchor, constant: 1),
            hoursTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Constraints for hoursLabel
            hoursLabel.topAnchor.constraint(equalTo: hoursTitle.bottomAnchor, constant: 10),
            hoursLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor), //middle of screen
            //hoursLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            
            Line3.topAnchor.constraint(equalTo: hoursLabel.bottomAnchor, constant: 4),
            Line3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            Line3.heightAnchor.constraint(equalToConstant: 25.0),
            
            daysTitle.topAnchor.constraint(equalTo: Line3.bottomAnchor, constant: 1),
            daysTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Constraints for daysLabel
            daysLabel.topAnchor.constraint(equalTo: daysTitle.bottomAnchor, constant: 10),
            daysLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),  //middle of screen
            //daysLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
        ])
        
        let buttons = [mapsButton, callButton, faqButton, surveyButton]
        for i in 1..<buttons.count {
            if let button1 = buttons[i]{
                if let button2 = buttons[i-1]{
                    button1.widthAnchor.constraint(equalTo: button2.widthAnchor).isActive = true
                }
            }
        }
    }
    
    @IBAction func openMaps(_ sender: Any) {
        if let address = unit?.address {
            let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let mapURLString = "http://maps.apple.com/?address=\(encodedAddress)"
            guard let mapURL = URL(string: mapURLString) else { return }
            
            // Open the Apple Maps URL
            UIApplication.shared.open(mapURL)
        }else{
            print("Map Fetch Failed")
            return
        }
        
    }

    
    @IBAction func makeCall(_ sender: Any) {
        let phoneNumber = unit?.number
        if let phoneURL = phoneNumber, UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func openSurveyForm(_ sender: Any) {
        let surveyURLString = "https://forms.gle/QYRetAh1XRHutMqp9"
        guard let surveyURL = URL(string: surveyURLString) else { return }
        
        // Open the Apple Maps URL
        UIApplication.shared.open(surveyURL)
    }
    
    // Method to dismiss the presented view when the button is tapped
    @IBAction func dismissButtonTapped(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}


