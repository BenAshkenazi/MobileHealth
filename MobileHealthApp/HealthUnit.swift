//
//  HealthUnit.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/8/23.
//

import Foundation
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
    
    var rawopen: String?
    var rawclose: String?
    
    var rawdays: String?
    
    var days: [Int?]
    
    var address: String?
    
    var comments: String?
    
    init(rawId: String, rawMY: String, name: String, rawnumber: String, rawopen: String, rawclose: String, rawdays: String, rawaddr: String, comments: String?) {
       
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        //sets id, 0 if there was an error
        self.id = Int(rawId) ?? 0
        
        //sets month/year
        self.MonthYear = String(rawMY.prefix(7))

        //sets name
        self.name = name
        
        //sets phone number
        //var num = rawnumber.replacingOccurrences(of: ")(- ", with: "", options: NSString.CompareOptions.literal, range: nil)
        self.number = URL(string: "tel://" + String(rawnumber)) ?? URL(string: "tel://" + "0000000000")
        print(rawnumber)
        
        //gets opening hours
        self.open = rawopen
        print("Raw Opening Time: \(rawopen)")
        //gets closing hours
        self.close = rawclose
        
        self.rawopen = String(rawopen.prefix(16).suffix(5))
        self.rawclose = String(rawclose.prefix(16).suffix(5))
        
        //self.rawopen = rawopen
        //self.rawclose = rawclose
        
        
       
        //gets days
        var nospace = rawdays.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        var dayArray = nospace.split(separator: " ")
        self.rawdays = rawdays
        self.days = convertStringsToInts(array: dayArray)
        
        //gets address
        self.address = rawaddr
        
        self.comments = comments ?? "None"
    }
    
    func toString()->String{
        let dateFormatter = DateFormatter()
        
        
        return "\(name ?? "lol"): \(MonthYear ?? "4/23")\n Days Open: \(rawdays!)\n\(address!)\n\(number!)"
    }
}

func convertStringsToInts(array: [String.SubSequence]) -> [Int?] {
    let convertedArray = array.compactMap { Int($0) }
    return convertedArray
}

