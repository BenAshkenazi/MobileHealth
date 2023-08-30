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
        let databaseService = DatabaseService()
        let locationService = LocationService()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! MainViewController
        contentViewController.databaseService = databaseService
        contentViewController.locationService = locationService
        
        let bottomSheetViewController = storyboard.instantiateViewController(withIdentifier: "BottomSheetContentViewController") as! BottomSheetContentViewController
        bottomSheetViewController.databaseService = databaseService
        bottomSheetViewController.locationService = locationService
        bottomSheetViewController.delegate = contentViewController
        
        super.init(
        contentViewController: contentViewController,
        bottomSheetViewController: bottomSheetViewController,
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
