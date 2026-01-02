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
        // Reference to Firestore database
        let db = Firestore.firestore()
        
        // Fetch User Data (from 'user' collection)
        let userRef = db.collection("user").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    // Check if data exists before updating the UI
                    if let fullName = data?["fullName"] as? String {
                        self.fullNameLabel.text = fullName
                    } else {
                        self.fullNameLabel.isHidden = true // Hide label if no data
                    }
                    
                    if let username = data?["userName"] as? String {
                        self.usernameLabel.text = username
                    } else {
                        self.usernameLabel.isHidden = true // Hide label if no data
                    }
                    
                    // Load profile image if available
                    if let imageUrl = data?["profilePicture"] as? String, let url = URL(string: imageUrl) {
                        // Using Task to fetch the image asynchronously
                        Task {
                            if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                                DispatchQueue.main.async {
                                    self.profileImageView.image = image
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.profileImageView.image = UIImage(named: "Person") // Placeholder image if image fails to load
                                }
                            }
                        }
                    } else {
                        self.profileImageView.image = UIImage(named: "Person") // Placeholder image if no image URL
                    }
                    
                    // Bio, Skills, and Interests
                    if let bio = data?["bio"] as? String, !bio.isEmpty {
                        self.bioLabel.text = bio
                    } else {
                        self.bioLabel.isHidden = true // Hide if no bio data
                    }
                    
                    // Skills: Check if skills are available and not empty
                    if let skills = data?["skills"] as? [String], !skills.isEmpty {
                        var allSkills = ""
                        for skill in skills {
                            allSkills += skill + ", "
                        }
                        self.skillsLabel.text = allSkills
                    } else {
                        self.skillsLabel.isHidden = true // Hide if no skills data
                    }
                    
                    // Interests: Check if interests are available and not empty
                    if let interests = data?["interests"] as? [String], !interests.isEmpty {
                        var allInterests = ""
                        for interest in interests {
                            allInterests += interest + ", "
                        }
                        self.interestsLabel.text = allInterests
                    } else {
                        self.interestsLabel.isHidden = true // Hide if no interests data
                    }
                } else {
                    print("User document does not exist")
                }
            }
        }
        
        // Fetch Rating and NumServices Data (from 'ProviderDetails' collection)
        let providerDetailsRef = db.collection("ProviderDetails").document(userID)
        providerDetailsRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting provider details document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    // Skills: Check if skills data exists
                    if let skills = data?["skills"] as? [String], !skills.isEmpty {
                        var allSkills = ""
                        for skill in skills {
                            allSkills += skill + ", "
                        }
                        self.skillsLabel.text = allSkills
                    } else {
                        self.skillsLabel.isHidden = true // Hide if no skills data
                    }
                    
                    // Check if rating data exists
                    if let rating = data?["rating"] as? Double {
                        self.ratingLabel.text = "Rating: \(rating)"
                    } else {
                        self.ratingLabel.isHidden = true // Hide label if no data
                    }
                    
                    // Check if number of services data exists
                    if let numServices = data?["numServices"] as? Int {
                        self.numServicesLabel.text = "Services: \(numServices)"
                    } else {
                        self.numServicesLabel.isHidden = true // Hide label if no data
                    }
                } else {
                    print("Provider details document does not exist")
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
        // Assuming you have an image downloading method for async image loading
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
