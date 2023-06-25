//
//  ViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 6/25/23.
//

import UIKit
import Firebase


class ReminderViewController: UIViewController {
   

    @IBOutlet var refreshButton: UIButton!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    
    var unitArray: [HealthUnit] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let rootRef = Database.database().reference().child("1tccGgPzxsOegrepl329GJkQOYnGcWu2XhLYcgiB_iNE").child("Sheet1")
        rootRef.observeSingleEvent(of: .value) { [weak self] snapshot, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if !snapshot.exists() {
                print("No data found.")
                //print(dict["id"] as? String)
                return
            }
            
            var units: [HealthUnit] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any] {
                    let newUnit = HealthUnit(
                        rawId: dict["id"] as? String ?? "",
                        rawMY: dict["Month and Year"] as? String ?? "",
                        name: dict["MHU Name"] as? String ?? "",
                        rawnumber: dict["Phone Number"] as? String ?? "",
                        rawopen: dict["Opening"] as? String ?? "",
                        rawclose: dict["Closing"] as? String ?? "",
                        rawdays: dict["Days Open"] as? String ?? "",
                        rawaddr: dict["Address"] as? String ?? "",
                        comments: dict["Comments"] as? String ?? ""
                    )
                    units.append(newUnit)
                }
            }
            
            unitArray = units
            label1.text = unitArray[0].toString()
            label2.text = unitArray[1].toString()
            if(unitArray.count>2){
                label3.text = unitArray[2].toString()
            }
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //array[1][1][1]
    }
    
    
    @IBAction func showMHUDEtail(_ sender: Any) {
        let viewControllerB = DetailViewController()
        viewControllerB.unit = unitArray[1]
        navigationController?.pushViewController(viewControllerB, animated: false)
    }
    
    
   
}
    
