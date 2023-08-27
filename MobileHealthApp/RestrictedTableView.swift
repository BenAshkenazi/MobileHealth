//
//  RestrictedTableView.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/27/23.
//

import UIKit

class RestrictedUITableView: UITableView, UIGestureRecognizerDelegate {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupGestureRecognizers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: nil)
        gestureRecognizer.delegate = self
        addGestureRecognizer(gestureRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous recognition only if the other gesture is from a subview of this table view
        return otherGestureRecognizer.view?.isDescendant(of: self) == true
    }
}
