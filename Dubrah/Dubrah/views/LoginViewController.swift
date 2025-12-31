//
//  LoginViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/5/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
   
    
    @IBOutlet weak var emailTextFeild: UITextField!
    @IBOutlet weak var SigninBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextFeild.delegate = self
         
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        guard let email = emailTextFeild.text, !email.isEmpty else {
                showAlert(message: "Please enter your email.")
                return
            }
            
            guard let password = passwordTextField.text, !password.isEmpty else {
                showAlert(message: "Please enter your password.")
                return
            }
            
            // Try signing in with Firebase
            Task {
                do {
                    // Attempt to sign in with the entered email and password
                    try await AuthManager.shared.signIn(email: email, password: password)
                    // If successful, navigate to the home page
                    
                } catch let error as NSError {
                    // Handle the error based on Firebase Auth errors
                    switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        self.showAlert(message: "The email address is invalid.")
                    case AuthErrorCode.wrongPassword.rawValue:
                        self.showAlert(message: "The password is incorrect.")
                    case AuthErrorCode.userNotFound.rawValue:
                        self.showAlert(message: "No account found with this email.")
                    default:
                        self.showAlert(message: "Sign In failed. Please try again.")
                    }
                }
            }
               
        
    }
    func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

    
}
