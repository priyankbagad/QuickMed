//
//  HomeViewController.swift
//  QuickMed
//
//  Created by Priyank Bagad on 7/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var addMedicineButton: UIButton!
    
    @IBOutlet weak var viewMedicineButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addMedicineTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addMedVC = storyboard.instantiateViewController(withIdentifier: "AddMedicineViewController") as? AddMedicineViewController {
            self.navigationController?.pushViewController(addMedVC, animated: true)
        }
    }
    @IBAction func viewMedicinesTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewMedVC = storyboard.instantiateViewController(withIdentifier: "ViewMedicinesViewController") as? ViewMedicinesViewController {
            self.navigationController?.pushViewController(viewMedVC, animated: true)
        }
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
