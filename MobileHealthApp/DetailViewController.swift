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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var centralImageView: UIImageView!
    @IBOutlet var daysLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var mapsButton: UIButton!
    @IBOutlet var faqButton: UIButton!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var sButton: UIButton!
    @IBOutlet var backButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //Set label of MHU
        nameLabel.text = unit?.name
        
        centralImageView.layer.cornerRadius = centralImageView.bounds.width / 8.0
        // Adjust the value to control the roundness
        centralImageView.clipsToBounds = true
        centralImageView.layer.borderWidth = 3.0 // Adjust the border width as needed
        centralImageView.layer.borderColor = UIColor.black.cgColor
        
        //Displays hours
        if let open = unit?.open{
            if let close = unit?.close{
                
                hoursLabel.text = "Opening Hours: \(open)-\(close)"
            }
        }
        
        //displays days open
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
        
        //Displays address
        if let addr = unit?.address{
            addressLabel.text = "Address:\n" + addr.replacingOccurrences(of: ", ", with: ",\n")
        }
        
        setupConstraints()

        updateButtonSizeAndFont()
        setUpMapsButton()
        
       
    }
    
   
    
    @IBAction func showFAQPage(_ sender: Any){
        print("FAQ button tapped")
        let fAQsViewController = storyboard!.instantiateViewController(withIdentifier: "FAQsViewController") as? FAQsViewController
        fAQsViewController!.modalPresentationStyle = .custom
        fAQsViewController!.transitioningDelegate = self
        present(fAQsViewController!, animated: true, completion: nil)
            
        
    }
    
    @objc func sendEmail() {
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
    
    @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
           guard let label = gesture.view as? UILabel else {
               return
           }

           // Copy the label's text to the clipboard
           UIPasteboard.general.string = label.text
       }
    
    func setupConstraints() {
            // Disable autoresizing mask for all views
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            hoursLabel.translatesAutoresizingMaskIntoConstraints = false
            centralImageView.translatesAutoresizingMaskIntoConstraints = false
            daysLabel.translatesAutoresizingMaskIntoConstraints = false
            addressLabel.translatesAutoresizingMaskIntoConstraints = false
            mapsButton.translatesAutoresizingMaskIntoConstraints = false
            faqButton.translatesAutoresizingMaskIntoConstraints = false
            callButton.translatesAutoresizingMaskIntoConstraints = false
            sButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.translatesAutoresizingMaskIntoConstraints = false

            // Limit the width of centralImageView to 90% of the screen's width
            let maxWidthConstraint = centralImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.65)
            maxWidthConstraint.priority = .required // Set required priority to avoid conflicts
            maxWidthConstraint.isActive = true

            // Aspect ratio constraint to maintain the image's aspect ratio
            let aspectRatioConstraint = centralImageView.widthAnchor.constraint(equalTo: centralImageView.heightAnchor, multiplier: 4032.0/3024.0)
            aspectRatioConstraint.priority = .required // Set required priority to avoid conflicts
            aspectRatioConstraint.isActive = true
        
        
        // Create the constraints
                NSLayoutConstraint.activate([
                    
                    // Back Button (top-left corner)
                    backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                    backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    
                    // Name Label (center-top)
                    nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

                    // Central Image View (centered below name label)

                    centralImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    centralImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 15),

                    // Days Label (centered below hours label)
                    daysLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    daysLabel.topAnchor.constraint(equalTo: centralImageView.bottomAnchor, constant: 10),
                    
                    // Hours Label (centered below image view)
                    hoursLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    hoursLabel.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 10),

                    

                    // Address Label (centered below FAQ button)
                    addressLabel.topAnchor.constraint(equalTo: hoursLabel.bottomAnchor, constant: 30),
                    addressLabel.leadingAnchor.constraint(equalTo: mapsButton.trailingAnchor, constant: 10),

                    // Maps Button (left-aligned with Address Label)
                    mapsButton.topAnchor.constraint(equalTo: hoursLabel.bottomAnchor, constant: 30),
                    mapsButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -5),
                    
                    // FAQ Button (centered below hours label)
                    faqButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    faqButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 30),
                    
                    // Call Button (bottom-left corner)
                    callButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    callButton.topAnchor.constraint(equalTo: faqButton.bottomAnchor, constant: 20),

                    // S Button (bottom-right corner)
                    sButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    sButton.topAnchor.constraint(equalTo: callButton.bottomAnchor, constant: 20),

                    
                ])
            }
    
        func fontSizeForButton() -> CGFloat {
            // Calculate the font size based on the screen's width and height
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let referenceWidth: CGFloat = 375.0 // Reference width for font scaling

            let scaleFactor = min(screenWidth / referenceWidth, screenHeight / referenceWidth)
            let fontSize = scaleFactor * 17.0 // Adjust the base font size (17.0) as needed

            return fontSize
        }

        func updateButtonSizeAndFont() {
            let fontSize = fontSizeForButton()
           
            backButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize/1.75)
            
            let buttons = [faqButton, callButton, sButton]
            for button in buttons{
                if let b = button{
                    // Set button rounded shape
                    b.layer.cornerRadius = 8.0
                    b.layer.borderWidth = 1.5
                    b.layer.masksToBounds = true
                    b.layer.borderColor = UIColor.black.cgColor
                    b.layer.opacity = 0.95
                    
                    // Calculate the font size based on the screen's width and height
                    

                    // Update the font size of the button title
                    b.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)

                    // Update the button size
                    let buttonWidth = b.intrinsicContentSize.width
                    let buttonHeight = b.intrinsicContentSize.height
                    b.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
                    b.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
                }
                
            }
            
        }
        func setUpMapsButton(){
            mapsButton.setImage(UIImage(named: "appmaps"), for: .normal)
            mapsButton.imageView?.contentMode = .scaleAspectFit

            let buttonSize = addressLabel.intrinsicContentSize.height

            // Apply the calculated button size
            mapsButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
            mapsButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        }
   }




/*
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
let attributedString = NSAttributedString(string: nameLabel.text ?? "",
                                                 attributes: [
                                                   NSAttributedString.Key.strokeColor: UIColor.white,
                                                   NSAttributedString.Key.strokeWidth: -0.25
                                                 ])
nameLabel.attributedText = attributedString

let image = UIImage(named: "mobileunit")
let imageView = UIImageView(image: image)



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
hoursLabel .text = "Opening Hours: \(String(describing: (unit?.open)!)) - \(String(describing: (unit?.close)!))"

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
for day in (unit?.days)! {
    if first {
        daysTxt = daysTxt + "\((unit?.MonthYear)!.suffix(2))/\(day!) "
        first = false
    } else {
        daysTxt = daysTxt + ", \((unit?.MonthYear)!.suffix(2))/\(day!) "
    }
}

let daysCount = CGFloat((unit?.days)!.count)

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
self.view.addSubview(faqButton)*/
