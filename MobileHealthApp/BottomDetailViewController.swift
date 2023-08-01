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
    @IBOutlet var proxLabel: UILabel!
    @IBOutlet var surveyButton: UIButton!
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var daysLabel: UILabel!
    
    weak var delegate: BottomSheetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        setUpProximity()
        setUpHours()
        setUpDays()
    
        
    
    }
    
    func setUpTitle(){
        if let name = unit?.name{
                nameLabel.text = name
        }
    }
    
    func setUpProximity(){
        var proxText = "User Location not found"
        if var proxVal = unit?.prox{
            proxVal = round(proxVal * 100) / 100.0
            print("The unit is this far away: \(proxVal)")
            if(proxVal != -1.0){
                proxText = "Distance: \(proxVal) miles"
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
                
                hoursLabel.text = "Opening Hours: \(open) AM - \(close) PM"
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
        daysLabel.text = "Days available this month:\n"+daysTxt
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


