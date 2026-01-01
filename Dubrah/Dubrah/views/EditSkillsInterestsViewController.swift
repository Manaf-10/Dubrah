import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EditSkillsInterestsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // UI Elements
    @IBOutlet weak var skillsTextField: UITextField!
    @IBOutlet weak var interestsTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var userID: String?
    var skills: [String] = []
    var interests: [String] = []
    
    var pickerView: UIPickerView!
    var pickerData: [String] = []
    var selectedSkills: [String] = []
    var selectedInterests: [String] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the user is logged in and fetch their data
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        self.userID = userID
        
        // Prepare the picker view
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        skillsTextField.inputView = pickerView
        interestsTextField.inputView = pickerView
        
        // Fetch data for skills and interests
        fetchPickerData()
        fetchUserData()
    }
    
    // Fetch Skills and Interests Data for Picker (example data, you can modify this)
    func fetchPickerData() {
        // Example data (you can fetch this from Firestore if necessary)
        pickerData = ["Design", "Photography", "Tutoring", "Programming", "Marketing", "Writing"]
    }
    
    // Fetch the user data (Skills and Interests) from Firestore
    func fetchUserData() {
        let userRef = db.collection("user").document(userID!)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                self.interests = data?["interests"] as? [String] ?? []
                self.skills = [] // We will fetch skills from ProviderDetails collection
                
                // Display existing data in the text fields
                self.interestsTextField.text = self.interests.joined(separator: ", ")
            } else {
                print("User document does not exist")
            }
        }
        
        // Fetch Skills Data from 'ProviderDetails' collection
        let providerDetailsRef = db.collection("ProviderDetails").document(userID!)
        
        providerDetailsRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting provider details document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                // Fetch and display skills
                self.skills = data?["skills"] as? [String] ?? []
                
                // Display skills in the text field
                self.skillsTextField.text = self.skills.joined(separator: ", ")
            } else {
                print("Provider details document does not exist")
            }
        }
    }
    
    // MARK: - UIPickerView DataSource and Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column picker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // When the user selects a row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Add selected skill or interest
        let selectedItem = pickerData[row]
        
        // Determine which text field was tapped (skills or interests)
        if skillsTextField.isFirstResponder {
            if !selectedSkills.contains(selectedItem) {
                selectedSkills.append(selectedItem)
            }
            skillsTextField.text = selectedSkills.joined(separator: ", ")
        } else if interestsTextField.isFirstResponder {
            if !selectedInterests.contains(selectedItem) {
                selectedInterests.append(selectedItem)
            }
            interestsTextField.text = selectedInterests.joined(separator: ", ")
        }
    }
    
    // MARK: - Save Button Action
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Check if both skills and interests fields are empty
        if skillsTextField.text?.isEmpty ?? true && interestsTextField.text?.isEmpty ?? true {
            showError(message: "Please enter at least one skill or interest.")
            return
        }
        
        // Validate and update Firestore
        updateUserSkillsAndInterests()
    }
    
    // Show error alert if fields are empty
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Update Skills and Interests in Firestore
    func updateUserSkillsAndInterests() {
        guard let userID = userID else { return }
        
        var updatedSkills = skillsTextField.text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        var updatedInterests = interestsTextField.text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
        // If user is not a provider, do not update skills
        if !isUserProvider() {
            updatedSkills = [] // Skip saving skills if the user is not a provider
        }
        
        // Update skills and interests in the respective collections
        if isUserProvider() {
            // Update skills in 'ProviderDetails' collection
            let providerDetailsRef = db.collection("ProviderDetails").document(userID)
            providerDetailsRef.updateData([
                "skills": updatedSkills
            ]) { error in
                if let error = error {
                    print("Error updating skills: \(error.localizedDescription)")
                } else {
                    print("Skills successfully updated.")
                }
            }
        }
        
        // Update interests in 'users' collection
        let userRef = db.collection("user").document(userID)
        userRef.updateData([
            "interests": updatedInterests
        ]) { error in
            if let error = error {
                print("Error updating interests: \(error.localizedDescription)")
            } else {
                print("Interests successfully updated.")
                self.navigationController?.popViewController(animated: true) // Navigate back after successful save
            }
        }
    }
    
    // Check if user is a provider
    func isUserProvider() -> Bool {
        // Fetch user role from Firestore (this is an example, you need to check if the user is a provider)
        // Assuming you have a 'role' field in your Firestore 'users' document:
        
        let userRef = db.collection("user").document(userID!)
        
        var isProvider = false
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                if let role = data?["role"] as? String, role == "provider" {
                    isProvider = true
                }
            }
        }
        
        return isProvider
    }
}
