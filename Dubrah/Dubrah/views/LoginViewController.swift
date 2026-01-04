import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextFeild: UITextField!
    @IBOutlet weak var SigninBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextFeild.delegate = self
        SigninBtn.layer.cornerRadius = 12.0
        SigninBtn.clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let email = emailTextFeild.text, !email.isEmpty else {
             showAlert(message: "Please enter your email.")
             return
         }
         
         guard let password = passwordTextField.text, !password.isEmpty else {
             showAlert(message: "Please enter your password.")
             return
         }
         
         print("Attempting to sign in with email: \(email)")
         
         Task {
             do {
                 try await AuthManager.shared.signIn(email: email, password: password)
                 
                 if let user = Auth.auth().currentUser {
                     print("✅ User authenticated: \(user.email ?? "No email")")
                     checkUserRole(userId: user.uid)
                 } else {
                     print("❌ Authentication failed or no user found.")
                     showAlert(message: "Authentication failed. Please check your credentials.")
                 }
                 
             } catch let error as NSError {
                 switch error.code {
                 case AuthErrorCode.invalidEmail.rawValue:
                     self.showAlert(message: "The email address is invalid.")
                 case AuthErrorCode.wrongPassword.rawValue:
                     self.showAlert(message: "The password is incorrect.")
                 case AuthErrorCode.userNotFound.rawValue:
                     self.showAlert(message: "No account found with this email.")
                 default:
                     self.showAlert(message: "Sign In failed: \(error.localizedDescription)")
                 }
             }
         }
     }

     func checkUserRole(userId: String) {
         let db = Firestore.firestore()
         db.collection("user").document(userId).getDocument { [weak self] document, error in
             if let error = error {
                 print("❌ Error fetching user role: \(error.localizedDescription)")
                 self?.showAlert(message: "Error fetching user role. Please try again later.")
                 return
             }
             
             guard let document = document, document.exists else {
                 print("❌ No user document found in Firestore for UID: \(userId)")
                 self?.showAlert(message: "No account found with this email.")
                 return
             }
             
             if let role = document.data()?["role"] as? String {
                 print("✅ User role: \(role)")
                 
                 DispatchQueue.main.async {
                     if role.lowercased() == "admin" {
                         print("🔵 Navigating to Admin Dashboard")
                         self?.navigateToAdminDashboard()
                     } else {
                         print("🟢 Navigating to User Dashboard")
                         self?.navigateToUserDashboard()
                     }
                 }
             } else {
                 print("⚠️ User role not found in document")
                 self?.showAlert(message: "User role not found or is invalid.")
             }
         }
     }
     
     private func navigateToAdminDashboard() {
         let storyboard = UIStoryboard(name: "TabBarController", bundle: nil)
         let adminTabBar = storyboard.instantiateViewController(withIdentifier: "AdminTabBarController") as! AdminTabBarController
         
         if let window = view.window {
             window.rootViewController = adminTabBar
             UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
         }
     }

     private func navigateToUserDashboard() {
         let storyboard = UIStoryboard(name: "User", bundle: nil)
         let userTabBar = storyboard.instantiateViewController(withIdentifier: "CustomerTabBarVC")
         
         if let window = view.window {
             window.rootViewController = userTabBar
             UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
         }
     }

     func showAlert(message: String) {
         let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default))
         present(alert, animated: true)
     }
 }
