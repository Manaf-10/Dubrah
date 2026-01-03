//
//  ServiceTableViewCell.swift
//  Dubrah
//
//  Created by BP-19-131-07 on 31/12/2025.
//

import UIKit

final class ServiceTableViewCell: UITableViewCell {

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
    }

    func configure(with service: Service) {
        titleLabel.text = service.title
        descriptionLabel.text = service.description
        providerLabel.text = "Provider: \(service.providerID)"
        priceLabel.text = "BHD \(service.price)"

        let avg = service.averageRating
        ratingLabel.text = avg == 0 ? "No rating" : String(format: "⭐️ %.1f", avg)

        loadImage(from: service.image)
    }

    private func loadImage(from urlString: String) {
        serviceImageView.image = UIImage(systemName: "photo")
        guard let url = URL(string: urlString), !urlString.isEmpty else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data else { return }
            DispatchQueue.main.async {
                self?.serviceImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}

