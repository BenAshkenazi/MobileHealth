//
//  AppDelegate.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 6/25/23.
//


import UIKit
import Firebase
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init(){
        FirebaseApp.configure()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let bottomSheetContentViewController = storyboard.instantiateViewController(withIdentifier: "BottomSheetContentViewController") as! BottomSheetContentViewController

        // Set the delegate
        bottomSheetContentViewController.delegate = viewController
        
        window = UIWindow()
        window?.rootViewController = ContainerViewController(
            contentViewController: viewController,
            bottomSheetViewController: bottomSheetContentViewController,
            bottomSheetConfiguration: .init(
                height: UIScreen.main.bounds.height * 0.8,
                initialOffset: 200 + window!.safeAreaInsets.bottom
            )
        )
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
