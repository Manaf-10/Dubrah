import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ProviderReviwsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlets connected to the storyboard elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var averageRating: UILabel!
    @IBOutlet weak var totalReviews: UILabel!
    @IBOutlet weak var star5Progress: UIProgressView!
    @IBOutlet weak var star4Progress: UIProgressView!
    @IBOutlet weak var star3Progress: UIProgressView!
    @IBOutlet weak var star2Progress: UIProgressView!
    @IBOutlet weak var star1Progress: UIProgressView!
    @IBOutlet weak var star5Count: UILabel!
    @IBOutlet weak var star4Count: UILabel!
    @IBOutlet weak var star3Count: UILabel!
    @IBOutlet weak var star2Count: UILabel!
    @IBOutlet weak var star1Count: UILabel!

    var userId: String?  // The current logged-in user's ID
    private var reviews: [Review] = [] // Array to hold review data
    private let db = Firestore.firestore() // Firestore instance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if the user is logged in and proceed
        checkUserAuthentication()

        // Set table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self

        // Set estimated row height for the table
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }

    // MARK: - Check User Authentication
    func checkUserAuthentication() {
        if let user = Auth.auth().currentUser {
            // User is logged in, proceed with fetching provider details
            self.userId = user.uid
            fetchProviderDetails()
        } else {
            // No user is logged in, handle this case (show login screen)
            print("User is not logged in.")
        }
    }

    // MARK: - Fetch Provider Details
    private func fetchProviderDetails() {
        guard let userId = self.userId else {
            print("❌ userId is nil")
            return
        }

        // Fetch provider details from Firestore using the userId
        db.collection("ProviderDetails")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching provider details: \(error)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No provider details found for this user")
                    return
                }

                let data = document.data()
                print("Fetched Provider Details Data: \(data)")  // Debugging statement

                // Update UI with the provider details
                self.updateProviderDetailsUI(data)
            }
    }

    // MARK: - Update UI with Provider Details
    private func updateProviderDetailsUI(_ data: [String: Any]) {
        // Check and update the average rating if available
        if let averageRatingValue = data["averageRating"] as? Double {
            self.averageRating.text = String(format: "%.1f", averageRatingValue)
        } else {
            self.averageRating.isHidden = true  // Hide if no averageRating
        }

        // Check and update reviews count and reviews list
        if let reviewsArray = data["reviews"] as? [[String: Any]] {
            self.reviews = reviewsArray.compactMap { Review(dictionary: $0) }
            self.totalReviews.text = "\(self.reviews.count) Reviews"
            self.updateRatingSummary()
        } else {
            self.reviews = []
            self.totalReviews.isHidden = true  // Hide if no reviews
            self.updateRatingSummary()
        }

        // After updating UI, reload the table view to reflect the changes
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Update Rating Summary
    private func updateRatingSummary() {
        let total = reviews.count
        guard total > 0 else {
            averageRating.text = "0.0"
            totalReviews.text = "0 Reviews"
            [star1Progress, star2Progress, star3Progress, star4Progress, star5Progress]
                .forEach { $0?.progress = 0 }
            [star1Count, star2Count, star3Count, star4Count, star5Count]
                .forEach { $0?.text = "0" }
            return
        }

        let counts = (1...5).map { rating in
            reviews.filter { $0.rate == rating }.count
        }

        let average = Double(reviews.map { $0.rate }.reduce(0, +)) / Double(total)

        averageRating.text = String(format: "%.1f", average)
        totalReviews.text = "\(total) Reviews"

        star1Progress.progress = Float(counts[0]) / Float(total)
        star2Progress.progress = Float(counts[1]) / Float(total)
        star3Progress.progress = Float(counts[2]) / Float(total)
        star4Progress.progress = Float(counts[3]) / Float(total)
        star5Progress.progress = Float(counts[4]) / Float(total)

        star1Count.text = "\(counts[0])"
        star2Count.text = "\(counts[1])"
        star3Count.text = "\(counts[2])"
        star4Count.text = "\(counts[3])"
        star5Count.text = "\(counts[4])"
    }

    // MARK: - Table View Data Source & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ProviderReviwsTableViewCell
        let review = reviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
}
