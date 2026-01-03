import UIKit
import FirebaseFirestore

class ProviderReviwsTableViewCell: UITableViewCell {

    // Outlets for the cell components
    @IBOutlet weak var reviewerImage: UIImageView!
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet var stars: [UIImageView]!  // Array of ImageViews for the stars (1 to 5 stars)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeCircular(reviewerImage)
        reviewerImage.image = UIImage(systemName: "person.crop.circle") // Placeholder image for reviewer
    }

    // Function to configure the cell with review data
    func configure(with review: Review) {
        reviewText.text = review.content
        updateStars(review.rate)
        reviewDate.text = timeAgo(from: review.createdAt)

        reviewerName.text = "Loading..."  // Placeholder while fetching user name
        fetchUserName(userId: review.senderID)
    }

    // Fetch the reviewer name from Firestore using their user ID
    private func fetchUserName(userId: String) {
        guard !userId.isEmpty else {
            reviewerName.text = "Anonymous"
            return
        }

        let cleanId = userId.contains("/")
            ? userId.components(separatedBy: "/").last ?? userId
            : userId

        // Assuming you have a Firestore reference
        let db = Firestore.firestore()
        db.collection("user")
            .document(cleanId)
            .getDocument { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Failed to fetch user:", error.localizedDescription)
                    self.reviewerName.text = "User"
                    return
                }

                let name = snapshot?.data()?["fullName"] as? String
                self.reviewerName.text = name ?? "User"
            }
    }

    // Function to update the stars (e.g., if the rating is 4, show 4 filled stars and 1 empty star)
    private func updateStars(_ rating: Int) {
        for (index, starImageView) in stars.enumerated() {
            // Ensure the images "Filled_Star" and "Star" exist in your asset catalog
            starImageView.image = UIImage(
                named: index < rating ? "Filled_Star" : "Star"
            )
        }
    }

    // Function to format the time ago (e.g., "2 hours ago", "1 day ago")
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // Helper function to make the reviewer's image circular
    private func makeCircular(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }
}
