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
         

        /*if let dayOfWeek = calculateDayOfWeek(year: year, month: month, day: day) {
            print("The day of the week is:", dayOfWeek)
        } else {
            print("Invalid date.")
        }*/
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.view.backgroundColor = UIColor(red:127.0/255.0, green:86.0/255.0, blue:108.0/255.0, alpha: 1.0)


        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 40))
        nameLabel.font = UIFont.boldSystemFont(ofSize: screenHeight/25)
        nameLabel.numberOfLines = 0
        nameLabel .textColor = .black
        nameLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/6)
        nameLabel .textAlignment = .center
        nameLabel .text = unit?.name
        let attributedString = NSAttributedString(string: nameLabel.text ?? "",
                                                         attributes: [
                                                           NSAttributedString.Key.strokeColor: UIColor.white,
                                                           NSAttributedString.Key.strokeWidth: -0.25
                                                         ])
       nameLabel.attributedText = attributedString

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
        
        let backButton = UIButton(type: .custom)
        backButton.setTitle("Back", for: .normal)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.fill"), for: .normal)
        backButton.tintColor = .white
        backButton.frame = CGRect(x: screenWidth/12, y: screenHeight/12, width: screenHeight/10, height: screenHeight/14)
        backButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)


           

        
        let hoursLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 21))
        hoursLabel.font =  UIFont.boldSystemFont(ofSize: screenHeight/40)
        hoursLabel.numberOfLines = 0
        hoursLabel .textColor = .black
        hoursLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/5)
        hoursLabel .textAlignment = .center
        hoursLabel .text = "Hours: \(String(describing: (unit?.open)!)) - \(String(describing: (unit?.close)!))"
        //hoursLabel .text = "\(Date.dateFromISOString(string: (unit?.open)!))"
        
        
        //Days Open Label
        let avaLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        avaLabel.font = UIFont.boldSystemFont(ofSize: screenHeight/50)
        avaLabel.numberOfLines = 0
        avaLabel .textColor = .black
        avaLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/3.5)
        avaLabel .textAlignment = .center
        avaLabel .text = "Days Available This Month:"
        
        //Days Open Label
        let daysLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        daysLabel.font = UIFont.boldSystemFont(ofSize: screenHeight/60)
        daysLabel.numberOfLines = 0
        daysLabel .textColor = .black
        daysLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/3)
        daysLabel .textAlignment = .center
        var daysTxt = ""
        for day in (unit?.days)!{
            daysTxt = daysTxt+"\((unit?.MonthYear)!.suffix(2))/\(day!) "
        }
        daysLabel .text = daysTxt
        //Days open july?
        
        //Address
        let addrLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        addrLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        addrLabel.numberOfLines = 0
        addrLabel .textColor = .black
        addrLabel .center = CGPoint(x: screenWidth/3, y: screenHeight/1.45)
        addrLabel .textAlignment = .left
        addrLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        addrLabel.addGestureRecognizer(tapGesture)
        addrLabel .text = (unit?.address)!.replacingOccurrences(of: ",", with: ",\n")

        //apple maps button
        let openMapsButton = UIButton(type: .custom)
        openMapsButton.setImage(UIImage(named: "appmaps"), for: .normal)
        
        openMapsButton.setTitle("Open in Maps", for: .normal)
        openMapsButton.addTarget(self, action: #selector(openMaps), for: .touchUpInside)
        openMapsButton.frame = CGRect(x: screenWidth/1.5, y: screenHeight/1.55, width: screenHeight/10, height: screenHeight/10)
        view.addSubview(openMapsButton)
        
        
        //learn more button (to faq)
        
        
        //phone call button
        let callButton = UIButton(type: .custom)
        callButton.setImage(UIImage(named: "call"), for: .normal)
        callButton.setTitle("Call", for: .normal)
        callButton.addTarget(self, action: #selector(makeCall), for: .touchUpInside)
        callButton.frame = CGRect(x: screenWidth/5.75, y: screenHeight/1.15, width: screenHeight/14, height: screenHeight/14)
       
        //survey button
        let sButton = UIButton(type: .custom)
        sButton.setImage(UIImage(named: "survey"), for: .normal)
       sButton.setTitle("Survey Form", for: .normal)
       sButton.addTarget(self, action: #selector(openSurveyForm), for: .touchUpInside)
        sButton.frame = CGRect(x: screenWidth/1.45, y: screenHeight/1.15, width: screenHeight/17, height: screenHeight/14)

        //faq button
        let faqButton = UIButton(type: .custom)
        faqButton.setTitle("FAQ", for: .normal)
        faqButton.setTitleColor(.white, for: .normal)
        let faqColor = UIColor(red: 44.0/255.0, green: 101.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        faqButton.backgroundColor = faqColor
        faqButton.layer.borderWidth = 2.0
        faqButton.layer.borderColor = UIColor.white.cgColor
        faqButton.layer.cornerRadius = 10.0
        faqButton.frame = CGRect(x: screenWidth/2.5, y: screenHeight/2, width: screenHeight/10, height: screenHeight/14)

        
        

        self.view.addSubview(nameLabel)
        self.view.addSubview(hoursLabel)
        self.view.addSubview(backButton)
        self.view.addSubview(avaLabel)
        self.view.addSubview(daysLabel)
        self.view.addSubview(addrLabel)
        self.view.addSubview(callButton)
        self.view.addSubview(sButton)
        self.view.addSubview(faqButton)
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
    
    // Method to dismiss the presented view when the button is tapped
    @objc private func dismissButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
           guard let label = gesture.view as? UILabel else {
               return
           }

           // Copy the label's text to the clipboard
           UIPasteboard.general.string = label.text
       }
   }

func calculateDayOfWeek(year: Int, month: Int, day: Int) -> String? {
    let calendar = Calendar.current
    let components = DateComponents(year: year, month: month, day: day)
    
    guard let date = calendar.date(from: components) else {
        return nil
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    
    let dayOfWeek = dateFormatter.string(from: date)
    
    return dayOfWeek
}


