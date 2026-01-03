//
//  ProductReviewsViewController.swift
//  Dubrah
//
//  Created by Ali on 25/12/2025.
//

import UIKit
import FirebaseFirestore

class ProductReviewsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
 
    var serviceId: String!
    var serviceName: String!
    
    private var reviews: [Review] = []
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        fetchReviews()
        setupNavigation(title: serviceName)
    }

    // MARK: - FETCH REVIEWS
    private func fetchReviews() {
        guard let serviceId else {
            print("❌ serviceId is nil")
            return
        }

        db.collection("Service")
            .document(serviceId)
            .getDocument { [weak self] snapshot, error in
                guard let self else { return }

                guard
                    let data = snapshot?.data(),
                    let reviewsArray = data["reviews"] as? [[String: Any]]
                else {
                    self.reviews = []
                    self.updateRatingSummary()
                    self.tableView.reloadData()
                    return
                }

                self.reviews = reviewsArray.compactMap {
                    Review(dictionary: $0)
                }

                DispatchQueue.main.async {
                    self.updateRatingSummary()
                    self.tableView.reloadData()
                }
            }
    }

    // MARK: - TABLE VIEW
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewCell",
            for: indexPath
        ) as! ReviewTableViewCell

        let review = reviews[indexPath.row]
        cell.configure(with: review)

        return cell
    }

    // MARK: - SUMMARY
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
}
