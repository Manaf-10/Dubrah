import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EditProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var interestsCollectionView: UICollectionView!
    @IBOutlet weak var skillsCollectionView: UICollectionView!

    var userID: String?
    var skills: [String] = []
    var interests: [String] = []
    var currentProfileImageUrl: String?

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        skillsCollectionView.delegate = self
        skillsCollectionView.dataSource = self
        interestsCollectionView.delegate = self
        interestsCollectionView.dataSource = self

 
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        self.userID = userID
        fetchUserProfileData(userID: userID)

    
        if let profileImageView = profileImageView {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(tapGesture)
        }
    }

  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let userID = userID {
            fetchUserProfileData(userID: userID)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

   
    func fetchUserProfileData(userID: String) {
       
        let userRef = db.collection("user").document(userID)

        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()

              
                self.fullNameLabel.text = data?["fullName"] as? String ?? "No Name"
                self.usernameLabel.text = data?["userName"] as? String ?? "No Username"
                self.bioLabel.text = data?["bio"] as? String ?? "No Bio"

              
                self.bioLabel.isHidden = self.bioLabel.text?.isEmpty ?? true

              
                if let imageUrl = data?["profilePicture"] as? String, !imageUrl.isEmpty {
                    self.currentProfileImageUrl = imageUrl
                    Task {
                        if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                            self.profileImageView.image = image
                            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                            self.profileImageView.clipsToBounds = true
                        }
                    }
                } else {
                 
                    self.profileImageView.image = UIImage(named: "Person")
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                    self.profileImageView.clipsToBounds = true
                }
            } else {
                print("User document does not exist")
            }
        }

        
        let providerDetailsRef = db.collection("ProviderDetails").whereField("userId", isEqualTo: userID)

        providerDetailsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting provider details document: \(error.localizedDescription)")
                return
            }

            if let documents = querySnapshot?.documents, !documents.isEmpty {
                let data = documents.first?.data()

                
                self.skills = data?["skills"] as? [String] ?? []

                
                self.skillsCollectionView.isHidden = self.skills.isEmpty
                self.skillsCollectionView.reloadData()
            } else {
                print("Provider details document not found for this userId.")
            }
        }

       
        let userRefInterests = db.collection("user").document(userID)

        userRefInterests.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document for interests: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()

              
                self.interests = data?["interests"] as? [String] ?? []

            
                self.interestsCollectionView.isHidden = self.interests.isEmpty
                self.interestsCollectionView.reloadData()
            } else {
                print("User document does not exist for interests")
            }
        }
    }

   
    @objc func profileImageTapped() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }

 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Failed to select image")
            picker.dismiss(animated: true, completion: nil)
            return
        }

       
        let alert = UIAlertController(title: "Change Profile Picture", message: "Do you want to change your profile picture?", preferredStyle: .alert)

      
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.uploadProfileImage(selectedImage)
        }))

       
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

       
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }

        picker.dismiss(animated: true, completion: nil)
    }

    
    func uploadProfileImage(_ image: UIImage) {
        
        MediaManager.shared.uploadImage(image) { result in
            switch result {
            case .success(let imageUrl):
                
                self.updateProfileImageUrl(imageUrl)
            case .failure(let error):
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }

    
    func updateProfileImageUrl(_ imageUrl: String) {
        guard let userID = userID else { return }

        let userRef = db.collection("user").document(userID)

        userRef.updateData([ "profilePicture": imageUrl ]) { error in
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
