//
//  DetailPresentationController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 7/31/23.
//
/*
import Foundation
import UIKit

class DetailPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }
        let height = containerView.bounds.height / 2
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func presentationTransitionWillBegin() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        containerView?.addGestureRecognizer(tapGesture)
    }

    @objc func didTapContainerView() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
*/
