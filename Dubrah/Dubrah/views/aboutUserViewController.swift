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
    
    var selectedSkills: Set<Int> = []  // Store selected skill indices
    var currentIndex = 0
    var selectedPortfolioImages: [UIImage] = [] // Store selected portfolio images
    var selectedPortfolioUrls: [String] = [] // Store Cloudinary URLs of the images
    
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
        // Show the image picker to select the first image
        openImagePicker()
    }
    
    // This function opens the image picker for the user to select an image
    func openImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        imagePickerController.modalPresentationStyle = .fullScreen
        
        present(imagePickerController, animated: true, completion: nil)
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        // Validate inputs and save data to Firestore
        validateAndSaveWorkDetails()
    }
    
    // MARK: - Validate Inputs and Save Data
    func validateAndSaveWorkDetails() {
        // Validate if portfolio images have been selected
        if selectedPortfolioImages.isEmpty {
            showAlert(message: "Please upload at least one portfolio image.")
            return
        }
        
        // Proceed with uploading images and saving data
        uploadImagesToCloudinary(images: selectedPortfolioImages)
    }
    
    // Upload the images to Cloudinary
    func uploadImagesToCloudinary(images: [UIImage]) {
        var uploadedUrls = [String]()
        
        let dispatchGroup = DispatchGroup()
        
        // Loop through selected images and upload them to Cloudinary
        for image in images {
            dispatchGroup.enter()  // Enter group for each image upload
            
            // Use your existing Cloudinary upload function from the constants file
            MediaManager.shared.uploadImage(image) { result in
                switch result {
                case .success(let url):
                    uploadedUrls.append(url)  // Append the Cloudinary URL to the array
                case .failure:
                    self.showAlert(message: "Failed to upload portfolio image")
                }
                dispatchGroup.leave()  // Leave group after each upload
            }
        }
        
        // After all images are uploaded, save URLs and other data to Firestore
        dispatchGroup.notify(queue: .main) {
            // Save the URLs and other data to Firestore if all images are uploaded successfully
            if !uploadedUrls.isEmpty {
                self.saveImagesAndDataToFirestore(urls: uploadedUrls)
            } else {
                self.showAlert(message: "No images uploaded successfully.")
            }
        }
    }

    // Save images, years of experience, and skills to Firestore
    func saveImagesAndDataToFirestore(urls: [String]) {
        let userRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        
        // Collect data to save
        var userData: [String: Any] = [
            "experience": textSelectYears.text ?? "", // Years of experience
            "skills": Array(selectedSkills).map { primarySkills[$0] }, // Save the skills as an array
            "portfolio": urls  // Save the array of URLs
        ]
        
        // Save the data to Firestore
        userRef.updateData(userData) { error in
            if let error = error {
                self.showAlert(message: "Error saving data: \(error.localizedDescription)")
            } else {
                // Proceed to the next page or flow
                self.performSegue(withIdentifier: "GoToFinalPage", sender: nil)
            }
        }
    }

    // Function to show an alert message to the user
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // Enable the continue button when at least one image is selected
        if !selectedPortfolioImages.isEmpty {
            continueBtn.isEnabled = true
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the selected image from the picker
        if let selectedImage = info[.originalImage] as? UIImage {
            // Add the selected image to the portfolio images array
            selectedPortfolioImages.append(selectedImage)
            print("Selected portfolio image added: \(selectedImage)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
