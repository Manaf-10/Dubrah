import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
   
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        showConfirmationAlert(actionType: .logOut)
    }
    
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        showConfirmationAlert(actionType: .deleteAccount)
    }
    
 
    func showConfirmationAlert(actionType: ActionType) {
        let alert = UIAlertController(title: "Confirm Action", message: "Are you sure you want to proceed?", preferredStyle: .alert)
        
    
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            if actionType == .logOut {
                self.logOutUser()
            } else if actionType == .deleteAccount {
                self.deleteUserAccount()
            }
        }))
        
     
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
   
        self.present(alert, animated: true, completion: nil)
    }
    
 
    func logOutUser() {
        do {
            try Auth.auth().signOut()
           
            self.navigateToLoginScreen()
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    

    func deleteUserAccount() {
        let user = Auth.auth().currentUser
    
        guard let userEmail = user?.email else {
            print("No user email found")
            return
        }
        
    
        let alert = UIAlertController(title: "Reauthenticate", message: "Please enter your password to confirm account deletion.", preferredStyle: .alert)
        
     
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            if let password = alert.textFields?.first?.text {
       
                self.reauthenticateAndDeleteAccount(userEmail: userEmail, password: password)
            }
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func reauthenticateAndDeleteAccount(userEmail: String, password: String) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: userEmail, password: password)
        
        user?.reauthenticate(with: credential, completion: { (result, error) in
            if let error = error {
                print("Reauthentication failed: \(error.localizedDescription)")
                self.showErrorAlert(message: "Reauthentication failed. Please check your credentials.")
                return
            }
            
           
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
    
   
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func navigateToLoginScreen() {
        self.performSegue(withIdentifier: "GoToLogInPage", sender: nil)
    }
}


enum ActionType {
    case logOut
    case deleteAccount
}
