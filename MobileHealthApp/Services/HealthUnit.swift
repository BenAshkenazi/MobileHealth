//
//  HealthUnit.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/8/23.
//
//
//  HealthUnit.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/8/23.
//
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
    //Default proximity, updated the first time it is checked for range
    var prox = -1.0
    
    var availableDay: Int?
    //var distanceInMiles: Double
    var distanceToUser: CLLocationDistance?
    
    init(rawId: String, rawMY: String, name: String, rawnumber: String, rawopen: String, rawclose: String, rawdays: String, rawaddr: String, comments: String?) {
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        //sets id, 0 if there was an error
        self.id = Int(rawId) ?? 0
        
        //sets month/year
        self.rawMY = rawMY
        self.MonthYear = String(rawMY.prefix(7))
        
        //sets name
        self.name = name
        

        //sets phone number
        //var num = rawnumber.replacingOccurrences(of: ")(- ", with: "", options: NSString.CompareOptions.literal, range: nil)
        self.number = URL(string: "tel://" + String(rawnumber)) ?? URL(string: "tel://" + "0000000000")
                
        
        //gets opening hours
        self.rawopen = convertToArizonaTime(from: rawopen)
        self.rawclose = convertToArizonaTime(from: rawclose)
        
        //Strips just the hours from the entire iso8601 date string
        if(self.rawopen != nil && self.rawclose != nil){
            self.open = String(String(String(self.rawopen!).prefix(16)).suffix(5))
            self.close = String(String(String(self.rawclose!).prefix(16)).suffix(5))
        }else{
            self.open = ""
            self.close = ""
        }
       
        
        
        //gets days

        if(rawdays.count<3){
            let dayArray = [Int(rawdays)]
            //If rawdays is 2 or fewer chars, it goes through this code
            self.rawdays = rawdays
            self.days = dayArray
        }else{
            let nospace = rawdays.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
            let dayArray = nospace.split(separator: ",")
            self.rawdays = rawdays
            self.days = convertStringsToInts(array: dayArray)
        }
        
        
        //gets address
        self.address = rawaddr
        
        self.comments = comments ?? "None"
    }
    
    func toString()->String{
        _ = DateFormatter()
        return "\(name ?? "lol"): \(MonthYear ?? "4/23")\n Days Open: \(rawdays!)\n\(address!)\n\(number!)"
    }
    
    //This function is currently unused, may be needed for more thorough data checking, but i think thats unlikely
//    func isComplete()->Bool{
//        if(id==0){
//            return false
//        }
//        if(name == ""){
//            return false
//        }
//        if(rawdays == ""){
//            return false
//        }
//        if (rawopen == ""){
//            return false
//        }
//        if(number == nil){
//            return false
//        }
//        if(address == nil || address == ""){
//            return false
//        }
//        return true
//    }
    
    func isComplete() -> Bool {
//        if id == nil || id == 0 {
//            return false
//        }
        if name?.isEmpty ?? true { // If name is nil or empty, return false
            return false
        }
        if rawdays?.isEmpty ?? true {
            return false
        }
        if rawopen?.isEmpty ?? true {
            return false
        }
        if number == nil {
            return false
        }
        if address == nil || address!.isEmpty {
            return false
        }
        return true
    }
    
    //returns location as a coordinate from a string
    func location(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!) { (placemarks, error) in
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                print("Failed to get location for address: \(String(describing: self.address))")
                completion(nil)
                return
            }
            print("Got location for address: \(String(describing: self.address))")
            completion(coordinate)
        }
    }
    
    //checks days and hours, maybe this could handle month year too? might consider adding
    func isOpen(on date: Date) -> Bool {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        
        print("Checking if \(String(describing: name)) is open on day \(day) at hour \(hour)")
                
        if !days.contains(day) || hour < timeToInt(timeString: open!) || hour > timeToInt(timeString: close!) {
            return false
        }
                
        return true
    }
    
    //updates proximity value after checking if the address is valid, then returns whether or not it satisfies the range requiement
    func isWithin(range: Double, userLoc: CLLocationCoordinate2D, address: String, completion: @escaping (Bool) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                print("Failed to get location for address: \(address)")
                self.prox = -1.0
                completion(false)
                return
            }

            print("Got location for address: \(address)")

            let dis = distanceInMiles(from: userLoc, to: coordinate)
            self.prox = dis
            if dis > range && range != 0 {
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    
    func timeToInt(timeString: String)-> Int{
        let components = timeString.split(separator: ":")
        if components.count == 2, let hour = Int(components[0]) {
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

func distanceInMiles(from sourceCoordinate: CLLocationCoordinate2D, to destinationCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
    let sourceLocation = CLLocation(latitude: sourceCoordinate.latitude, longitude: sourceCoordinate.longitude)
    let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
    
    // Calculate distance in meters
    let distanceInMeters = sourceLocation.distance(from: destinationLocation)
    
    // Convert distance from meters to miles
    let distanceInMiles = distanceInMeters * 0.000621371
    
    return distanceInMiles
}

extension HealthUnit {

    var formattedHours: String {
        var openTag = "AM"
        var endTag = "AM"
        guard var open = self.open else {
            return "N/A"
        }
        
        guard var close = self.close else {
            return "\(open) AM"
        }
        
        if var closedHour = Int(close.prefix(2)) {
            if closedHour > 12 {
                closedHour -= 12
                close = "\(closedHour):\(close.suffix(2))"
                endTag = "PM"
            }
        }
        
        if var firstHour = Int(open.prefix(2)) {
            if firstHour > 12 {
                firstHour -= 12
                print("First hour was called \(firstHour)")
                open = "\(firstHour):\(open.suffix(2))"
                openTag = "PM"
            }
        }
        
        return "\(open) \(openTag) - \(close) \(endTag)"
    }

    var formattedDays: String {
        guard let monthYear = self.MonthYear else {
            return "N/A"
        }
        let days = self.days

        var daysTxt = ""
        var monthString = monthYear.suffix(2)
        let monthNum = Int(monthString) ?? -1
        
        if monthNum == -1 || monthNum < 10 {
            monthString = monthYear.suffix(1)
        }

        let dayCount = days.count - 1
        for (index, day) in days.enumerated() {
            if index == dayCount {
                daysTxt += "\(monthString)/\(day ?? 0)"
            } else if(index % 4 == 0 && index != 0) {
                daysTxt += "\(monthString)/\(day ?? 0),\n"
            } else {
                daysTxt += "\(monthString)/\(day ?? 0),  "
            }
        }
        return daysTxt
    }
    
    func getDayName(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        if let date = dateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let dayOfWeek = calendar.component(.weekday, from: date)
            return dateFormatter.weekdaySymbols[dayOfWeek - 1]
        }
        return nil
    }
    
    var formattedDaysName: String {
        guard let monthYear = self.MonthYear else {
            return "N/A"
        }
        let days = self.days

        var daysTxt = ""
        var monthString = monthYear.suffix(2)
        let monthNum = Int(monthString) ?? -1
        
        if monthNum == -1 || monthNum < 10 {
            monthString = monthYear.suffix(1)
        }
        
        let calendar = Calendar.current

        var uniqueDays = Set<String>() // To keep track of unique days
        
        for day in days {
            if let dayInt = day {
                let dateString = "\(monthNum)/\(dayInt)/\(calendar.component(.year, from: Date()))"
                
                if let dayName = getDayName(from: dateString), !uniqueDays.contains(dayName) {
                    uniqueDays.insert(dayName)
                    
                    if !daysTxt.isEmpty {
                        daysTxt += ", "
                    }
                    
                    daysTxt += dayName
                }
            }
        }
        
        return daysTxt
    }

    var daysAsIntegers: [Int] {
        return self.days.compactMap { $0 }
    }
    
//    func calculateDistanceFromUserLocation(userLoc: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
//        guard !address!.isEmpty else {
//            print("Address is empty.")
//            self.distanceToUser = nil
//            completion(false)
//            return
//        }
//
//        geocodeAddress(address: address!) { coordinate, error in
//            if let coordinate = coordinate {
//                let distance = distanceInMiles(from: userLoc, to: coordinate)
//                self.distanceToUser = distance
//                completion(true)
//            } else {
//                print("Failed to get location for address: \(self.address)")
//                self.distanceToUser = nil
//                completion(false)
//            }
//        }
//    }

    func calculateDistanceFromUserLocation(userLoc: CLLocationCoordinate2D, completion: @escaping (Bool) -> Void) {
        guard !address!.isEmpty else {
            print("Address is empty.")
            self.prox = -1.0 // Set a default value to indicate failure
            completion(false)
            return
        }
        
        geocodeAddress(address: address!) { coordinate, error in
            if let coordinate = coordinate {
                let distance = distanceInMiles(from: userLoc, to: coordinate)
                self.prox = distance // Store the calculated distance in the prox variable
                completion(true)
            } else {
                print("Failed to get location for address: \(self.address)")
                self.prox = -1.0 // Set a default value to indicate failure
                completion(false)
            }
        }
    }


    private func geocodeAddress(address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                completion(nil, error)
                return
            }

            guard let coordinate = placemarks?.first?.location?.coordinate else {
                print("Failed to get location for address: \(address)")
                completion(nil, nil)
                return
            }

            completion(coordinate, nil)
        }
    }
}

//extension HealthUnit {
//    func distanceFromUserLocation(userLoc: CLLocationCoordinate2D) -> CLLocationDistance? {
//        guard let coordinate = geocodeAddressSync(address: rawAddress)?.location?.coordinate else {
//            print("Failed to get location for address: \(rawAddress)")
//            return nil
//        }
//
//        return distanceInMiles(from: userLoc, to: coordinate)
//    }
//}
