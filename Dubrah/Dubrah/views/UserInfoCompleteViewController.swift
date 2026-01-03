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
        
        
        ContinueSettingUpbtn.isEnabled = false
        
        
        passwordTextField.addTarget(self, action: #selector(validatePassword), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(validatePassword), for: .editingChanged)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func validatePassword() {
        guard let password = passwordTextField.text else { return }
        
        
        let is8Characters = password.count >= 8
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecialChar = password.rangeOfCharacter(from: CharacterSet.punctuationCharacters) != nil
        
        
        updateLabelColor(label: label8Characters, isValid: is8Characters)
        updateLabelColor(label: labelUppercase, isValid: hasUppercase)
        updateLabelColor(label: labelLowercase, isValid: hasLowercase)
        updateLabelColor(label: labelNumber, isValid: hasNumber)
        updateLabelColor(label: labelSpecialChar, isValid: hasSpecialChar)
        
        
        let isPasswordValid = is8Characters && hasUppercase && hasLowercase && hasNumber && hasSpecialChar
        let isPasswordMatch = password == confirmPasswordTextField.text
        
        ContinueSettingUpbtn.isEnabled = isPasswordValid && isPasswordMatch
    }
    
    
    func updateLabelColor(label: UILabel, isValid: Bool) {
        if isValid {
            label.textColor = .green
        } else {
            label.textColor = .red
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        
        guard let phone = phoneNumberTextField.text, !phone.isEmpty else {
            showAlert(message: "Phone number cannot be empty")
            return
        }
        
        guard let password = passwordTextField.text, password.count >= 8,
              password == confirmPasswordTextField.text else {
            showAlert(message: "Password must be at least 8 characters and match.")
            return
        }
        
        
        saveUserData(phone: phone, password: password)
    }
    
    func saveUserData(phone: String, password: String) {
        let user = Auth.auth().currentUser
        
        
        guard let currentUser = user else {
            showAlert(message: "User is not authenticated")
            return
        }
        
        
        let userRef = Firestore.firestore().collection("user").document(currentUser.uid)
        
        
        userRef.getDocument { (document, error) in
            if let error = error {
                self.showAlert(message: "Failed to fetch user document: \(error.localizedDescription)")
                return
            }
            
            if document?.exists == true {
                
                userRef.updateData([
                    "phone": phone
                ]) { error in
                    if let error = error {
                        self.showAlert(message: "Failed to save phone number: \(error.localizedDescription)")
                        return
                    }
                    
                    
                    currentUser.updatePassword(to: password) { error in
                        if let error = error {
                            self.showAlert(message: "Failed to update password: \(error.localizedDescription)")
                            return
                        }
                        
                       
                        self.performSegue(withIdentifier: "GoToTellUsMore", sender: nil)
                    }
                }
            } else {
                
                userRef.setData([
                    "phone": phone,
                    "email": currentUser.email ?? "",
                    "fullName": "",
                    "role": "seeker"
                ]) { error in
                    if let error = error {
                        self.showAlert(message: "Failed to create user document: \(error.localizedDescription)")
                        return
                    }
                    
                    
                    currentUser.updatePassword(to: password) { error in
                        if let error = error {
                            self.showAlert(message: "Failed to update password: \(error.localizedDescription)")
                            return
                        }
                        
                        // Proceed to the next page
                        self.performSegue(withIdentifier: "GoToTellUsMore", sender: nil)
                    }
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
