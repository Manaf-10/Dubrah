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
    var skillsPickerData: [String] = []
    var interestsPickerData: [String] = []
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
       
        skillsPickerData = ["UIDesign", "Graphics Design", "Logo Design", "Illustration", "Web Design", "Mobile App", "Back End", "Front End", "Photography", "Video Editing", "Tutoring"]
        
       
        interestsPickerData = ["Design", "Development", "Photography", "Tutoring"]
    }
    
    
    func fetchUserData() {
        guard let userID = userID else { return }
        
       
        let userRef = db.collection("user").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.interests = data?["interests"] as? [String] ?? []
                self.interestsTextField.text = self.interests.joined(separator: ", ")
            } else {
                print("User document does not exist")
            }
        }
        
        
        let providerDetailsRef = db.collection("ProviderDetails")
        let query = providerDetailsRef.whereField("userId", isEqualTo: userID)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching provider details: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                let document = snapshot.documents[0]
                let data = document.data()
                self.skills = data["skills"] as? [String] ?? []
                self.skillsTextField.text = self.skills.joined(separator: ", ")
            } else {
                print("Provider details document not found for userId: \(userID)")
            }
        }
    }
    
  
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if skillsTextField.isFirstResponder {
            return skillsPickerData.count
        } else if interestsTextField.isFirstResponder {
            return interestsPickerData.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if skillsTextField.isFirstResponder {
            return skillsPickerData[row]
        } else if interestsTextField.isFirstResponder {
            return interestsPickerData[row]
        }
        return nil
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedItem: String
        if skillsTextField.isFirstResponder {
            selectedItem = skillsPickerData[row]
            if selectedSkills.count < 4, !selectedSkills.contains(selectedItem) {
                selectedSkills.append(selectedItem)
            }
            skillsTextField.text = selectedSkills.joined(separator: ", ")
        } else if interestsTextField.isFirstResponder {
            selectedItem = interestsPickerData[row]
            if selectedInterests.count < 4, !selectedInterests.contains(selectedItem) {
                selectedInterests.append(selectedItem)
            }
            interestsTextField.text = selectedInterests.joined(separator: ", ")
        }
    }
    
   
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        if skillsTextField.text?.isEmpty ?? true && interestsTextField.text?.isEmpty ?? true {
            showError(message: "Please enter at least one skill or interest.")
            return
        }
        
        updateUserSkillsAndInterests()
    }
    
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateUserSkillsAndInterests() {
        guard let userID = userID else { return }

        
        var updatedSkills = selectedSkills
        var updatedInterests = selectedInterests
        
        
        let providerDetailsRef = db.collection("ProviderDetails")
        let query = providerDetailsRef.whereField("userId", isEqualTo: userID)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }

            
            if let document = snapshot?.documents.first {
                let documentRef = document.reference

              
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
