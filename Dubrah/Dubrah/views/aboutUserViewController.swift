import UIKit
import FirebaseFirestore
import FirebaseAuth
import Cloudinary

class aboutUserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var textSelectSkills: UITextField!
    @IBOutlet weak var uploadImageBtn: UIButton!
    @IBOutlet weak var textSelectYears: UITextField!
    
    let pickerYears = UIPickerView()
    let pickerSkills = UIPickerView()
    
    var arrYears = ["1 - 5 Years", "5+ Years", "10+ Years"]
    var primarySkills = ["Design", "Photography", "Editing", "Illustration", "UI Design"]
    
    var selectedSkills: Set<Int> = []
    var currentIndex = 0
    var selectedPortfolioImages: [UIImage] = []
    var selectedPortfolioUrls: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerYears.delegate = self
        pickerYears.dataSource = self
        pickerSkills.delegate = self
        pickerSkills.dataSource = self
        
        setupToolbar(for: textSelectYears)
        setupToolbar(for: textSelectSkills)
        
        textSelectYears.inputView = pickerYears
        textSelectSkills.inputView = pickerSkills
        continueBtn.layer.cornerRadius = 12.0
        continueBtn.clipsToBounds = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupToolbar(for textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closePicker))
        toolBar.setItems([btnDone], animated: true)
        textField.inputAccessoryView = toolBar
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerYears {
            return arrYears.count
        } else {
            return primarySkills.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerYears {
            return arrYears[row]
        } else {
            return primarySkills[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerYears {
            currentIndex = row
            textSelectYears.text = arrYears[row]
        } else {
            // Toggle selection for the skills picker (multi-selection)
            if selectedSkills.contains(row) {
                selectedSkills.remove(row)
            } else {
                selectedSkills.insert(row)
            }
            updateSkillsSelection()
        }
    }

    func updateSkillsSelection() {
        var selectedSkillsArray = [String]()
        for index in selectedSkills {
            selectedSkillsArray.append(primarySkills[index])
        }
        textSelectSkills.text = selectedSkillsArray.joined(separator: ", ")
    }

    @objc func closePicker() {
        textSelectYears.text = arrYears[currentIndex]
        view.endEditing(true)
    }

    @IBAction func portfolioUploadButtonTapped(_ sender: UIButton) {
        openImagePicker()
    }
    
    func openImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.modalPresentationStyle = .fullScreen
        
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        validateAndSaveWorkDetails()
    }

    func validateAndSaveWorkDetails() {
        if selectedPortfolioImages.isEmpty {
            showAlert(message: "Please upload at least one portfolio image.")
            return
        }
        
        // Proceed to upload images to Cloudinary
        uploadImagesToCloudinary(images: selectedPortfolioImages)
    }

    func uploadImagesToCloudinary(images: [UIImage]) {
        var uploadedUrls = [String]()
        
        let dispatchGroup = DispatchGroup()
        
        for image in images {
            dispatchGroup.enter()  // Enter the group for each image
            
            MediaManager.shared.uploadImage(image) { result in
                switch result {
                case .success(let url):
                    uploadedUrls.append(url)  // Add the URL to the array
                case .failure:
                    self.showAlert(message: "Failed to upload portfolio image")
                }
                dispatchGroup.leave()  // Leave the group once upload completes
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !uploadedUrls.isEmpty {
                // If the URLs were uploaded successfully, save to Firestore
                self.saveImagesAndDataToFirestore(urls: uploadedUrls)
            } else {
                self.showAlert(message: "No images uploaded successfully.")
            }
        }
    }

    func saveImagesAndDataToFirestore(urls: [String]) {
        // Query the ProviderDetails collection for the document with the user's ID
        let providerDetailsRef = Firestore.firestore().collection("ProviderDetails")
        let query = providerDetailsRef.whereField("userId", isEqualTo: Auth.auth().currentUser!.uid)
        
        query.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }  // Prevents strong reference cycle
            
            if let error = error {
                self.showAlert(message: "Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            // Check if a document is found
            if let document = snapshot?.documents.first {
                let documentRef = document.reference
                
                // Prepare the data to update
                let updatedData: [String: Any] = [
                    "experience": self.textSelectYears.text ?? "",
                    "skills": Array(self.selectedSkills).map { self.primarySkills[$0] },
                    "portifolioImages": urls,
                    "timestamp": FieldValue.serverTimestamp() // Optional: Timestamp for when the data is saved
                ]
                
                // Update the existing document with the new data
                documentRef.updateData(updatedData) { error in
                    if let error = error {
                        self.showAlert(message: "Error updating data: \(error.localizedDescription)")
                    } else {
                        print("Data updated successfully in ProviderDetails")
                        self.performSegue(withIdentifier: "GoToFinalPage", sender: nil)
                    }
                }
            } else {
                self.showAlert(message: "No document found for this user.")
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        if !selectedPortfolioImages.isEmpty {
            continueBtn.isEnabled = true
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            selectedPortfolioImages.append(selectedImage)
            print("Selected portfolio image added: \(selectedImage)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
