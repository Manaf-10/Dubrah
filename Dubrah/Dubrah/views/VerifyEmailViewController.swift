//
//  VerifyEmailViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/25/25.
//

import UIKit
import FirebaseAuth

class VerifyEmailViewController: UIViewController, UITextFieldDelegate {

    
    
    @IBOutlet weak var verifybtn: UIButton!
    
    var sentVerificationCode: String = "1234"
    
        var enteredCode: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        verifybtn.layer.cornerRadius = 12
        verifybtn.clipsToBounds = true
        
    }

    
    @IBAction func alreadyVerifiedTapped(_ sender: UIButton) {
            // Check if the email is verified
            if let user = Auth.auth().currentUser, user.isEmailVerified {
                // If email is verified, navigate to the Password Reset page
                self.performSegue(withIdentifier: "CreateNewPassword", sender: self)
              
            } else {
                // Show error if the email is not verified
                showAlert(message: "Your email is not verified yet. Please check your email for the verification link.")
            }
        }

        func showAlert(message: String) {
            let alert = UIAlertController(title: "Email Verification", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    

