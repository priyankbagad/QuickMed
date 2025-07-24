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
        
        // Wait for 2 seconds before moving to Home
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.goToHomeScreen()
        }
    }
    
    func goToHomeScreen() {
        // 1. Load Main storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // 2. Instantiate Navigation Controller by its Storyboard ID
        if let navController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController {
            
            // 3. Access app's SceneDelegate to replace the rootViewController
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                
                // 4. Set the Navigation Controller as the root view controller
                sceneDelegate.window?.rootViewController = navController
            }
        }
    }
}



