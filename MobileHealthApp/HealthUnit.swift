//
//  HealthUnit.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/8/23.
//

import Foundation
import MapKit
import CoreLocation

class HealthUnit {
    var id: Int?
    //iso 8601
    var MonthYear: String?
    var name: String?
    var partner: String?
    var number: URL?
    
    //iso 8601
    var open: String?
    //iso 8601
    var close: String?
    
    var rawMY: String?
    var rawopen: String?
    var rawclose: String?
    var rawdays: String?
    
    var days: [Int?]
    
    var address: String?
    
    var comments: String?
    
    init(rawId: String, rawMY: String, name: String, rawpartner: String,rawnumber: String, rawopen: String, rawclose: String, rawdays: String, rawaddr: String, comments: String?) {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        //sets id, 0 if there was an error
        self.id = Int(rawId) ?? 0
        
        //sets month/year
        self.rawMY = rawMY
        self.MonthYear = String(rawMY.prefix(7))
        
        //sets name
        self.name = name
        
        self.partner = rawpartner
        //sets phone number
        //var num = rawnumber.replacingOccurrences(of: ")(- ", with: "", options: NSString.CompareOptions.literal, range: nil)
        self.number = URL(string: "tel://" + String(rawnumber)) ?? URL(string: "tel://" + "0000000000")
                    
        //gets opening hours
        self.rawopen = convertToArizonaTime(from: rawopen)
        self.rawclose = convertToArizonaTime(from: rawclose)
        
  
        self.open = String(String(String(self.rawopen!).prefix(16)).suffix(5))
        self.close = String(String(String(self.rawclose!).prefix(16)).suffix(5))
        
        
        //gets days
        var nospace = rawdays.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)

        if(nospace.count<3){
            var dayArray = [nospace.prefix(2)]
            self.rawdays = rawdays
            self.days = convertStringsToInts(array: dayArray)
        }else{
            var dayArray = nospace.split(separator: ",")
            self.rawdays = rawdays
            self.days = convertStringsToInts(array: dayArray)
        }
        
        print(self.days)
        
        //gets address
        self.address = rawaddr
        
        self.comments = comments ?? "None"
    }
    
    func toString()->String{
        let dateFormatter = DateFormatter()
        return "\(name ?? "lol"): \(MonthYear ?? "4/23")\n Days Open: \(rawdays!)\n\(address!)\n\(number!)"
    }
    
    func isComplete()->Bool{
        if(id==0){
            return false
        }
        if(name == ""){
            return false
        }
        if(rawdays == ""){
            return false
        }
        if (rawopen == ""){
            return false
        }
        if(number == nil){
            return false
        }
        if(address == nil){
            return false
        }
        return true
    }
    
    func location(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!) { (placemarks, error) in
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                print("Failed to get location for address: \(self.address)")
                completion(nil)
                return
            }
            print("Got location for address: \(self.address)")
            completion(coordinate)
        }
    }
    
    func isOpen(on date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)
        
        print("Checking if \(name) is open on day \(day) at hour \(hour)")
                
        if !days.contains(day) || hour < timeToInt(timeString: open!) || hour > timeToInt(timeString: close!) {
            return false
        }
                
        return true
    }
    
    func timeToInt(timeString: String)-> Int{
        let components = timeString.split(separator: ":")
        if components.count == 2, let hour = Int(components[0]) {
            print("The number is: \(hour)")
            return hour
        } else {
            print("Invalid time format")
            return 0
        }
    }
}

func convertStringsToInts(array: [String.SubSequence]) -> [Int?] {
    let convertedArray = array.compactMap { Int($0) }
    return convertedArray
}

func convertToArizonaTime(from iso8601String: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    guard let date = dateFormatter.date(from: iso8601String) else {
        return nil
    }
    
    let arizonaTimeZone = TimeZone(identifier: "America/Phoenix")
    dateFormatter.timeZone = arizonaTimeZone
    
    let arizonaDate = dateFormatter.string(from: date)
    
    return arizonaDate
}
