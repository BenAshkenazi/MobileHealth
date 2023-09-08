//
//  DatabaseService.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/27/23.
//
import Foundation
import Firebase

class DatabaseService {
    var healthUnits: [HealthUnit]?
    
    init() {
        fetchDatabase { _ in
            // self.healthUnits = healthUnits
        }
    }
    
    private func fetchDatabase(completion: @escaping ([HealthUnit]) -> Void) {
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
                return
            }
            
            var units: [HealthUnit] = []
            // Gets data from Firebase and inits a mobile health unit class
            var newUnits: [NewHealthUnit] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any] {
                    let unit = HealthUnit(
                        rawId: dict["id"] as? String ?? "",
                        rawMY: dict["Month and Year"] as? String ?? "",
                        name: dict["MHU Name"] as? String ?? "",
                        rawnumber: dict["Phone Number"] as? String ?? "",
                        rawopen: dict["Opening"] as? String ?? "",
                        rawclose: dict["Closing"] as? String ?? "",
                        rawdays: dict["Days of the Month Open"] as? String ?? "",
                        rawaddr: dict["Address"] as? String ?? "",
                        comments: dict["Comments"] as? String ?? ""
                    )
                    units.append(unit)
                    let newUnit = NewHealthUnit(
                        rawId: dict["id"] as? String ?? "",
                        rawMY: dict["Month and Year"] as? String ?? "",
                        name: dict["MHU Name"] as? String ?? "",
                        rawnumber: dict["Phone Number"] as? String ?? "",
                        rawopen: dict["Opening"] as? String ?? "",
                        rawclose: dict["Closing"] as? String ?? "",
                        rawdays: dict["Days of the Month Open"] as? String ?? "",
                        rawaddr: dict["Address"] as? String ?? "",
                        comments: dict["Comments"] as? String ?? ""
                    )
                    newUnits.append(newUnit)
                    
                }
            }
            
            healthUnits = units
            completion(units)
        }
    }
    
    //    func getUnfilteredList()->[HealthUnit]{
    //        print("healthunit.count \(healthUnits.count)")
    //        return healthUnits
    //    }
    
    func fetchHealthUnits(completion: @escaping ([HealthUnit]) -> Void) {
        if let healthUnits = healthUnits {
            completion(healthUnits)
        } else {
            fetchDatabase { healthUnits in
                completion(healthUnits)
            }
        }
    }
    
}
