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
}
