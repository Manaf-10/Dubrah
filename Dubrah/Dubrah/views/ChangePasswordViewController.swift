import UIKit
import Firebase
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    // UI Elements
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var label8Characters: UILabel!
    @IBOutlet weak var labelUppercase: UILabel!
    @IBOutlet weak var labelLowercase: UILabel!
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var labelSpecialChar: UILabel!
    
    // Firebase Auth user
    var currentUser: FirebaseAuth.User? // Use FirebaseAuth.User, not Dubrah.User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get current authenticated user from Firebase Authentication
        currentUser = Auth.auth().currentUser
        
        // Add observer to validate password while typing
        newPasswordTextField.addTarget(self, action: #selector(validateNewPassword), for: .editingChanged)
    }
    
    // Action to validate the current password
    @IBAction func validateCurrentPassword(_ sender: UITextField) {
        guard let currentPassword = sender.text else { return }
        
        // Re-authenticate the user with their current password
        let credential = EmailAuthProvider.credential(withEmail: currentUser?.email ?? "", password: currentPassword)
        
        // Re-authenticate using Firebase Authentication's currentUser
        currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                // If re-authentication fails, mark text field red
                self.currentPasswordTextField.layer.borderColor = UIColor.red.cgColor
                self.currentPasswordTextField.layer.borderWidth = 1
            } else {
                // If re-authentication succeeds, mark text field green
                self.currentPasswordTextField.layer.borderColor = UIColor.green.cgColor
                self.currentPasswordTextField.layer.borderWidth = 1
            }
        })
    }
    
    // Action when the user taps the Save New Password button
    @IBAction func saveNewPassword(_ sender: UIButton) {
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(message: "New password cannot be empty.")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Confirm password cannot be empty.")
            return
        }
        
        // Check if the new password and confirmation match
        if newPassword != confirmPassword {
            showAlert(message: "New password and confirmation do not match.")
            return
        }
        
        // Proceed with updating the password
        if let currentUser = currentUser {
            currentUser.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert(message: "Error updating password: \(error.localizedDescription)")
                } else {
                    self.performSegue(withIdentifier: "PasswordChanged", sender: nil )
                }
            }
        }
    }
    
    // Function to validate the new password based on criteria
    @objc func validateNewPassword() {
        guard let password = newPasswordTextField.text else { return }
        
        // Validate the conditions
        let isAtLeast8Characters = password.count >= 8
        let hasUppercaseLetter = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercaseLetter = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        
        // Update labels based on password conditions
        updateLabel(label: label8Characters, isValid: isAtLeast8Characters)
        updateLabel(label: labelUppercase, isValid: hasUppercaseLetter)
        updateLabel(label: labelLowercase, isValid: hasLowercaseLetter)
        updateLabel(label: labelNumber, isValid: hasNumber)
        updateLabel(label: labelSpecialChar, isValid: hasSpecialChar)
        
        // Enable/Disable Save button based on all conditions
        saveButton.isEnabled = isAtLeast8Characters && hasUppercaseLetter && hasLowercaseLetter && hasNumber && hasSpecialChar
    }
    
    // Function to update label color based on validation result
    func updateLabel(label: UILabel, isValid: Bool) {
        if isValid {
            label.textColor = .green
        } else {
            label.textColor = .red
        }
    }
    
    // Function to show an alert with a given message
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Password Change", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
