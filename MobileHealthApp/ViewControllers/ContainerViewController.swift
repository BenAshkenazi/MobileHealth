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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contentViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! MainViewController
        contentViewController.databaseService = databaseService
        
        let bottomSheetViewController = storyboard.instantiateViewController(withIdentifier: "BottomSheetContentViewController") as! BottomSheetContentViewController
        bottomSheetViewController.databaseService = databaseService
        // Set the delegate
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
