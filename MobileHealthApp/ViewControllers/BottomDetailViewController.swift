//
//  BottomDetailViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/31/23.
//

import Foundation
import UIKit
import CoreLocation
import SafariServices

class BottomDetailViewController: UIViewController, UIViewControllerTransitioningDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var unit: HealthUnit?
    var userLocation: CLLocationCoordinate2D?
    var formattedDays: [String] = []

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var mapsButton: UIButton!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var proxTitle: UILabel!
    @IBOutlet var proxLabel: UILabel!
    @IBOutlet var surveyButton: UIButton!
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var hoursTitle: UILabel!

    @IBOutlet var daysTitle: UILabel!
    @IBOutlet var Line1: UIImageView!
    @IBOutlet var Line2: UIImageView!
    @IBOutlet var Line3: UIImageView!
    
    @IBOutlet var daysCollectionView: UICollectionView!
    
    weak var delegate: BottomSheetDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
        setUpProximity()
        setUpHours()
        daysTitle.text = "Days available this month:"
        //setUpDays()
        setUpConstraints()
        
        // Initialize your collection view
        daysCollectionView.dataSource = self
        daysCollectionView.delegate = self
        // You can register a nib or use a default cell
        daysCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "dayCell")
        updateFormattedDays()
        
        daysCollectionView.backgroundColor = UIColor(red: 100 / 255.0, green: 39 / 255.0, blue: 81 / 255.0, alpha: 1.0)
        
        let layout = CenterAlignedCollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 80)
        layout.scrollDirection = .horizontal
        daysCollectionView.collectionViewLayout = layout
        
        updateFormattedDays()
        centerCollectionItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        daysCollectionView.collectionViewLayout.invalidateLayout()
    }

    // unwraps name safely
    func setUpTitle() {
        if let name = unit?.name {
                nameLabel.text = name
        }
    }

    // If user location not available/wifi is bad, sets value to user location, otherwise, sets distance text
    func setUpProximity() {
        var proxText = "User Location not found"
        proxTitle.text = ""
        if var proxVal = unit?.prox {
            proxVal = round(proxVal * 100) / 100.0
            print("The unit is this far away: \(proxVal)")
            if proxVal != -1.0 {
                proxTitle.text = "Distance:"
                proxText = "\(proxVal) miles"
            }
        }
        proxLabel.text = proxText
    }
    // converts hours from army time to regular AM/PM
    func setUpHours() {
        if let open = unit?.open {
            if var close = unit?.close {
                if var firstHour = Int(close.prefix(2)) {
                    if firstHour > 12 {
                        firstHour-=12
                        close = "\(firstHour):\(close.suffix(2))"
                    }
                }
                hoursTitle.text = "Walk-In Hours:"
                hoursLabel.text = unit?.formattedHours
            }
        }
    }

//    func setUpDays() {
//        var daysTxt = ""
//        // Changes month from 08/  to 8/ for formatting reasons
//        if let days = unit?.days, let monthYear = unit?.MonthYear {
//            print("This is the first letter of the month \(monthYear.suffix(1))")
//            var monthString = monthYear.suffix(2)
//            let monthNum = Int(monthString) ?? -1
//
//            if monthNum == -1 || monthNum < 10 {
//                monthString = monthYear.suffix(1)
//            }
//            // iterates through days, adding each one to the top
//            let dayCount = days.count-1
//            for (index, day) in days.enumerated() {
//                if index == dayCount {
//                    daysTxt += "\(monthString)/\(day ?? 0)"
//                } else if index % 4 == 0 && index != 0 {
//                    daysTxt += "\(monthString)/\(day ?? 0),\n"
//                } else {
//                    daysTxt += "\(monthString)/\(day ?? 0),  "
//                }
//            }
//        }
//        daysTitle.text = "Days available this month:"
//        daysLabel.text = daysTxt
//    }
    
    // New function to update the formattedDays array
    func updateFormattedDays() {
        formattedDays = []  // Clear existing items
        if let days = unit?.days, let monthYear = unit?.MonthYear {
            print("Days Array: \(days)") // Debug: Print out the days array
            print("Month Year: \(monthYear)") // Debug: Print out the month and year

            for day in days {
                if let day = day {
                    let dateStr = "\(monthYear)-\(day)"
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM/dd" 
                    
                    if let date = dateFormatter.date(from: dateStr) {
                        dateFormatter.dateFormat = "MMMM d"
                        let formattedDateStr = dateFormatter.string(from: date)
                        formattedDays.append(formattedDateStr)
                    } else {
                        print("Date formatting failed for \(dateStr)") // Debug: Print if date formatting fails
                    }
                }
            }
            
            print("Formatted Days: \(formattedDays)")  // Debug: Print out the formatted days
        } else {
            print("Either days or monthYear is nil")  // Debug: Print this if either of them is nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of Items: \(formattedDays.count)") // Debug: Print the number of items
        //return formattedDays.count
        return formattedDays.isEmpty ? 1 : formattedDays.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath)
        
        //cell.layoutIfNeeded()
        
        // Set background color and border for cell
        cell.contentView.backgroundColor = UIColor(red: 255 / 255.0, green: 212 / 255.0, blue: 238 / 255.0, alpha: 1.0) // Or any other color
        cell.contentView.layer.borderWidth = 1.0
        //cell.contentView.layer.borderColor = UIColor.black.cgColor // Or any other color
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.clipsToBounds = true
        
//        cell.setNeedsLayout()
//        cell.layoutIfNeeded()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height))
        
        label.numberOfLines = 2 // Allow multiple lines
        label.textAlignment = .center
        
        if formattedDays.isEmpty {
            label.text = "No available days"
        } else {
            let textArray = formattedDays[indexPath.row].split(separator: " ")
            if textArray.count == 2 {
                let month = String(textArray[0])
                let day = String(textArray[1])
                
                let monthAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16)
                ]
                let dayAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 24)
                ]
                
                let attributedText = NSMutableAttributedString(string: month, attributes: monthAttributes)
                attributedText.append(NSAttributedString(string: "\n"))
                attributedText.append(NSAttributedString(string: day, attributes: dayAttributes))
                
                label.attributedText = attributedText
            } else {
                label.text = formattedDays[indexPath.row]
            }
        }
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        cell.contentView.addSubview(label)
        
        return cell
    }
    
    func centerCollectionItems() {
        let cellCount = max(1, formattedDays.count)
        let cellWidth = CGFloat(100)
        let totalCellWidth = cellWidth * CGFloat(cellCount)
        let totalSpacingWidth = CGFloat(cellCount - 1) * 10.0 // replace 10 with your minimum spacing

        var leftInset: CGFloat = 0.0
        var rightInset: CGFloat = 0.0

        if cellCount == 1 || cellCount == 2 {
            leftInset = (daysCollectionView.frame.width - totalCellWidth) / 2 - 9.0
            rightInset = leftInset + 9.0
        } else if cellCount == 3 {
            leftInset = (daysCollectionView.frame.width - totalCellWidth - totalSpacingWidth) / 2 - 4.0
            rightInset = leftInset + 4.0
        } else {
            leftInset = 0.0
            rightInset = 0.0
        }
        
        daysCollectionView.contentInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

    func setUpConstraints() {
        // Disable the automatic translation of constraints into Autoresizing Masks
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        mapsButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.translatesAutoresizingMaskIntoConstraints = false
        proxLabel.translatesAutoresizingMaskIntoConstraints = false
        surveyButton.translatesAutoresizingMaskIntoConstraints = false
        hoursLabel.translatesAutoresizingMaskIntoConstraints = false
        daysCollectionView.translatesAutoresizingMaskIntoConstraints = false
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

            // callButton constraints (in the middle)

           // mapsButton constraints
            mapsButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
           mapsButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -8),

           // faqButton constraints
            callButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
           callButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            callButton.widthAnchor.constraint(equalTo: mapsButton.widthAnchor),

            Line1.topAnchor.constraint(equalTo: mapsButton.bottomAnchor, constant: 1),
            Line1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            Line1.heightAnchor.constraint(equalToConstant: 25.0),

            proxTitle.topAnchor.constraint(equalTo: Line1.bottomAnchor, constant: 1),
            proxTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Constraints for proxLabel
            proxLabel.topAnchor.constraint(equalTo: proxTitle.bottomAnchor, constant: 10),
            proxLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor), // middle of screen
            // proxLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),

            Line2.topAnchor.constraint(equalTo: proxLabel.bottomAnchor, constant: 4),
            Line2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            Line2.heightAnchor.constraint(equalToConstant: 25.0),

            hoursTitle.topAnchor.constraint(equalTo: Line2.bottomAnchor, constant: 1),
            hoursTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Constraints for hoursLabel
            hoursLabel.topAnchor.constraint(equalTo: hoursTitle.bottomAnchor, constant: 10),
            hoursLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor), // middle of screen
            // hoursLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),

            Line3.topAnchor.constraint(equalTo: hoursLabel.bottomAnchor, constant: 4),
            Line3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            Line3.heightAnchor.constraint(equalToConstant: 25.0),

            daysTitle.topAnchor.constraint(equalTo: Line3.bottomAnchor, constant: 1),
            daysTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Constraints for daysLabel
            daysCollectionView.topAnchor.constraint(equalTo: daysTitle.bottomAnchor, constant: 10),
            //daysCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),  // middle of screen
            //daysCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),

            surveyButton.topAnchor.constraint(equalTo: daysCollectionView.bottomAnchor, constant: 18),
            surveyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),  // middle of screen
            surveyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            surveyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])

    }

    @IBAction func openMaps(_ sender: Any) {
        if let address = unit?.address {
            let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let mapURLString = "http://maps.apple.com/?address=\(encodedAddress)"
            guard let mapURL = URL(string: mapURLString) else { return }

            // Open the Apple Maps URL
            //UIApplication.shared.open(mapURL)
            if mapURL != nil {
               let config = SFSafariViewController.Configuration()
               config.entersReaderIfAvailable = true

               let svc = SFSafariViewController(url: mapURL, configuration: config)
                self.present(svc, animated: true) {

                    var frame = svc.view.frame
                    let OffsetY: CGFloat = 42

                    frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y + OffsetY)
                    frame.size = CGSize(width: frame.size.width, height: frame.size.height + OffsetY)
                    svc.view.frame = frame
                }
           }
        } else {
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
        
        if let url = URL(string: "https://forms.gle/QYRetAh1XRHutMqp9") {
           let config = SFSafariViewController.Configuration()
           config.entersReaderIfAvailable = true

           let svc = SFSafariViewController(url: url, configuration: config)
            self.present(svc, animated: true) {

                var frame = svc.view.frame
                let OffsetY: CGFloat = 42

                frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y + OffsetY)
                frame.size = CGSize(width: frame.size.width, height: frame.size.height + OffsetY)
                svc.view.frame = frame
            }
       }
        /*let surveyURLString = "https://forms.gle/QYRetAh1XRHutMqp9"
        guard let surveyURL = URL(string: surveyURLString) else { return }

        // Open the Apple Maps URL
        UIApplication.shared.open(surveyURL)*/
    }

    // Method to dismiss the presented view when the button is tapped
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
