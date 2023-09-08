//
//  String+Extension.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/24/23.
//

import Foundation
extension String {
    var localized: String {
          NSLocalizedString(self, tableName: "Localizable",
                            bundle: Bundle.main,
                                    value: self,
                                    comment: "")
   }
    
    func convertToArizonaTime() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        guard let date = dateFormatter.date(from: self) else {
            return nil
        }

        let arizonaTimeZone = TimeZone(identifier: "America/Phoenix")
        dateFormatter.timeZone = arizonaTimeZone

        let arizonaDate = dateFormatter.string(from: date)

        return arizonaDate
    }
}
