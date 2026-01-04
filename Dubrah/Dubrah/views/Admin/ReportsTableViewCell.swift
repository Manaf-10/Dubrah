//
//  ReportsTableViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit


class ReportsTableViewCell: UITableViewCell {

    @IBOutlet weak var imgReporterAvatar: UIImageView!
    @IBOutlet weak var reporterUsername: UILabel!
    @IBOutlet weak var reporterEmail: UILabel!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reportedUser: UILabel!
    @IBOutlet weak var viewButton: UIButton!
    
    var onViewTapped: (() -> Void)?

     override func awakeFromNib() {
         super.awakeFromNib()
         setupUI()
         
         viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
     }

     private func setupUI() {
         // Avatar circle
         imgReporterAvatar.clipsToBounds = true
         imgReporterAvatar.contentMode = .scaleAspectFill

         // Type pill (display-only)
         typeButton.isUserInteractionEnabled = false
         typeButton.layer.cornerRadius = 9
         typeButton.layer.borderWidth = 1
         typeButton.layer.borderColor = UIColor(named: "PrimaryBlue")?.cgColor
         typeButton.setTitleColor(UIColor(named: "PrimaryBlue"), for: .normal)
         typeButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)

         // Description multiline
         descriptionLabel.numberOfLines = 2
     }
     
     override func layoutSubviews() {
         super.layoutSubviews()
         // Ensure correct circle after autolayout
         imgReporterAvatar.layer.cornerRadius = imgReporterAvatar.frame.width / 2
     }
     
     func setupCell(report: Report) {
         // Reporter info
         reporterUsername.text = report.reporterName ?? "Unknown User"
         reporterEmail.text = report.reporterEmail ?? "No email"
         
         // Type (capitalize: "service" → "Service")
         typeButton.setTitle(report.reportType.capitalized, for: .normal)
         
         // Report details
         titleLabel.text = report.title
         descriptionLabel.text = report.description
         
         // Reported user
         let reportedUserName = report.reportedUserName ?? "Unknown"
         reportedUser.text = "Reported user: \(reportedUserName)"
         
         // Load avatar from URL
         if let avatarUrl = report.reporterAvatar {
             imgReporterAvatar.loadFromUrl(avatarUrl)
         } else {
             imgReporterAvatar.image = UIImage(named: "Log-Profile")
         }
     }

     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)
     }
     
     @objc private func viewTapped() {
         onViewTapped?()
     }
 }
