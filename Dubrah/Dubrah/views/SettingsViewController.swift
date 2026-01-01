import UIKit
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
        
        // Reauthenticate the user first (prompt for password or use stored credentials)
        guard let userEmail = user?.email else {
            print("No user email found")
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: "userPassword") // You may ask user for password input
        
        user?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                print("Reauthentication failed: \(error.localizedDescription)")
                return
            }
            
            // Proceed with account deletion
            user?.delete(completion: { (error) in
                if let error = error {
                    print("Error deleting account: \(error.localizedDescription)")
                } else {
                    print("Account successfully deleted.")
                    self.navigateToLoginScreen()
                }
            })
        })
    }
    
    // Navigate to login screen (after log out or account deletion)
    func navigateToLoginScreen() {
        // You can use a segue or manually instantiate the login screen:
        // Example using a segue:
        self.performSegue(withIdentifier: "showLoginScreen", sender: self)
        
        // Or instantiate the login screen manually
        // let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        // self.present(loginViewController, animated: true, completion: nil)
    }
}

// Enum to differentiate between Log Out and Delete Account actions
enum ActionType {
    case logOut
    case deleteAccount
}
