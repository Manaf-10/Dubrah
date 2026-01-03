//
//  ServiceDetailsViewController.swift
//  Dubrah
//
//  Created by Ali on 02/01/2026.
//

import UIKit
import FirebaseFirestore
import Firebase

class ServiceDetailsViewController: UIViewController {

    var serviceId: String! 
    private var service: Service?
    private var providerRating: Double = 0
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var providerRatingLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var viewProfileButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var serviceDescription: UILabel!
    @IBOutlet weak var allReviewsButton: UIButton!
    
    @IBOutlet weak var providerImage: UIImageView!
    @IBOutlet weak var reviewerProfileImage: UIImageView!
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewTime: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    
    @IBOutlet weak var bookNowButton: UIButton!

    @IBOutlet weak var serviceImage: UIImageView!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    var providerId: String!
    var serviceImageUrl: String?
    
    override func viewDidLoad() {
            super.viewDidLoad()
            configureUI()
            fetchService()
        }

        // MARK: - UI Setup
        private func configureUI() {
            serviceDescription.numberOfLines = 0
            reviewText.numberOfLines = 0
            providerImage.layer.cornerRadius = providerImage.frame.height / 2
            providerImage.clipsToBounds = true
        }

    private func fetchService() {
        Task {
            do {
                guard let service = try await ServiceController.shared
                    .getServiceDetails(id: serviceId) else { return }

                self.service = service
                self.providerId = service.providerID
                self.serviceImageUrl = service.image

                let providerData = try await fetchUser(userId: service.providerID)
                providerNameLabel.text = providerData["fullName"] as? String ?? "Provider"

                if let imageURL = providerData["profilePicture"] as? String {
                    loadImage(from: imageURL, into: providerImage)
                }

                providerRating = try await fetchProviderRating(providerId: service.providerID)

                await MainActor.run {
                    updateUI()
                }

            } catch {
                print("❌ Failed to load service details:", error)
            }
        }
    }


        // MARK: - Update UI
        private func updateUI() {
            guard let service = service else { return }

            serviceNameLabel.text = service.title
            serviceDescription.text = service.description
            durationLabel.text = formattedDuration(hours: service.duration)
            priceLabel.text = "\(service.price) BHD"

            loadImage(from: service.image, into: serviceImage)


            let attributed = NSMutableAttributedString(string: (providerNameLabel.text ?? "") + " ")
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "verified")
            attributed.append(NSAttributedString(attachment: attachment))
            providerNameLabel.attributedText = attributed

            providerRatingLabel.text = String(format: "%.1f", providerRating)

            if let topReview = getTopReview(from: service.reviews) {

                reviewText.text = topReview.content
                reviewTime.text = timeAgo(from: topReview.createdAt)
                updateStars(rating: topReview.rate)

                reviewerName.text = "Loading..."
                fetchReviewerName(userId: topReview.senderID)

            } else {
                reviewerName.text = "No reviews yet"
                reviewText.text = ""
                reviewTime.text = ""
                updateStars(rating: 0)
            }

        }

    private func formattedDuration(hours: Int) -> String {
        if hours < 24 {
            return "\(hours) Hours"
        } else {
            let days = Int(ceil(Double(hours) / 24.0))
            return days == 1 ? "1 Day" : "\(days) Days"
        }
    }

        // MARK: - Stars
        private func updateStars(rating: Int) {
            let stars = [star1, star2, star3, star4, star5]
            for (index, star) in stars.enumerated() {
                star?.image = UIImage(named: index < rating ? "Filled_Star" : "Star")
            }
        }

        // MARK: - Helpers
        private func loadImage(from urlString: String, into imageView: UIImageView) {
            guard let url = URL(string: urlString) else { return }

            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            imageView.image = image
                        }
                    }
                } catch {
                    print("❌ Image load failed:", error)
                }
            }
        }

        private func fetchUser(userId: String) async throws -> [String: Any] {
            let cleanId = userId.contains("/")
                ? userId.components(separatedBy: "/").last ?? ""
                : userId

            let doc = try await Firestore.firestore()
                .collection("user")
                .document(cleanId)
                .getDocument()

            return doc.data() ?? [:]
        }

        private func fetchProviderRating(providerId: String) async throws -> Double {
            let snapshot = try await Firestore.firestore()
                .collection("ProviderDetails")
                .whereField("userID", isEqualTo: providerId)
                .getDocuments()

            let data = snapshot.documents.first?.data() ?? [:]
            return data["averageRating"] as? Double ?? 0
        }

        // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // ===============================
        // PAYMENT FLOW
        // ===============================
        if segue.identifier == "toPayment",
           let destination = segue.destination as? PaymentViewController,
           let service = service {

            destination.serviceTitleText = service.title
            destination.providerNameAttributed = providerNameLabel.attributedText
            destination.priceText = "\(service.price) BHD"

            destination.serviceId = service.id
            destination.providerId = service.providerID

            destination.serviceImage = serviceImage.image
            destination.providerImage = providerImage.image
            destination.serviceImageUrl = serviceImageUrl

            destination.availablePaymentMethods = service.paymentMethods
        }

        // ===============================
        // VIEW REVIEWS
        // ===============================
        if segue.identifier == "toProductReviews",
           let destination = segue.destination as? ProductReviewsViewController,
           let service = service {

            destination.serviceId = service.id
        }
    }

    private func getTopReview(from reviews: [Review]) -> Review? {
        return reviews
            .sorted {
                if $0.rate == $1.rate {
                    return $0.createdAt > $1.createdAt
                }
                return $0.rate > $1.rate
            }
            .first
    }
    
    private func fetchReviewerName(userId: String) {
        guard !userId.isEmpty else {
            reviewerName.text = "Anonymous"
            return
        }

        let cleanId = userId.contains("/")
            ? userId.components(separatedBy: "/").last ?? userId
            : userId

        Firestore.firestore()
            .collection("user")
            .document(cleanId)
            .getDocument { [weak self] snapshot, _ in
                let name = snapshot?.data()?["fullName"] as? String
                self?.reviewerName.text = name ?? "User"
            }
    }

    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }


    @IBAction func bookNowTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toPayment", sender: self)
    }
    
    @IBAction func allReviewsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toProductReviews", sender: self)
    }

    

}

