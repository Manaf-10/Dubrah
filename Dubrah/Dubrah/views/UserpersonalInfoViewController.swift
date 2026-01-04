import UIKit
import FirebaseAuth
import FirebaseFirestore
import Cloudinary
import Photos

class UserpersonalInfoViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullnameTextField: UITextField!
    @IBOutlet weak var BioTextField: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var DateOfBirthtxt: UITextField!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGesture)
        
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        DateOfBirthtxt.inputView = datePicker
        DateOfBirthtxt.text = formatDate(date: Date())
        
        
        continueBtn.isEnabled = false
        
        
        usernameTextField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        DateOfBirthtxt.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        continueBtn.layer.cornerRadius = 12.0
        continueBtn.clipsToBounds = true
   
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func validateForm() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let fullName = fullnameTextField.text, !fullName.isEmpty,
              let dateOfBirth = DateOfBirthtxt.text, !dateOfBirth.isEmpty else {
            continueBtn.isEnabled = false
            return
        }
        
      
        continueBtn.isEnabled = true
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        DateOfBirthtxt.text = formatDate(date: datePicker.date)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string(from: date)
    }
    
    
    @objc func profileImageTapped() {
        requestPhotoLibraryPermission { [weak self] isGranted in
            if isGranted {
                
                DispatchQueue.main.async {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = .photoLibrary
                    imagePickerController.allowsEditing = true
                    self?.present(imagePickerController, animated: true)
                }
            } else {
                self?.showAlert(message: "We need permission to access your photo library to upload a profile image.")
            }
        }
    }
    
  
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized:
            
            completion(true)
        case .denied, .restricted:
            
            completion(false)
        case .notDetermined:
          
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .limited:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showAlert(message: "Username cannot be empty")
            return
        }
        
        guard let fullName = fullnameTextField.text, !fullName.isEmpty else {
            showAlert(message: "Full name cannot be empty")
            return
        }
        
        guard let dateOfBirth = DateOfBirthtxt.text, !dateOfBirth.isEmpty else {
            showAlert(message: "Date of birth cannot be empty")
            return
        }
        
        guard let bio = BioTextField.text, !bio.isEmpty else {
            showAlert(message: "Bio cannot be empty")
            return
        }
        
        
        if let image = selectedImage {
            uploadProfilePicture(image: image) { imageUrl in
                self.saveUserInfo(username: username, fullName: fullName, dateOfBirth: dateOfBirth, bio: bio, profileImageUrl: imageUrl)
            }
        } else {
          
            saveUserInfo(username: username, fullName: fullName, dateOfBirth: dateOfBirth, bio: bio, profileImageUrl: nil)
        }
    }
    
    func uploadProfilePicture(image: UIImage, completion: @escaping (String?) -> Void) {
        MediaManager.shared.uploadImage(image) { result in
            switch result {
            case .success(let url):
                print("Uploaded image URL: \(url)")
                completion(url)
            case .failure(let error):
                print("Failed to upload image: \(error.localizedDescription)")
                self.showAlert(message: "Error uploading image: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    func saveUserInfo(username: String, fullName: String, dateOfBirth: String, bio: String, profileImageUrl: String?) {
        let userRef = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
        
        var userData: [String: Any] = [
            "userName": username,
            "fullName": fullName,
            "dateOfBirth": dateOfBirth,
            "bio": bio
        ]
        
      
        if let imageUrl = profileImageUrl {
            userData["profilePicture"] = imageUrl
        }
        
        
        userRef.setData(userData) { error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
           
            self.performSegue(withIdentifier: "ShowSkillsAndInterests", sender: nil)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UserpersonalInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
            self.selectedImage = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
