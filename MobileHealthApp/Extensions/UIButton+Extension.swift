//
//  UIButton+Extension.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 9/7/23.
//

import UIKit

extension UIButton {
    func customizeButton(){
        self.layer.cornerRadius = self.bounds.height / 4
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
        
    }
    
    func setButtonSize40(){
        self.layer.bounds.size.width = 40
        self.layer.bounds.size.height = 40
    }
    
    func setCustomButtonSize(){
        self.customizeButton()
        self.setButtonSize40()
    }
}
