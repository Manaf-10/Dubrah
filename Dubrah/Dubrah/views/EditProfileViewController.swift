import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EditProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // UI Elements
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var interestsCollectionView: UICollectionView!
    @IBOutlet weak var skillsCollectionView: UICollectionView!
    
    var userID: String?
    var skills: [String] = []
    var interests: [String] = [] // Fetch this from Firestore
    var currentProfileImageUrl: String? // To hold the current profile image URL
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up collection views
        skillsCollectionView.delegate = self
        skillsCollectionView.dataSource = self
        interestsCollectionView.delegate = self
        interestsCollectionView.dataSource = self
        
        // Ensure user is logged in and fetch their profile data
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        self.userID = userID
        fetchUserProfileData(userID: userID)
        
        // Make the profile image view tappable
        if let profileImageView = profileImageView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(tapGesture)
        }
    }
    
    // Fetch User Profile Data (full name, username, bio, profile image URL, skills, and interests)
    func fetchUserProfileData(userID: String) {
        // Reference to Firestore database (using the "user" collection)
        let userRef = db.collection("user").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                // Fetch and display the user's full name, username, and bio
                self.fullNameLabel.text = data?["fullName"] as? String ?? "No Name"
                self.usernameLabel.text = data?["username"] as? String ?? "No Username"
                self.bioLabel.text = data?["bio"] as? String ?? "No Bio"
                
                // Hide bio if empty
                self.bioLabel.isHidden = self.bioLabel.text?.isEmpty ?? true
                
                // Load and display the profile image
                if let imageUrl = data?["profileImageUrl"] as? String, !imageUrl.isEmpty {
                    self.currentProfileImageUrl = imageUrl
                    Task {
                        if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                            self.profileImageView.image = image
                            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                            self.profileImageView.clipsToBounds = true
                        }
                    }
                } else {
                    self.profileImageView.image = UIImage(named: "defaultProfileImage") // Fallback to a default image if no URL
                }
            } else {
                print("User document does not exist")
            }
        }
        
        // Fetch Skills Data (from 'ProviderDetails' collection)
        let providerDetailsRef = db.collection("ProviderDetails").document(userID)
        
        providerDetailsRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting provider details document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                // Fetch and display skills
                self.skills = data?["skills"] as? [String] ?? []
                
                // Hide skills collection view if no skills
                self.skillsCollectionView.isHidden = self.skills.isEmpty
                self.skillsCollectionView.reloadData()
            } else {
                print("Provider details document does not exist")
            }
        }
        
        // Fetch Interests Data (from 'user' collection)
        let userRefInterests = db.collection("user").document(userID)
        
        userRefInterests.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document for interests: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                // Fetch and display interests
                self.interests = data?["interests"] as? [String] ?? []
                
                // Hide interests collection view if no interests
                self.interestsCollectionView.isHidden = self.interests.isEmpty
                self.interestsCollectionView.reloadData()
            } else {
                print("User document does not exist for interests")
            }
        }
    }
    
    // MARK: - Profile Image Selection
    @objc func profileImageTapped() {
        // Allow the user to pick an image from their photo library
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // UIImagePickerControllerDelegate method to handle image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Failed to select image")
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        // Show alert to confirm if the user wants to change the profile picture
        let alert = UIAlertController(title: "Change Profile Picture", message: "Do you want to change your profile picture?", preferredStyle: .alert)
        
        // If user taps "Yes", upload the image to Firebase
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.uploadProfileImage(selectedImage)
        }))
        
        // If user taps "No", revert to the original profile image
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            if let imageUrl = self.currentProfileImageUrl {
                Task {
                    if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                        self.profileImageView.image = image
                        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                        self.profileImageView.clipsToBounds = true
                    }
                }
            }
        }))
        
        present(alert, animated: true, completion: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Upload the selected image to Cloudinary and update Firestore
    func uploadProfileImage(_ image: UIImage) {
        // Use MediaManager to upload the image to Cloudinary
        MediaManager.shared.uploadImage(image) { result in
            switch result {
            case .success(let imageUrl):
                // Update the profile image URL in Firestore
                self.updateProfileImageUrl(imageUrl)
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
    
    // Update profile image URL in Firestore
    func updateProfileImageUrl(_ imageUrl: String) {
        guard let userID = userID else { return }
        
        let userRef = db.collection("user").document(userID)
        
        userRef.updateData([ "profileImageUrl": imageUrl ]) { error in
            if let error = error {
                print("Error updating profile image URL: \(error.localizedDescription)")
            } else {
                print("Profile image successfully updated.")
                Task {
                    if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                        self.profileImageView.image = image
                        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                        self.profileImageView.clipsToBounds = true
                    }
                }
            }
        }
    }
    
    // MARK: - UICollectionView DataSource and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == skillsCollectionView {
            return skills.isEmpty ? 1 : skills.count
        } else if collectionView == interestsCollectionView {
            return interests.isEmpty ? 1 : interests.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == skillsCollectionView {
            let cell = skillsCollectionView.dequeueReusableCell(withReuseIdentifier: "Skillscell", for: indexPath) as! skillsCollectionViewCell
            if skills.isEmpty {
                // Display an empty cell
                cell.Skillslbl.text = "No Skills Available"
                cell.backgroundColor = .lightGray
                cell.layer.cornerRadius = 12
            } else {
                cell.Skillslbl.text = skills[indexPath.row]
                cell.backgroundColor = .blue
                cell.Skillslbl.textColor = .white
                cell.layer.cornerRadius = 12
            }
            return cell
        } else if collectionView == interestsCollectionView {
            let cell = interestsCollectionView.dequeueReusableCell(withReuseIdentifier: "Interestscell", for: indexPath) as! InterestsCollectionViewCell
            if interests.isEmpty {
                // Display an empty cell
                cell.Interestslbl.text = "No Interests Available"
                cell.backgroundColor = .lightGray
                cell.layer.cornerRadius = 12
            } else {
                cell.Interestslbl.text = interests[indexPath.row]
                cell.backgroundColor = .blue
                cell.Interestslbl.textColor = .white
                cell.layer.cornerRadius = 12
            }
            return cell
        }
        return UICollectionViewCell()
    }
}
