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
            // ensure correct circle after autolayout
            imgReporterAvatar.layer.cornerRadius = imgReporterAvatar.frame.width / 2
        }
    
    func setupCell(report: Report) {
           imgReporterAvatar.image = report.avatar
           reporterUsername.text = report.username
           reporterEmail.text = report.email
           typeButton.setTitle(report.type, for: .normal)
           titleLabel.text = report.title
           descriptionLabel.text = report.description
           reportedUser.text = "Reported user: \(report.reportedUser)"
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func viewTapped() {
            onViewTapped?()
        }

}
