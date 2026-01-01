//
//  CreateNewPassViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/25/25.
//

import UIKit
import FirebaseAuth

class CreateNewPassViewController: UIViewController {

    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var saveNewPassbtn: UIButton!
    
    @IBOutlet weak var label8Characters: UILabel!
        @IBOutlet weak var labelUppercase: UILabel!
        @IBOutlet weak var labelLowercase: UILabel!
        @IBOutlet weak var labelNumber: UILabel!
        @IBOutlet weak var labelSpecialChar: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        saveNewPassbtn.layer.cornerRadius = 12
        saveNewPassbtn.clipsToBounds = true
        newPasswordTextField.addTarget(self, action: #selector(validatePassword), for: .editingChanged)
    }
    
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
}
    
    @IBAction func saveNewPasswordTapped(_ sender: UIButton) {
            guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
                showAlert(message: "Please enter a new password.")
                return
            }

            guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
                showAlert(message: "Please confirm your new password.")
                return
            }

            // Check if passwords match
            if newPassword != confirmPassword {
                showAlert(message: "Passwords do not match. Please try again.")
                return
            }

            // Validate password strength
            if !isValidPassword(newPassword) {
                showAlert(message: "Password must be at least 8 characters long, contain at least one uppercase letter, one lowercase letter, one number, and one special character.")
                return
            }

            // Proceed with password reset in Firebase
            resetPassword(newPassword: newPassword)
        }

        // Validate password strength
        func isValidPassword(_ password: String) -> Bool {
            return password.count >= 8 &&
                password.rangeOfCharacter(from: .uppercaseLetters) != nil &&
                password.rangeOfCharacter(from: .lowercaseLetters) != nil &&
                password.rangeOfCharacter(from: .decimalDigits) != nil &&
                password.rangeOfCharacter(from: CharacterSet(charactersIn: "#@%*")) != nil
        }

        // Validate and update label colors based on password conditions
        @objc func validatePassword() {
            guard let password = newPasswordTextField.text else { return }

            // Validate the length (at least 8 characters)
            label8Characters.textColor = password.count >= 8 ? .green : .red
            
            // Validate if it contains at least one uppercase letter
            labelUppercase.textColor = password.rangeOfCharacter(from: .uppercaseLetters) != nil ? .green : .red
            
            // Validate if it contains at least one lowercase letter
            labelLowercase.textColor = password.rangeOfCharacter(from: .lowercaseLetters) != nil ? .green : .red
            
            // Validate if it contains at least one number
            labelNumber.textColor = password.rangeOfCharacter(from: .decimalDigits) != nil ? .green : .red
            
            // Validate if it contains at least one special character
            labelSpecialChar.textColor = password.rangeOfCharacter(from: CharacterSet(charactersIn: "#@%*")) != nil ? .green : .red
        }

        // Reset Password in Firebase Authentication
        func resetPassword(newPassword: String) {
            // Reset the password for the current user
            Auth.auth().currentUser?.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert(message: "Error resetting password: \(error.localizedDescription)")
                } else {
                    self.showAlert(message: "Your password has been successfully reset!")
                    // After successful password reset, navigate to final page
                    self.performSegue(withIdentifier: "ResetSuccessfullyViewController", sender: self)
                }
            }
        }

        // Show alert messages
        func showAlert(message: String) {
            let alert = UIAlertController(title: "Password Reset", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
   
