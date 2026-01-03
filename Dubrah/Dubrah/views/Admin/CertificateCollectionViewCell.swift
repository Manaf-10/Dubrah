//
//  CertificateCollectionViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

class CertificateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCertificate: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgCertificate.contentMode = .scaleAspectFill
        imgCertificate.clipsToBounds = true
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 14
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor(named: "PrimaryBlue")?.cgColor
    }

    func setup(with cert: Certificate) {
        imgCertificate.image = cert.image
    }
}
