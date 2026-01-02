import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    // UI Elements
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Action for Log Out
    @IBAction func logOutTapped(_ sender: UIButton) {
        showConfirmationAlert(actionType: .logOut)
    }
    
    // Action for Delete Account
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        showConfirmationAlert(actionType: .deleteAccount)
    }
    
    // Show confirmation alert
    func showConfirmationAlert(actionType: ActionType) {
        let alert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to proceed?", preferredStyle: .alert)
        
        // Add "Yes" action
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            if actionType == .logOut {
                self.logOutUser()
            } else if actionType == .deleteAccount {
                self.deleteUserAccount()
            }
        }))
        
        // Add "Cancel" action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Handle Log Out action
    func logOutUser() {
        do {
            try Auth.auth().signOut()
            // After logging out, navigate to login screen
            self.navigateToLoginScreen()
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // Handle Delete Account action
    func deleteUserAccount() {
        let user = Auth.auth().currentUser
        
        // Ensure the user is logged in
        guard let userEmail = user?.email else {
            print("No user email found")
            return
        }
        
        // Prompt the user for their password
        let alert = UIAlertController(title: "Reauthenticate", message: "Please enter your password to confirm account deletion.", preferredStyle: .alert)
        
        // Add a password field
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        // Add "Cancel" and "Submit" actions
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            if let password = alert.textFields?.first?.text {
                // Reauthenticate with the provided password
                self.reauthenticateAndDeleteAccount(userEmail: userEmail, password: password)
            }
        }))
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // Reauthenticate the user and delete the account
    func reauthenticateAndDeleteAccount(userEmail: String, password: String) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: password)
        
        user?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                print("Reauthentication failed: \(error.localizedDescription)")
                self.showErrorAlert(message: "Reauthentication failed. Please check your credentials.")
                return
            }
            
            // Proceed with account deletion after successful reauthentication
            user?.delete(completion: { (error) in
                if let error = error {
                    print("Error deleting account: \(error.localizedDescription)")
                    self.showErrorAlert(message: "Error deleting account. Please try again.")
                } else {
                    print("Account successfully deleted.")
                    self.navigateToLoginScreen()
                }
            })
        })
    }
    
    // Show an error alert
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Navigate to the login screen
    func navigateToLoginScreen() {
        // Instantiate the navigation controller from the storyboard
        let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        
        // Instantiate the login view controller
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        
        // Push the login view controller onto the navigation stack
        navigationController.pushViewController(loginViewController, animated: true)
        
        // Present the navigation controller
        self.present(navigationController, animated: true, completion: nil)
    }
}

// Enum to differentiate between Log Out and Delete Account actions
enum ActionType {
    case logOut
    case deleteAccount
}
