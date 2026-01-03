//
//  ReviewTableViewCell.swift
//  Dubrah
//
//  Created by Ali on 25/12/2025.
//

import UIKit
import FirebaseFirestore

class ReviewTableViewCell: UITableViewCell {
    

    @IBOutlet weak var reviewerImage: UIImageView!
    @IBOutlet weak var reviewerName: UILabel!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var reviewText: UILabel!
    @IBOutlet var stars: [UIImageView]!
    private let db = Firestore.firestore()

       override func awakeFromNib() {
           super.awakeFromNib()
           makeCircular(reviewerImage)
           reviewerImage.image = UIImage(systemName: "person.crop.circle")
       }

       func configure(with review: Review) {
           reviewText.text = review.content
           updateStars(review.rate)
           reviewDate.text = timeAgo(from: review.createdAt)

           reviewerName.text = "Loading..."

           fetchUserName(userId: review.senderID)
       }

       private func fetchUserName(userId: String) {
           guard !userId.isEmpty else {
               reviewerName.text = "Anonymous"
               return
           }

           let cleanId = userId.contains("/")
               ? userId.components(separatedBy: "/").last ?? userId
               : userId

           db.collection("user")
               .document(cleanId)
               .getDocument { [weak self] snapshot, error in
                   guard let self else { return }

                   if let error = error {
                       print("❌ Failed to fetch user:", error.localizedDescription)
                       self.reviewerName.text = "User"
                       return
                   }

                   let name = snapshot?.data()?["fullName"] as? String
                   self.reviewerName.text = name ?? "User"
               }
       }

       private func updateStars(_ rating: Int) {
           for (index, starImageView) in stars.enumerated() {
               starImageView.image = UIImage(
                   named: index < rating ? "Filled_Star" : "Star"
               )
           }
       }

       private func timeAgo(from date: Date) -> String {
           let formatter = RelativeDateTimeFormatter()
           formatter.unitsStyle = .short
           return formatter.localizedString(for: date, relativeTo: Date())
       }
   }
