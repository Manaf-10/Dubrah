import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ViewProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
   
    // UI Elements with updated outlet names
    @IBOutlet weak var lblFullName: UILabel!
       @IBOutlet weak var lblUsername: UILabel!
       @IBOutlet weak var lblRating: UILabel!
       @IBOutlet weak var lblNumServices: UILabel!
       @IBOutlet weak var lblBio: UILabel!
       @IBOutlet weak var lblSkills: UILabel!
       @IBOutlet weak var lblInterests: UILabel!
       @IBOutlet weak var imgProfile: UIImageView!
       @IBOutlet weak var lblProviderReviews: UILabel!
       
       // UICollectionView for displaying "What I Offer"
       @IBOutlet weak var collectionViewWhatIOffer: UICollectionView!
    var userID: String? // To hold the user ID for fetching the data
    var services: [(title: String, imageURL: String)] = [] // Array to hold "What I Offer" data

    override func viewDidLoad() {
        super.viewDidLoad()
        makeCircular(imgProfile) // Make the profile image circular
        
        fetchUserProfileData(userID: userID ?? "")
        
        // Set up collection view
        collectionViewWhatIOffer.delegate = self
        collectionViewWhatIOffer.dataSource = self
    }

    func fetchUserProfileData(userID: String) {
        let db = Firestore.firestore()
        
        // Fetch User Data from the "user" collection
        let userRef = db.collection("user").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    // Check and update UI elements with user data
                    if let fullName = data?["fullName"] as? String {
                        self.lblFullName.text = fullName
                    } else {
                        self.lblFullName.isHidden = true
                    }

                    if let username = data?["userName"] as? String {
                        self.lblUsername.text = username
                    } else {
                        self.lblUsername.isHidden = true
                    }
                    
                    // Load profile image asynchronously
                    if let imageUrl = data?["profilePicture"] as? String, let url = URL(string: imageUrl) {
                        Task {
                            if let image = await ImageDownloader.fetchImage(from: imageUrl) {
                                DispatchQueue.main.async {
                                    self.imgProfile.image = image
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.imgProfile.image = UIImage(named: "Person") // Placeholder if image fails to load
                                    self.imgProfile.isHidden = true
                                }
                            }
                        }
                    } else {
                        self.imgProfile.isHidden = true
                    }

                    if let bio = data?["bio"] as? String, !bio.isEmpty {
                        self.lblBio.text = bio
                    } else {
                        self.lblBio.isHidden = true
                    }
                    
                    // Update skills and interests if they exist
                    if let skills = data?["skills"] as? [String], !skills.isEmpty {
                        self.lblSkills.text = skills.joined(separator: ", ")
                    } else {
                        self.lblSkills.isHidden = true
                    }
                    
                    if let interests = data?["interests"] as? [String], !interests.isEmpty {
                        self.lblInterests.text = interests.joined(separator: ", ")
                    } else {
                        self.lblInterests.isHidden = true
                    }
                }
            }
        }
        
        // Fetch Rating and NumServices Data from the "ProviderDetails" collection
        let providerDetailsRef = db.collection("ProviderDetails").document(userID)
        providerDetailsRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting provider details document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    // Update skills from ProviderDetails
                    if let skills = data?["skills"] as? [String], !skills.isEmpty {
                        self.lblSkills.text = skills.joined(separator: ", ")
                    } else {
                        self.lblSkills.isHidden = true
                    }
                    
                    if let rating = data?["rating"] as? Double {
                        self.lblRating.text = "Rating: \(rating)"
                    } else {
                        self.lblRating.isHidden = true
                    }
                    
                    if let numServices = data?["numServices"] as? Int {
                        self.lblNumServices.text = "Services: \(numServices)"
                    } else {
                        self.lblNumServices.isHidden = true
                    }
                }
            }
        }
        
        // Fetch "What I Offer" Data from the "Service" collection
        let serviceRef = db.collection("Service").document(userID)
        serviceRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting service document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    let whatIOffer = data?["whatIOffer"] as? [[String: String]] ?? []
                    
                    self.services = whatIOffer.compactMap {
                        guard let title = $0["title"], let imageURL = $0["image"] else {
                            return nil
                        }
                        return (title, imageURL)
                    }
                    
                    // Reload collection view
                    DispatchQueue.main.async {
                        if self.services.isEmpty {
                            self.collectionViewWhatIOffer.isHidden = true
                        } else {
                            self.collectionViewWhatIOffer.reloadData()
                        }
                    }
                }
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
