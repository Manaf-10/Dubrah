import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ViewProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // UI Elements
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

    var userID: String? // To hold the user ID for fetching the data
    var services: [(title: String, imageURL: String)] = [] // Array to hold "What I Offer" data
    var completedOrdersCount = 0 // To hold the count of completed orders

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch data when the view is about to appear
        if let user = AuthManager.shared.currentUser {
            fetchUserProfileData(userID: Auth.auth().currentUser?.uid ?? "")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        makeCircular(profileImageView)

        // Ensure the user is logged in and fetch their data
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }

        self.userID = "iNTjqIe10AX4M4AoLdvBSoDxuSg1" // Hardcoded user ID for testing purposes
        fetchUserProfileData(userID: userID)
        fetchCompletedOrdersCount(userID: userID)

        // Set up collection view
        whatIOfferCollectionView.delegate = self
        whatIOfferCollectionView.dataSource = self

        // Set up collection view layout
        if let layout = whatIOfferCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 150, height: 150) // Fixed size for cells
            layout.minimumLineSpacing = 10  // Spacing between rows
            layout.minimumInteritemSpacing = 10  // Spacing between items in a row
            whatIOfferCollectionView.collectionViewLayout = layout
        }
    }

    func fetchUserProfileData(userID: String) {
        let db = Firestore.firestore()

        // Fetch User Data (from 'user' collection)
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

        // Fetch Provider Details (from 'ProviderDetails' collection)
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

        // Fetch "Services" Data (from 'Service' collection)
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
        
        // Profile Image
        if let imageUrl = data?["profilePicture"] as? String, let url = URL(string: imageUrl) {
            Task {
                if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.profileImageView.image = UIImage(named: "Person") // Placeholder
                    }
                }
            }
        } else {
            self.profileImageView.image = UIImage(named: "Person") // Placeholder
        }
        
        // Bio
        if let bio = data?["bio"] as? String, !bio.isEmpty {
            self.bioLabel.text = bio
        } else {
            self.bioLabel.isHidden = true
        }
        
        // Interests
        if let interests = data?["interests"] as? [String], !interests.isEmpty {
            self.interestsLabel.text = interests.joined(separator: ", ")
        } else {
            self.interestsLabel.isHidden = true
        }
    }

    func updateProviderDetailsUI(_ data: [String: Any]?) {
        // Skills
        if let skills = data?["skills"] as? [String], !skills.isEmpty {
            self.skillsLabel.text = skills.joined(separator: ", ")
        } else {
            self.skillsLabel.isHidden = true
        }
        
        // Rating
        if let rating = data?["averageRating"] as? Double {
            self.ratingLabel.text = "\(rating)"
        } else {
            self.ratingLabel.isHidden = true
        }
    }

    func updateWhatIOfferUI(_ documents: [QueryDocumentSnapshot]) {
        // Populate services array with the title and image URL from the 'Service' collection
        self.services = documents.compactMap { document in
            let title = document["title"] as? String
            let imageURL = document["image"] as? String
            if let title = title, let imageURL = imageURL {
                return (title, imageURL)
            }
            return nil
        }

        // Limit the number of services displayed to 3
        if self.services.count > 3 {
            self.services = Array(self.services.prefix(3))
        }

        // Reload the collection view after fetching the data
        DispatchQueue.main.async {
            self.whatIOfferCollectionView.reloadData()
        }
    }

    func fetchCompletedOrdersCount(userID: String) {
        let db = Firestore.firestore()

        // Fetch orders with 'completed' status for the given userID
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
                    self.numServicesLabel.text = "0"
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhatIOfferCell", for: indexPath) as! UserProfileCollectionViewCell
        let service = services[indexPath.row]
        cell.lblOfferTitle.text = service.title

        // Download and display the image asynchronously
        Task {
            if let image = await ImageDownloader.fetchImage(from: service.imageURL) {
                DispatchQueue.main.async {
                    cell.imgOffer.image = image
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
