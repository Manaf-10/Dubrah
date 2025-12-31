//
//  ForgotPasswordViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/5/25.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var SendResetCodebtn: UIButton!
        override func viewDidLoad() {
        super.viewDidLoad()
        
        SendResetCodebtn.layer.cornerRadius = 12
        SendResetCodebtn.clipsToBounds = true
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func sendVerificationLinkTappe(_ sender: UIButton) {
            guard let email = emailTextField.text, !email.isEmpty else {
                showAlert(message: "Please enter your email.")
                return
            }

            // Validate email format
            if !isValidEmail(email) {
                showAlert(message: "Please enter a valid email address.")
                return
            }

            // Send email verification link using Firebase
            sendEmailVerificationLink(email: email)
        }

        // Validate email format
        func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: email)
        }

        // Send email verification link using Firebase
        func sendEmailVerificationLink(email: String) {
            let actionCodeSettings = ActionCodeSettings()

            // Use Firebase Hosting URL for continue URL
            // This URL should match your Firebase Hosting domain (e.g., `yourapp.firebaseapp.com` or `yourapp.web.app`)
            actionCodeSettings.url = URL(string: "https://dubrah-51a8f.web.app/verifyEmail?email=\(email)")  // Replace with your own Firebase Hosting URL
            actionCodeSettings.handleCodeInApp = true // Firebase will handle the verification in the app

            Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
                if let error = error {
                    self.showAlert(message: "Error: \(error.localizedDescription)")
                } else {
                    // After sending the verification email, navigate to the next page
                    self.performSegue(withIdentifier: "VerifyEmailViewController", sender: self)
                }
            }
        }

        // Show alert messages
        func showAlert(message: String) {
            let alert = UIAlertController(title: "Forgot Password", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

