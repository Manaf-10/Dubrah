import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class profileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var totalReviewsLbl: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var numServicesLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var providerReviewsLabel: UILabel!
    @IBOutlet weak var whatIOfferCollectionView: UICollectionView!
    
    var userID: String?
    var services: [(title: String, imageURL: String)] = []
    var completedOrdersCount = 0
    var totalReviewsCount = 0  // Add this variable to store the total review count
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            if let user = AuthManager.shared.currentUser {
                fetchUserProfileData(userID: Auth.auth().currentUser?.uid ?? "")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeCircular(profileImageView)
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        self.userID = userID
        fetchUserProfileData(userID: userID)
        fetchCompletedOrdersCount(userID: userID)
        
        whatIOfferCollectionView.delegate = self
        whatIOfferCollectionView.dataSource = self
    }
    
    func fetchUserProfileData(userID: String) {
        let db = Firestore.firestore()
        
        // Fetch User data
        let userRef = db.collection("user").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
            } else if let document = document, document.exists {
                let data = document.data()
                self.updateUserProfileUI(data)
            } else {
                print("User document does not exist")
            }
        }
        
        // Fetch ProviderDetails data
        let providerDetailsRef = db.collection("ProviderDetails").whereField("userId", isEqualTo: userID)
        providerDetailsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting provider details document: \(error)")
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                let document = snapshot.documents.first
                let data = document?.data()
                self.updateProviderDetailsUI(data)
            }
        }
        
        // Fetch Service data
        let serviceRef = db.collection("Service").whereField("providerID", isEqualTo: userID)
        serviceRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting service document: \(error.localizedDescription)")
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                self.updateWhatIOfferUI(snapshot.documents)
            } else {
                print("No service document found for this user")
            }
        }
    }
    
    func updateUserProfileUI(_ data: [String: Any]?) {
        self.fullNameLabel.text = data?["fullName"] as? String ?? "No full name"
        self.usernameLabel.text = data?["userName"] as? String ?? "No username"
        
        if let imageUrl = data?["profilePicture"] as? String, let url = URL(string: imageUrl) {
            Task {
                if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(named: "Person")
                    }
                }
            }
        } else {
            self.profileImageView.image = UIImage(named: "Person")
        }
        
        if let bio = data?["bio"] as? String, !bio.isEmpty {
            self.bioLabel.text = bio
        } else {
            self.bioLabel.isHidden = true
        }
        
        if let interests = data?["interests"] as? [String], !interests.isEmpty {
            self.interestsLabel.text = interests.joined(separator: ", ")
        } else {
            self.interestsLabel.isHidden = true
        }
        
        if data?["interests"] == nil || data?["bio"] == nil {
            self.ratingLabel.isHidden = true
            self.numServicesLabel.isHidden = true
        }
    }
    
    func updateProviderDetailsUI(_ data: [String: Any]?) {
        // Get skills
        if let skills = data?["skills"] as? [String], !skills.isEmpty {
            self.skillsLabel.text = skills.joined(separator: ", ")
        } else {
            self.skillsLabel.isHidden = true
        }
        
        // Get average rating
        if let rating = data?["averageRating"] as? Double {
            self.ratingLabel.text = "\(rating)"
        } else {
            self.ratingLabel.isHidden = true
        }
        
        // Get reviews count
        if let reviews = data?["reviews"] as? [[String: Any]] {
            self.totalReviewsCount = reviews.count // Fetch and count the reviews
            self.totalReviewsLbl.text = "(\(self.totalReviewsCount) Reviws)"
        } else {
            self.totalReviewsLbl.text = "No Reviews"
        }
        
        if data?["skills"] == nil || data?["averageRating"] == nil {
            self.skillsLabel.isHidden = true
            self.ratingLabel.isHidden = true
        }
    }
    
    func updateWhatIOfferUI(_ documents: [QueryDocumentSnapshot]) {
        self.services = documents.compactMap { document in
            let title = document["title"] as? String
            let imageURL = document["image"] as? String
            if let title = title, let imageURL = imageURL {
                return (title, imageURL)
            }
            return nil
        }
        
        if self.services.count > 2 {
            self.services = Array(self.services.prefix(2))
        }
        
        DispatchQueue.main.async {
            self.whatIOfferCollectionView.reloadData()
        }
    }
    
    func fetchCompletedOrdersCount(userID: String) {
        let db = Firestore.firestore()
        
        let ordersRef = db.collection("orders")
            .whereField("userID", isEqualTo: userID)
            .whereField("status", isEqualTo: "completed")
        
        ordersRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting orders document: \(error.localizedDescription)")
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                self.completedOrdersCount = snapshot.documents.count
                DispatchQueue.main.async {
                    self.numServicesLabel.text = "\(self.completedOrdersCount)"
                }
            } else {
                self.completedOrdersCount = 0
                DispatchQueue.main.async {
                    self.numServicesLabel.text = "No"
                }
                print("No completed orders found")
            }
        }
    }
    
    // MARK: - UICollectionView DataSource and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "whatIOffer", for: indexPath) as! whatIOfferCollectionViewCell
        let service = services[indexPath.row]
        cell.offersNamelbl.text = service.title
        
        Task {
            if let image = await ImageDownloader.fetchImage(from: service.imageURL) {
                DispatchQueue.main.async {
                    cell.offersImg.image = image
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected service: \(services[indexPath.row].title)")
    }
    
    // Helper function to make the profile image circular
    func makeCircular(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
}
