//
//  DetailViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/13/23.
//

import Foundation
import UIKit

class DetailViewController: UIViewController, UIViewControllerTransitioningDelegate {
    var unit: HealthUnit?

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.view.backgroundColor = UIColor(red:241.0/255.0, green:242.0/255.0, blue:242.0/255.0, alpha: 1.0)


        let nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth/1.1, height: 50))
        nameLabel.font = UIFont.boldSystemFont(ofSize: screenHeight/25)
        nameLabel.numberOfLines = 0
        nameLabel .textColor = .black
        nameLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/5.5)
        nameLabel .textAlignment = .center
        nameLabel .text = unit?.name
        let attributedString = NSAttributedString(string: nameLabel.text ?? "",
                                                         attributes: [
                                                           NSAttributedString.Key.strokeColor: UIColor.white,
                                                           NSAttributedString.Key.strokeWidth: -0.25
                                                         ])
        nameLabel.attributedText = attributedString
        
        let image = UIImage(named: "mobileunit")
        let imageView = UIImageView(image: image)

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3.5
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = 15

        // Calculate the position and size to center the imageView
        let imageViewWidth: CGFloat = view.bounds.width / 2.0
        let imageViewHeight: CGFloat = (imageViewWidth * 3.0) / 4.0
        let imageViewX = (view.bounds.width - imageViewWidth) / 2.0
        let imageViewY = (view.bounds.height - imageViewHeight) / 3.0

        imageView.frame = CGRect(x: imageViewX, y: imageViewY, width: imageViewWidth, height: imageViewHeight)
        view.addSubview(imageView)

        
        let backButton = UIButton(type: .custom)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.setImage(UIImage(systemName: "arrowshape.turn.up.backward.fill"), for: .normal)
        backButton.tintColor = .black
        backButton.frame = CGRect(x: screenWidth/12, y: screenHeight/12, width: screenHeight/10, height: screenHeight/14)
        backButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        
        let hoursLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth/1.25, height: 40))
        hoursLabel.font =  UIFont.boldSystemFont(ofSize: screenHeight/40)
        hoursLabel.numberOfLines = 0
        hoursLabel .textColor = .black
        hoursLabel .center = CGPoint(x: screenWidth/2.0, y: screenHeight/4.5)
        hoursLabel .textAlignment = .center
        hoursLabel .text = "Opening Hours: \(String(describing: (unit?.open))) - \(String(describing: (unit?.close)))"
        
        // Days Available Label
        let avaLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth / 1.15, height: 50))
        avaLabel.font = UIFont.boldSystemFont(ofSize: screenHeight / 40)
        avaLabel.numberOfLines = 0
        avaLabel.textColor = .black
        avaLabel.center = CGPoint(x: screenWidth / 2.0, y: screenHeight / 1.85)
        avaLabel.textAlignment = .center
        avaLabel.text = "Days Available This Month:"
        view.addSubview(avaLabel)

        // Days Open Label
        let daysLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenHeight / 4, height: screenHeight / 4))
        daysLabel.numberOfLines = 0
        daysLabel.textColor = .black
        daysLabel.center = CGPoint(x: screenWidth / 2.0, y: screenHeight / 1.7)

        var daysTxt = ""
        var first = true
        
        guard let days = unit?.days else {return}
        for day in days {
            if let month = unit?.MonthYear {
                if first {
                    daysTxt = daysTxt + "\(month.suffix(2))/\(String(describing: day)) "
                    first = false
                } else {
                    daysTxt = daysTxt + ", \(month.suffix(2))/\(String(describing: day)) "
                }
            }
        }

       
        let daysCount = CGFloat(days.count)

        if daysTxt.count < 5 {
            daysLabel.font = UIFont.boldSystemFont(ofSize: screenHeight / (22.5 * daysCount))
        } else if daysTxt.count < 15 {
            daysLabel.font = UIFont.boldSystemFont(ofSize: screenHeight / (21.5 * daysCount))
        } else if daysTxt.count < 20 {
            daysLabel.font = UIFont.boldSystemFont(ofSize: screenHeight / (19.0 * daysCount))
        } else if daysTxt.count < 25 {
            daysLabel.font = UIFont.boldSystemFont(ofSize: screenHeight / (15.0 * daysCount))
        } else {
            daysLabel.font = UIFont.boldSystemFont(ofSize: screenHeight / (8.0 * daysCount))
        }

        daysLabel.text = daysTxt
        view.addSubview(daysLabel)
        
        //Get coordinates of edges of image along the x axis
        let leftImageX = imageViewX*1.35

        // Address Label
        let addrLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        addrLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        addrLabel.numberOfLines = 0
        addrLabel.textColor = .black
        addrLabel.center = CGPoint(x: leftImageX, y: screenHeight / 1.45)
        addrLabel.textAlignment = .left
        addrLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        addrLabel.addGestureRecognizer(tapGesture)
        if let text = unit?.address {
            addrLabel.text = "Address:\n" + text.replacingOccurrences(of: ",", with: ",\n")
        } else {
            addrLabel.text = "error in address"
        }
        view.addSubview(addrLabel)

        // Apple Maps Button
        let openMapsButton = UIButton(type: .custom)
        openMapsButton.setImage(UIImage(named: "appmaps"), for: .normal)
        openMapsButton.setTitle("Open in Maps", for: .normal)
        openMapsButton.addTarget(self, action: #selector(openMaps), for: .touchUpInside)

        // Adjust the frame for the button
        let buttonWidth: CGFloat = screenHeight / 10
        openMapsButton.frame = CGRect(x: imageViewX*2.5, y: screenHeight / 1.55, width: buttonWidth, height: buttonWidth)
        view.addSubview(openMapsButton)

        //phone call button
        let callButton = UIButton(type: .custom)
        callButton.setImage(UIImage(named: "call"), for: .normal)
        callButton.setTitle("Call", for: .normal)
        callButton.addTarget(self, action: #selector(makeCall), for: .touchUpInside)

        // Calculate the x position to center the button around the first 25% of the screen width
        let callButtonWidth: CGFloat = screenHeight / 14
        let callButtonX = (view.bounds.width / 4.5) - (callButtonWidth / 2)
        let callButtonY: CGFloat = screenHeight / 1.25

        callButton.frame = CGRect(x: callButtonX, y: callButtonY, width: callButtonWidth, height: callButtonWidth)

        view.addSubview(callButton)

        // sButton
        let sButton = UIButton(type: .custom)
        sButton.setImage(UIImage(named: "survey"), for: .normal)
        sButton.setTitle("Survey Form", for: .normal)
        sButton.addTarget(self, action: #selector(openSurveyForm), for: .touchUpInside)

        // Calculate the x position to center the button around the last 75% of the screen width
        let sButtonWidth: CGFloat = screenHeight / 17
        let sButtonX = (3.15 * view.bounds.width / 4) - (sButtonWidth / 2)
        let sButtonY: CGFloat = screenHeight / 1.25

        sButton.frame = CGRect(x: sButtonX, y: sButtonY, width: sButtonWidth, height: sButtonWidth*1.15)

        view.addSubview(sButton)

        //faq button
        let faqButton = UIButton(type: .custom)
        faqButton.addTarget(self, action: #selector(showFAQPage), for: .touchUpInside)
        faqButton.setTitle("Learn More", for: .normal)
        faqButton.setTitleColor(.white, for: .normal)
        let faqColor = UIColor(red: 127.0/255.0, green: 86.0/255.0, blue: 108.0/255.0, alpha: 1.0)
        faqButton.backgroundColor = faqColor
        faqButton.layer.borderWidth = 2.0
        faqButton.layer.borderColor = UIColor.white.cgColor
        faqButton.layer.cornerRadius = 10.0
        // Calculate the position to center the button width-wise
        let faqbuttonWidth: CGFloat = view.bounds.width / 3.5
        let buttonX = (view.bounds.width - faqbuttonWidth) / 2.0
        let buttonY: CGFloat = view.bounds.height / 1.25

        faqButton.frame = CGRect(x: buttonX, y: buttonY, width: faqbuttonWidth, height: faqbuttonWidth / 2.0) // Set the height based on your requirement

        view.addSubview(faqButton)


        
        

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
        let address = unit?.address
        guard let encodedAddress = address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
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
    
    @objc func showFAQPage() {
        print("FAQ button tapped")
        guard let fAQsViewController = storyboard?.instantiateViewController(withIdentifier: "FAQsViewController") as? FAQsViewController else {
            return
        }
        fAQsViewController.modalPresentationStyle = .custom
        fAQsViewController.transitioningDelegate = self
        present(fAQsViewController, animated: true, completion: nil)

    }
    
    @objc func sendEmail() {
        let phoneNumber = unit?.number
        if let phoneURL = phoneNumber, UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func openSurveyForm() {
        let surveyURLString = "https://forms.gle/QYRetAh1XRHutMqp9"
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


