//
//  WelcomeViewController.swift
//  MobileHealthApp
//
//  Created by Ben Ashkenazi on 8/20/23.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if true{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as? TutorialViewController {
                present(tutorialVC, animated: true, completion: nil)
            }
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
