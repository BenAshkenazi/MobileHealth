//
//  NewHealthUnit.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 9/7/23.
//

import Foundation

struct NewHealthUnit {
    let id: Int
    let rawMY: String
    let name: String
    var MonthYear: String? //iso 8601
    var number: URL?
    var open: String? // iso 8601
    var close: String? // iso 8601
    var rawopen: String?
    var rawclose: String?
    var rawdays: String?
    var days: [Int?]
    var address: String?
    var comments: String?
    var prox = -1.0 // Default proximity, updated the first time it is checked for range
    var availableDay: Int?
    
    init(rawId: String, rawMY: String, name: String, rawnumber: String, rawopen: String, rawclose: String, rawdays: String, rawaddr: String, comments: String?) {

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        // sets id, 0 if there was an error
        id = Int(rawId) ?? 0
        self.rawMY = rawMY
        self.name = name
        
        self.MonthYear = String(rawMY.prefix(7))
        
        number = URL(string: "tel://" + String(rawnumber)) ?? URL(string: "tel://" + "0000000000")
        // gets opening hours
        self.rawopen = rawopen.convertToArizonaTime()
        self.rawclose = rawclose.convertToArizonaTime()
        // Strips just the hours from the entire iso8601 date string
        if self.rawopen != nil && self.rawclose != nil {
            self.open = String(String(String(self.rawopen!).prefix(16)).suffix(5))
            self.close = String(String(String(self.rawclose!).prefix(16)).suffix(5))
        } else {
            self.open = ""
            self.close = ""
        }
        // gets days
        if rawdays.count<3 {
            let dayArray = [Int(rawdays)]
            // If rawdays is 2 or fewer chars, it goes through this code
            self.rawdays = rawdays
            self.days = dayArray
        } else {
            let nospace = rawdays.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
            let dayArray = nospace.split(separator: ",")
            self.rawdays = rawdays
            self.days = convertStringsToInts(array: dayArray)
        }
        // gets address
        self.address = rawaddr
        self.comments = comments ?? "None"
    }

}
