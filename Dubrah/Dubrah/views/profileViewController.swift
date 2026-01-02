import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class profileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    // UI Elements
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel! // For displaying the username
    @IBOutlet weak var ratingLabel: UILabel! // For displaying the rating
    @IBOutlet weak var numServicesLabel: UILabel! // For displaying the number of services
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var providerReviewsLabel: UILabel!
    
    // UICollectionView for displaying "What I Offer"
    @IBOutlet weak var whatIOfferCollectionView: UICollectionView!
    
    var userID: String? // To hold the user ID for fetching the data
    var services: [(title: String, imageURL: String)] = [] // Array to hold "What I Offer" data
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            // Log in
            if let user = AuthManager.shared.currentUser {
                fetchUserProfileData(userID: Auth.auth().currentUser?.uid ?? "")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCircular(profileImageView)
        
        Task {
            
            if let user = AuthManager.shared.currentUser {
                fetchUserProfileData(userID: Auth.auth().currentUser?.uid ?? "")
            }
        }

        // Ensure the user is logged in and fetch their data
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        self.userID = userID
        fetchUserProfileData(userID: userID)
        
        // Set up collection view
        whatIOfferCollectionView.delegate = self
        whatIOfferCollectionView.dataSource = self
    }
    
    func fetchUserProfileData(userID: String) {
        let db = Firestore.firestore()

        // Fetch User Data (from 'user' collection)
        let userRef = db.collection("user").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()

                    // Update UI with user data
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
                } else {
                    print("User document does not exist")
                }
            }
        }

        // Fetch Provider Details (from 'ProviderDetails' collection)
        let providerDetailsRef = db.collection("ProviderDetails").whereField("userId", isEqualTo: userID)
        providerDetailsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting provider details document: \(error)")
            } else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    // Fetch the first document (as there should be only one per user)
                    let document = snapshot.documents.first
                    let data = document?.data()

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

                    // Number of services
                    if let numServices = data?["numServices"] as? Int {
                        self.numServicesLabel.text = "Services: \(numServices)"
                    } else {
                        self.numServicesLabel.isHidden = true
                    }
                } else {
                    print("No provider details found for this user")
                }
            }
        }

        // Fetch "What I Offer" Data (from 'Service' collection)
        let serviceRef = db.collection("Service").document(userID)
        serviceRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting service document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    let whatIOffer = data?["whatIOffer"] as? [[String: String]] ?? []

                    // Populate services array if data exists
                    if !whatIOffer.isEmpty {
                        self.services = whatIOffer.compactMap {
                            guard let title = $0["title"], let imageURL = $0["image"] else {
                                return nil
                            }
                            return (title, imageURL)
                        }

                        // Limit the number of services displayed to 3
                        if self.services.count > 3 {
                            self.services = Array(self.services.prefix(3))
                        }

                        // Reload the collection view after fetching the data
                        DispatchQueue.main.async {
                            self.whatIOfferCollectionView.reloadData()
                        }
                    } else {
                        self.whatIOfferCollectionView.isHidden = true // Hide collection view if no data
                    }
                } else {
                    print("Service document does not exist")
                }
            }
        }
    }
    
    // MARK: - UICollectionView DataSource and Delegate Methods
    
    // Number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    // Configure each item in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhatIOfferCell", for: indexPath) as! whatIOfferCollectionViewCell
        
        let service = services[indexPath.row]
        cell.offersNamelbl.text = service.title
        
        // Download and display the image asynchronously
        Task {
            if let image = await ImageDownloader.fetchImage(from: service.imageURL) {
                DispatchQueue.main.async {
                    cell.offersImg.image = image
                }
            }
        }
        
        return cell
    }
    
    // Handle item selection (optional)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected service: \(services[indexPath.row].title)")
    }
    
}
