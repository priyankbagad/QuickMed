//
//  ViewController.swift
//  QuickMed
//
//  Created by Priyank Bagad on 7/10/25.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Wait 2 seconds, then navigate to Home
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.goToHomeScreen()
        }
    }
    
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
        }
    }
}


