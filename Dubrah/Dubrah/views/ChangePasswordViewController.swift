import UIKit
import Firebase
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var label8Characters: UILabel!
    @IBOutlet weak var labelUppercase: UILabel!
    @IBOutlet weak var labelLowercase: UILabel!
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var labelSpecialChar: UILabel!
    
    
    var currentUser: FirebaseAuth.User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
        
        
        currentUser = Auth.auth().currentUser
        
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
        
        
        newPasswordTextField.addTarget(self, action: #selector(validateNewPassword), for: .editingChanged)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
   
    @IBAction func validateCurrentPassword(_ sender: UITextField) {
        guard let currentPassword = sender.text else { return }
        
        
        let credential = EmailAuthProvider.credential(withEmail: currentUser?.email ?? "", password: currentPassword)
        
        
        currentUser?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                
                self.currentPasswordTextField.layer.borderColor = UIColor.red.cgColor
                self.currentPasswordTextField.layer.borderWidth = 1
            } else {
               
                self.currentPasswordTextField.layer.borderColor = UIColor.green.cgColor
                self.currentPasswordTextField.layer.borderWidth = 1
            }
        })
    }
    
    
    @IBAction func saveNewPassword(_ sender: UIButton) {
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(message: "New password cannot be empty.")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Confirm password cannot be empty.")
            return
        }
        
        
        if newPassword != confirmPassword {
            showAlert(message: "New password and confirmation do not match.")
            return
        }
        
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
    
    
    @objc func validateNewPassword() {
        guard let password = newPasswordTextField.text else { return }
        
        
        let isAtLeast8Characters = password.count >= 8
        let hasUppercaseLetter = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercaseLetter = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        
        
        updateLabel(label: label8Characters, isValid: isAtLeast8Characters)
        updateLabel(label: labelUppercase, isValid: hasUppercaseLetter)
        updateLabel(label: labelLowercase, isValid: hasLowercaseLetter)
        updateLabel(label: labelNumber, isValid: hasNumber)
        updateLabel(label: labelSpecialChar, isValid: hasSpecialChar)
        
        
        saveButton.isEnabled = isAtLeast8Characters && hasUppercaseLetter && hasLowercaseLetter && hasNumber && hasSpecialChar
    }
    
    
    func updateLabel(label: UILabel, isValid: Bool) {
        if isValid {
            label.textColor = .green
        } else {
            label.textColor = .red
        }
    }
    
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Password Change", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
