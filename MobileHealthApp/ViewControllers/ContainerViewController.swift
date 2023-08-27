//
//  WelcomeContainerViewController.swift
//  MobileHealthApp
//
//  Created by Fawwaz Firdaus on 7/15/23.
//

import Foundation
import UIKit

final class ContainerViewController: BottomSheetContainerViewController
<MainViewController, BottomSheetContentViewController> {
    
    public init?(){
        //super.init(coder: NSCoder())
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! MainViewController
        let bottomSheetContentViewController = storyboard.instantiateViewController(withIdentifier: "BottomSheetContentViewController") as! BottomSheetContentViewController
        // Set the delegate
        bottomSheetContentViewController.delegate = viewController
        
        super.init(
        contentViewController: viewController,
        bottomSheetViewController: bottomSheetContentViewController,
        bottomSheetConfiguration: .init(
            height: UIScreen.main.bounds.height * 0.8,
            initialOffset: 265 //+ window!.safeAreaInsets.bottom
        ))
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do something
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
