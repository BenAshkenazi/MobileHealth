//
//  DetailViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/13/23.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    var unit: HealthUnit?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.view.backgroundColor = UIColor(red:127.0/255.0, green:86.0/255.0, blue:108.0/255.0, alpha: 1.0)


        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        nameLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        nameLabel.numberOfLines = 0
        nameLabel .textColor = .black
        nameLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/6)
        nameLabel .textAlignment = .center
        nameLabel .text = unit?.name
        
        
        /*let isoDateString = (unit?.open)!
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: "America/Phoenix")
        
        // Parse the ISO8601 date string and convert it to Arizona time
        print("Attempting iso date formatter")
        if let isoDate = dateFormatter.date(from: isoDateString) {
            
            // Format the converted date for display
            dateFormatter.dateFormat = "HH:mm"
            let arizonaDateString = dateFormatter.string(from: isoDate)
            
            print("Arizona Time:", arizonaDateString)
        }*/
       
        
        let hoursLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
        hoursLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        hoursLabel.numberOfLines = 0
        hoursLabel .textColor = .black
        hoursLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/5)
        hoursLabel .textAlignment = .center
        
        hoursLabel .text = "\(String(describing: (unit?.rawopen)!)) - \(String(describing: (unit?.rawclose)!))"
        //hoursLabel .text = "\(Date.dateFromISOString(string: (unit?.open)!))"
        
        //Days Open Label
        let daysLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
        daysLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        daysLabel.numberOfLines = 0
        daysLabel .textColor = .black
        daysLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/4.5)
        daysLabel .textAlignment = .center
        daysLabel .text = "\((unit?.rawdays)!)"
        //Days open july?
        
        //Address
        let addrLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
        addrLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        addrLabel.numberOfLines = 0
        addrLabel .textColor = .black
        addrLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/4)
        addrLabel .textAlignment = .center
        addrLabel .text = unit?.address

        //apple maps button
        let openMapsButton = UIButton(type: .system)
        openMapsButton.setTitle("Open in Maps", for: .normal)
        openMapsButton.addTarget(self, action: #selector(openMaps), for: .touchUpInside)
        openMapsButton.frame = CGRect(x: 100, y: screenHeight/3.25, width: 200, height: 50)
        view.addSubview(openMapsButton)
        
        
        //learn more button (to faq)
        
        
        //phone call button
        let callButton = UIButton(type: .system)
       callButton.setTitle("Call", for: .normal)
       callButton.addTarget(self, action: #selector(makeCall), for: .touchUpInside)
        callButton.frame = CGRect(x: 100, y: screenHeight/3, width: 200, height: 50)
       
        let sButton = UIButton(type: .system)
       sButton.setTitle("Survey Form", for: .normal)
       sButton.addTarget(self, action: #selector(openSurveyForm), for: .touchUpInside)
        sButton.frame = CGRect(x: 100, y: screenHeight/2.75, width: 200, height: 50)
        //email button
        
        //survey form button
        

        self.view.addSubview(nameLabel)
        self.view.addSubview(hoursLabel)
        self.view.addSubview(daysLabel)
        self.view.addSubview(addrLabel)
        self.view.addSubview(callButton)
        self.view.addSubview(sButton)
    }
    
    @objc func openMaps() {
        let address = unit?.address!
        let encodedAddress = address!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let mapURLString = "http://maps.apple.com/?address=\(encodedAddress)"
        guard let mapURL = URL(string: mapURLString) else { return }
        
        // Open the Apple Maps URL
        UIApplication.shared.open(mapURL)
    }
    
    @objc func makeCall() {
        let phoneNumber = unit?.number
        if let phoneURL = phoneNumber, UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func sendEmail() {
        let phoneNumber = unit?.number
        if let phoneURL = phoneNumber, UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func openSurveyForm() {
        let surveyURLString = "https://forms.gle/hHqVW5EZaTWiTVnQ8"
        guard let surveyURL = URL(string: surveyURLString) else { return }
        
        // Open the Apple Maps URL
        UIApplication.shared.open(surveyURL)
    }
    
}

extension Date {
    static func ISOStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.string(from: date).appending("Z")
    }
    
    static func dateFromISOString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: string)
    }
}
