//
//  UserInfoCompleteViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/25/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UserInfoCompleteViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var ContinueSettingUpbtn: UIButton!
    
    @IBOutlet weak var label8Characters: UILabel!
    @IBOutlet weak var labelUppercase: UILabel!
    @IBOutlet weak var labelLowercase: UILabel!
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var labelSpecialChar: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ContinueSettingUpbtn.layer.cornerRadius = 12
        ContinueSettingUpbtn.clipsToBounds = true
        
        // Add listeners to validate password as user types
                passwordTextField.addTarget(self, action: #selector(validatePassword), for: .editingChanged)
        
    }
    @objc func validatePassword() {
           guard let password = passwordTextField.text else { return }
           
           // Check each password condition
           let is8Characters = password.count >= 8
           let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
           let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
           let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
           let hasSpecialChar = password.rangeOfCharacter(from: CharacterSet.punctuationCharacters) != nil
           
           // Update the label colors based on the conditions
           updateLabelColor(label: label8Characters, isValid: is8Characters)
           updateLabelColor(label: labelUppercase, isValid: hasUppercase)
           updateLabelColor(label: labelLowercase, isValid: hasLowercase)
           updateLabelColor(label: labelNumber, isValid: hasNumber)
           updateLabelColor(label: labelSpecialChar, isValid: hasSpecialChar)
       }
       
       // Helper function to update label color
       func updateLabelColor(label: UILabel, isValid: Bool) {
           if isValid {
               label.textColor = .green
           } else {
               label.textColor = .red
           }
       }
       
       @IBAction func continueButtonTapped(_ sender: UIButton) {
           // Validate phone number and password
           guard let phone = phoneNumberTextField.text, !phone.isEmpty else {
               showAlert(message: "Phone number cannot be empty")
               return
           }
           
           guard let password = passwordTextField.text, password.count >= 8,
                 password == confirmPasswordTextField.text else {
               showAlert(message: "Password must be at least 8 characters and match.")
               return
           }
           
           // Proceed with saving user data
           saveUserData(phone: phone, password: password)
       }
       
       func saveUserData(phone: String, password: String) {
           let user = Auth.auth().currentUser
           
           // Update the user's password in Firebase Authentication
           user?.updatePassword(to: password) { error in
               if let error = error {
                   self.showAlert(message: "Failed to update password: \(error.localizedDescription)")
                   return
               }
               
               // Store the phone number in Firestore (no verification required)
               let userRef = Firestore.firestore().collection("user").document(user!.uid)
               userRef.updateData([
                   "phone": phone // Store the phone number
               ]) { error in
                   if let error = error {
                       self.showAlert(message: "Failed to save phone number: \(error.localizedDescription)")
                       return
                   }
                   
                   // Proceed to the next page
                   self.performSegue(withIdentifier: "GoToTellUsMore", sender: nil)
               }
           }
       }
       
       func showAlert(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
   }

    

