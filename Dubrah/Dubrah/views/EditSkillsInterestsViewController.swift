import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EditSkillsInterestsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
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
        
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        self.userID = userID
        
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        skillsTextField.inputView = pickerView
        interestsTextField.inputView = pickerView
        
        
        fetchPickerData()
        fetchUserData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func fetchPickerData() {
        // Example data (you can fetch this from Firestore if necessary)
        pickerData = ["Design", "Photography", "Tutoring", "Programming", "Marketing", "Writing"]
    }
    
    // Fetch the user data (Skills and Interests) from Firestore
    func fetchUserData() {
        guard let userID = userID else { return }
        
        // Fetch Interests Data from 'user' collection
        let userRef = db.collection("user").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                self.interests = data?["interests"] as? [String] ?? []
                
                // Display interests in the text field
                self.interestsTextField.text = self.interests.joined(separator: ", ")
            } else {
                print("User document does not exist")
            }
        }
        
        // Fetch Skills Data from 'ProviderDetails' collection using the userID inside ProviderDetails
        let providerDetailsRef = db.collection("ProviderDetails")
        let query = providerDetailsRef.whereField("userId", isEqualTo: userID)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching provider details: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                // Get the first document since userId is unique in this case
                let document = snapshot.documents[0]
                let data = document.data()
                
                // Fetch and display skills
                self.skills = data["skills"] as? [String] ?? []
                
                // Display skills in the text field
                self.skillsTextField.text = self.skills.joined(separator: ", ")
            } else {
                print("Provider details document not found for userId: \(userID)")
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
            print("Selected Skills: \(selectedSkills)") // Debugging: Print skills selection
        } else if interestsTextField.isFirstResponder {
            if !selectedInterests.contains(selectedItem) {
                selectedInterests.append(selectedItem)
            }
            interestsTextField.text = selectedInterests.joined(separator: ", ")
            print("Selected Interests: \(selectedInterests)") // Debugging: Print interests selection
        }
    }
    
    // MARK: - Save Button Action
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        // Check if both skills and interests fields are empty
        if skillsTextField.text?.isEmpty ?? true && interestsTextField.text?.isEmpty ?? true {
            showError(message: "Please enter at least one skill or interest.")
            return
        }
        
        // Debugging: Print values before saving
        print("Skills TextField: \(skillsTextField.text ?? "")")
        print("Interests TextField: \(interestsTextField.text ?? "")")
        
        // Validate and update Firestore
        updateUserSkillsAndInterests()
    }
    
    // Show error alert if fields are empty
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateUserSkillsAndInterests() {
        guard let userID = userID else { return }

        // Prepare skills and interests arrays for Firestore
        var updatedSkills = skillsTextField.text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        var updatedInterests = interestsTextField.text?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
        // Debugging: Print arrays before saving
        print("Updated Skills: \(updatedSkills)")
        print("Updated Interests: \(updatedInterests)")

        // Update skills in 'ProviderDetails' collection
        let providerDetailsRef = db.collection("ProviderDetails")
        let query = providerDetailsRef.whereField("userId", isEqualTo: userID)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            // Check if a document is found
            if let document = snapshot?.documents.first {
                let documentRef = document.reference

                // Update the document with the new data
                let updatedData: [String: Any] = [
                    "skills": updatedSkills
                ]
                
                documentRef.updateData(updatedData) { error in
                    if let error = error {
                        print("Error updating data: \(error.localizedDescription)")
                    } else {
                        print("Skills updated successfully in ProviderDetails.")
                    }
                }
            } else {
                print("No document found for this user.")
            }
        }

        // Update interests in 'users' collection
        let userRef = db.collection("user").document(userID)
        userRef.updateData([ "interests": updatedInterests ]) { error in
            if let error = error {
                print("Error updating interests: \(error.localizedDescription)")
            } else {
                print("Interests successfully updated.")
                self.navigationController?.popViewController(animated: true) // Navigate back after successful save
            }
        }
    }
}
