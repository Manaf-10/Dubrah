//
//  NotificationCell.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 14/12/2025.
//
import UIKit

class NotificationCell: UITableViewCell{
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationImage: UIImageView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }
        
        private func setupUI() {
            notificationImage.layer.cornerRadius = notificationImage.frame.height / 2
            notificationImage.clipsToBounds = true
            notificationImage.contentMode = .scaleAspectFill
            notificationImage.backgroundColor = .systemGray6
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            notificationLabel.text = nil
            notificationImage.image = UIImage(systemName: "person.circle.fill")
        }
        
        func configure(with notification: Notification) {
            notificationLabel.text = notification.content
            
            if let imageUrl = notification.senderImage, !imageUrl.isEmpty {
                Task {
                    let image = await ImageDownloader.fetchImage(from: imageUrl)
                    
                    await MainActor.run {
                        self.notificationImage.image = image ?? UIImage(systemName: "person.circle.fill")
                    }
                }
            } else {
                notificationImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
}
