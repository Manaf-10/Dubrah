//
//  OrderHistoryCell.swift
//  Dubrah
//
//  Created by Ali on 29/12/2025.
//

import UIKit

final class OrderHistoryCell: UITableViewCell {

    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var starsStackView: UIStackView!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var orderAgainButton: UIButton!
    @IBOutlet weak var viewDetailsButton: UIButton!

    // ✅ Add a chat button outlet if you have it in storyboard
    @IBOutlet weak var chatButton: UIButton!

    // MARK: - Callback to VC
    var onChatTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        roundImage(serviceImage, radius: 8)
        styleOrderAgainButton()
    }

    func configure(_ order: Order) {
        ratingStackView.isHidden = true
        rateButton.isHidden = true
        rateButton.layer.cornerRadius = 8

        serviceName.text = order.serviceName
        priceLabel.text = order.subtotal
        orderDate.text = formattedDate(order.orderDate)

        applyStatusStyle(order.status)
        loadImage(from: order.serviceImageUrl)

        if order.status.lowercased() == "completed" {
            if order.serviceRating > 0 {
                ratingStackView.isHidden = false
                updateStars(order.serviceRating)
            } else {
                rateButton.isHidden = false
            }
        }
    }

    // ✅ This IBAction ONLY triggers the callback
    @IBAction func chatWithUserTapped(_ sender: UIButton) {
        onChatTapped?()
    }

    // MARK: - Status Logic
    private func applyStatusStyle(_ status: String) {
        let lower = status.lowercased()
        statusLabel.text = lower.capitalized

        statusContainer.layer.cornerRadius = 8
        statusContainer.clipsToBounds = true

        switch lower {
        case "pending":
            statusContainer.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
            statusLabel.textColor = .systemYellow
        case "accepted":
            statusContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
            statusLabel.textColor = .systemBlue
        case "rejected":
            statusContainer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            statusLabel.textColor = .systemRed
        case "completed":
            statusContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGreen
        default:
            statusContainer.backgroundColor = UIColor.systemGray5
            statusLabel.textColor = .darkGray
        }
    }

    // MARK: - UI Helpers
    private func styleOrderAgainButton() {
        orderAgainButton.backgroundColor = .clear
        orderAgainButton.setTitleColor(.systemGray, for: .normal)
        orderAgainButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        orderAgainButton.layer.cornerRadius = 8
        orderAgainButton.layer.borderWidth = 1
        orderAgainButton.layer.borderColor = UIColor.systemGray3.cgColor
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func updateStars(_ rating: Int) {
        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
            guard let imageView = view as? UIImageView else { continue }
            imageView.image = UIImage(named: index < rating ? "Filled_Star" : "Star")
        }
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            serviceImage.image = UIImage(systemName: "photo")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data else { return }
            DispatchQueue.main.async {
                self.serviceImage.image = UIImage(data: data)
            }
        }.resume()
    }
}
