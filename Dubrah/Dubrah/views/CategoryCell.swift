//
//  CategoryCell.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 18/12/2025.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!

    weak var delegate: CategoryCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    private func setupStyle() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor(hex: "#FFFFFF")

        iconLabel.textAlignment = .center
        iconLabel.numberOfLines = 1
    }

    func configure(with systemImageName: String) {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "folder")
        attachment.bounds = CGRect(x: 0, y: -4, width: 60, height: 55)

        iconLabel.attributedText =
            NSMutableAttributedString(attachment: attachment)
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        delegate?.didTapEdit(on: self)
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        delegate?.didTapDelete(on: self)
    }
}

    
    protocol CategoryCellDelegate: AnyObject {
        func didTapEdit(on cell: CategoryCell)
        func didTapDelete(on cell: CategoryCell)
    }


