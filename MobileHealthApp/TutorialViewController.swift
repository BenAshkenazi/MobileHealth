//
//  TutorialViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/13/23.
//

import Foundation
import UIKit

class TutorialViewController: UIViewController {
   
    @IBOutlet var PageTitle: UILabel!
    @IBOutlet var CentralImage: UIImageView!
    @IBOutlet var LeftButton: UIButton!
    @IBOutlet var PageText: UILabel!
    @IBOutlet var RightButton: UIButton!
    
    var pageNumber = 0
    let titleArray = ["What is a Mobile Health Unit?","Searching for a Unit", "Once You've Found a Unit"]
    let imageArray = ["mobileunit", "SearchScreen", "UnitScreen"]
    let pageTextArray = [
        "Health Units are mobile clinics that provide a variety of primary, preventive and behavioral medical services. They operate on a walk-in basis, so no appointment is needed. However, reading the FAQ or calling ahead to check services provided, wait times, and potential cost is advised. To find the number of a mobile health unit, click on its pin on the map. ",
     "To search for a unit, click on the date, time and range buttons to adjust the settings for the search, and then hit search. If a unit is open at the specified time, it will display as a red pin icon, and if it closed, it will display as a grey pin icon. Click on a unit to learn more.",
     "Once you've clicked on a unit, a page will pop up displaying information about the unit, including its hours, and the days of the month it will be available. You can find the unit's location on Apple Maps with the maps  button, call the unit with the call button, or read the FAQ."]
    override func viewDidLoad() {
        super.viewDidLoad()
        PageTitle.text = titleArray[pageNumber]
        CentralImage.image = UIImage(named: "mobileunit")
        PageText.text = pageTextArray[pageNumber]

    }
    
    @IBAction func pressedLeft(_ sender: Any) {
        setNewPage(left: true)
    }
    
    @IBAction func pressedRight(_ sender: Any) {
        setNewPage(left: false)
    }
    
    func setNewPage(left: Bool){
        if(left && pageNumber <= 0){
            return
        }else if(!left && pageNumber >= 2){
            return
        }else{
            
            if(left){
                pageNumber -= 1
            }else{
                pageNumber += 1
            }
           
            if(pageNumber == 0){
                LeftButton.setImage(UIImage(systemName: "arrowshape.left"), for: .normal)
                RightButton.setImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
            }else if(pageNumber == 1){
                LeftButton.setImage(UIImage(systemName: "arrowshape.left.fill"), for: .normal)
                RightButton.setImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
            }else{
                LeftButton.setImage(UIImage(systemName: "arrowshape.left.fill"), for: .normal)
                RightButton.setImage(UIImage(systemName: "arrowshape.right"), for: .normal)
            }
            
            PageTitle.text = titleArray[pageNumber]
            CentralImage.image = UIImage(named: imageArray[pageNumber])
            PageText.text = pageTextArray[pageNumber]
            
        }
    }
    
}
