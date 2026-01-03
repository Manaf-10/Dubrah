//
//  RequestTableViewCell.swift
//  Dubrah
//
//  Created by mohammed ali on 02/01/2026.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    private var currentStatus: String = ""
    
    var onLeftButtonTapped: (() -> Void)?
    var onRightButtonTapped: (() -> Void)?
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        selectionStyle = .none
    }
    
    private func setupUI() {
           // Style profile image
           profilePic.layer.cornerRadius = 25
           profilePic.clipsToBounds = true
           profilePic.contentMode = .scaleAspectFill
           
           // Style buttons
           leftButton.layer.cornerRadius = 8
           rightButton.layer.cornerRadius = 8
       }
    
    func configure(with order: Order, userData: UserData?, viewMode: String) {
            currentStatus = order.status
            
            // Set user data
            username.text = userData?.fullName ?? "Unknown User"
            
            // Load profile picture
            if let urlString = userData?.profilePicture,
               !urlString.isEmpty,
               let url = URL(string: urlString) {
                loadImage(from: url)
            } else {
                profilePic.image = UIImage(systemName: "person.circle.fill")
                profilePic.tintColor = .systemGray
            }
            
            // Set order details
            serviceLabel.text = order.serviceName
            dateLabel.text = formatDate(order.orderDate)
            timeAgoLabel.text = timeAgo(from: order.orderDate)
            priceLabel.text = order.subtotal
            
            // Payment methods (join array with commas)
            paymentMethodLabel.text = order.paymentMethod
            
            // Status
            statusLabel.text = order.status.capitalized
            configureStatusColor()
            
            // Configure buttons based on view mode and status
            if viewMode == "Completed" || viewMode == "MyBooking" {
                // Completed view - hide all buttons
                buttonsStackView.isHidden = true
            } else {
                // Incoming view - show buttons based on status
                switch order.status.lowercased() {
                case "pending":
                    configurePendingButtons()
                    buttonsStackView.isHidden = false
                case "accepted":
                    configureAcceptedButtons()
                    buttonsStackView.isHidden = false
                default:
                    buttonsStackView.isHidden = true
                }
            }
        }
        
        private func configureStatusColor() {
            switch currentStatus.lowercased() {
            case "pending":
                statusLabel.textColor = .systemOrange
            case "accepted":
                statusLabel.textColor = .systemGreen
            case "completed":
                statusLabel.textColor = .systemBlue
            case "rejected":
                statusLabel.textColor = .systemRed
            default:
                statusLabel.textColor = .systemGray
            }
        }
        
    private func configurePendingButtons() {
        // ⭐ Use modern UIButton.Configuration
        var acceptConfig = UIButton.Configuration.filled()
        acceptConfig.title = "Accept"
        acceptConfig.baseBackgroundColor = UIColor(named: "Primary_btn_color") ?? .systemBlue
        acceptConfig.baseForegroundColor = .white
        acceptConfig.cornerStyle = .medium
        acceptConfig.image = nil
        leftButton.configuration = acceptConfig
        
        // ⭐ Set size constraints for Accept button
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftButton.widthAnchor.constraint(equalToConstant: 83),
            leftButton.heightAnchor.constraint(equalToConstant: 29)
        ])
        
        var rejectConfig = UIButton.Configuration.plain()
        rejectConfig.title = "Reject"
        rejectConfig.baseBackgroundColor = .clear
        rejectConfig.baseForegroundColor = UIColor(named: "Primary_btn_color") ?? .systemRed
        rejectConfig.cornerStyle = .medium
        rejectConfig.background.strokeColor = UIColor(named: "Primary_btn_color") ?? .systemRed
        rejectConfig.background.strokeWidth = 2.0
        rejectConfig.image = nil
        rightButton.configuration = rejectConfig
        
        // ⭐ Set size constraints for Reject button
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightButton.widthAnchor.constraint(equalToConstant: 83),
            rightButton.heightAnchor.constraint(equalToConstant: 29)
        ])
    }

    private func configureAcceptedButtons() {
        // ⭐ Chat button with icon
        var chatConfig = UIButton.Configuration.filled()
        chatConfig.image = UIImage(named: "message_icon")
        chatConfig.title = nil
        chatConfig.baseBackgroundColor = UIColor(named: "Primary_btn_color")
        chatConfig.baseForegroundColor = .white
        chatConfig.cornerStyle = .medium
        leftButton.configuration = chatConfig
        
        // ⭐ Set size for Chat button
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftButton.widthAnchor.constraint(equalToConstant: 39),
            leftButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // ⭐ Complete button
        var completeConfig = UIButton.Configuration.filled()
        completeConfig.title = "Complete"
        completeConfig.baseBackgroundColor = UIColor(named: "Primary_btn_color")
        completeConfig.baseForegroundColor = .white
        completeConfig.cornerStyle = .medium
        completeConfig.image = nil
        rightButton.configuration = completeConfig
        
        // ⭐ Set size for Complete button
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightButton.widthAnchor.constraint(equalToConstant: 100),
            rightButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // ⭐ Remove all constraints
        leftButton.removeConstraints(leftButton.constraints)
        rightButton.removeConstraints(rightButton.constraints)
        leftButton.translatesAutoresizingMaskIntoConstraints = true
        rightButton.translatesAutoresizingMaskIntoConstraints = true
        
        // Reset configurations
        leftButton.configuration = nil
        rightButton.configuration = nil
    }
        private func loadImage(from url: URL) {
            profilePic.image = UIImage(systemName: "person.circle.fill")
               
               URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                   guard let data = data, let image = UIImage(data: data) else { return }
                   
                   DispatchQueue.main.async {
                       self?.profilePic.image = image
                   }
               }.resume()
        }
        
        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy - hh:mm a"
            return formatter.string(from: date)
        }
    private func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years)y ago"
        } else if let months = components.month, months > 0 {
            return "\(months)mo ago"
        } else if let days = components.day, days > 0 {
            return "\(days)d ago"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h ago"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m ago"
        } else if let seconds = components.second, seconds > 0 {
            return "\(seconds)s ago"
        } else {
            return "Just now"
        }
    }
    
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        onLeftButtonTapped?()
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        onRightButtonTapped?()
    }
    
}
