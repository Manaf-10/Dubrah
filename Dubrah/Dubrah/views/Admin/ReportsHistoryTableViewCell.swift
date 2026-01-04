//
//  ReportsHistoryTableViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 04/01/2026.
//

import UIKit

class ReportHistoryCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
    }
    
    func setupCell(report: Report) {
        titleLabel.text = report.title
        typeLabel.text = "\(report.reportType.capitalized) Report"
        
        // Status with color
        statusLabel.text = report.status.capitalized
        statusLabel.textColor = report.status == "resolved" ? .systemGreen : .systemOrange
        
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = formatter.string(from: report.createdAt)
        
        // Avatar
        if let avatarUrl = report.reporterAvatar {
            avatarImageView.loadFromUrl(avatarUrl)
        } else {
            avatarImageView.image = UIImage(named: "Log-Profile")
        }
    }
}
