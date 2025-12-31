//
//  VerifyandContinueViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/26/25.
//

import UIKit
import FirebaseAuth

class VerifyandContinueViewController: UIViewController {

    var email: String!
    @IBOutlet weak var VACbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func verifyButtonTapped(_ sender: UIButton) {
            if Auth.auth().currentUser?.isEmailVerified == true {
                // Proceed to the next screen
                performSegue(withIdentifier: "GoToSettingUpAccount", sender: nil)
            } else {
                showAlert(message: "Please verify your email before proceeding.")
            }
        }

        func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    


