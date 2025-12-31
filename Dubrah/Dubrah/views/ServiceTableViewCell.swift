//
//  ServiceTableViewCell.swift
//  Dubrah
//
//  Created by BP-19-131-07 on 31/12/2025.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {


    @IBOutlet weak var serviceImageView: UIImageView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    private func setupStyle() {
        selectionStyle = .none

        serviceImageView.layer.cornerRadius = 12
        serviceImageView.clipsToBounds = true
        serviceImageView.contentMode = .scaleAspectFill

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        ratingLabel.font = .systemFont(ofSize: 14, weight: .medium)
        ratingLabel.textColor = .systemOrange

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 2

        providerLabel.font = .systemFont(ofSize: 12)
        providerLabel.textColor = .gray

        priceLabel.font = .systemFont(ofSize: 16, weight: .bold)
        priceLabel.textColor = .systemGreen
    }

    func configure(with service: Service) {
        titleLabel.text = service.title
        ratingLabel.text = "⭐️ \(service.rating)"
        descriptionLabel.text = service.description
        providerLabel.text = "Provider: \(service.providerID)"
        priceLabel.text = "BHD \(service.price)"

        loadImage(from: service.image)
    }

    private func loadImage(from urlString: String) {
        serviceImageView.image = UIImage(systemName: "photo") // placeholder

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.serviceImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
