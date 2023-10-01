//
//  TutorialViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/13/23.
//

import Foundation
import UIKit

enum TutorialDirection {
    case right, left
}

protocol TutorialDelegate: AnyObject {
    func didFinishUnwindSegue()
}

class TutorialViewController: UIViewController {
    

    @IBOutlet var TutorialImage: UIImageView!
    @IBOutlet var TutorialScrollView: UIScrollView!
    @IBOutlet var LeftButton: UIButton!
    @IBOutlet var RightButton: UIButton!
    
    weak var delegate: TutorialDelegate?
    
    var logoPurple = UIColor(red: 0x6D / 255.0, green: 0x1D / 255.0, blue: 0x6A / 255.0, alpha: 1.0)
    var logoTan = UIColor(red: 0xFC / 255.0, green: 0xF6 / 255.0, blue: 0xF1 / 255.0, alpha: 1.0)
    var pageNumber = 0
   // let titleArray = ["What is a Mobile Health Unit?", "Searching for a Unit", "Once You've Found a Unit"]
    let imageArray = ["tutorial1", "tutorial2", "tutorial3", "tutorial4", "tutorial5", "tutorial6", "tutorial7", "tutorial8"]
    /*let pageTextArray = [
        "Health Units are mobile clinics that provide a variety of primary, preventive and behavioral medical services. They operate on a walk-in basis, so no appointment is needed. However, reading the FAQ or calling ahead to check services provided, wait times, and potential cost is advised. To find the number of a mobile health unit, click on its pin on the map. ",
        "To search for a unit, click on the date, time and range buttons to adjust the settings for the search, and then hit search. If a unit is open at the specified time, it will display as a red pin icon, and if it closed, it will display as a grey pin icon. Click on a unit to learn more.",
        "Once you've clicked on a unit, a page will pop up displaying information about the unit, including its hours, and the days of the month it will be available. You can find the unit's location on Apple Maps with the maps  button, call the unit with the call button, or read the FAQ."]*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = logoPurple
        //PageTitle.text = titleArray[pageNumber]
        //TutorialImage.image = UIImage(named: "tutorial1")
        //PageText.text = pageTextArray[pageNumber]
        configureSwipe()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserDefaults.standard.set(true, forKey: defaultKey)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didFinishUnwindSegue()
    }
    @IBAction func pressedLeft(_ sender: Any) {
        setNewPage(direction: .left)
    }
    
    @IBAction func pressedRight(_ sender: Any) {
        if(pageNumber == 7){
            self.dismiss(animated: true, completion: nil)
        }
        setNewPage(direction: .right)
    }
    
    
    func setNewPage(direction: TutorialDirection){//Page(left: Bool) {
        switch direction {
        case .left:
            guard pageNumber > 0 else { return }
            pageNumber -= 1
        case .right:
            
            guard pageNumber < (imageArray.count - 1) else { return }
            pageNumber += 1
        }
        
        switch pageNumber {
        case 0, 1:
            self.view.backgroundColor = logoPurple
        case (imageArray.count - 1):
            self.view.backgroundColor = logoTan
        default:
            self.view.backgroundColor = .white
        }
        
        if pageNumber == 0 {
            LeftButton.setImage(UIImage(systemName: "arrowshape.left"), for: .normal)
            RightButton.setImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
        } else if pageNumber == (imageArray.count - 1) {
            LeftButton.setImage(UIImage(systemName: "arrowshape.left.fill"), for: .normal)
            RightButton.setImage(UIImage(systemName: "arrowshape.right"), for: .normal)
        } else {
            LeftButton.setImage(UIImage(systemName: "arrowshape.left.fill"), for: .normal)
            RightButton.setImage(UIImage(systemName: "arrowshape.right.fill"), for: .normal)
        }
        
        
        //PageTitle.text = titleArray[pageNumber]
        TutorialImage.image = UIImage(named: imageArray[pageNumber])
        //PageText.text = pageTextArray[pageNumber]
    }
    
    
    
    
}
// this is for the swipe gesture recognition
extension TutorialViewController {
    
    func configureSwipe() {
        
        let swipeGestureRecognizerR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureRecognizerR.direction = .right// or .left, .up, .down
        view.addGestureRecognizer(swipeGestureRecognizerR)
        
        let swipeGestureRecognizerL = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureRecognizerL.direction = .left
        view.addGestureRecognizer(swipeGestureRecognizerL)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            setNewPage(direction: .left)
        } else if gesture.direction == .left {
            setNewPage(direction: .right)
        } else if gesture.direction == .up {
            // Handle up swipe
        } else if gesture.direction == .down {
            // Handle down swipe
        }
    }
    
}
