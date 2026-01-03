//
//  RequestsTableViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 23/12/2025.
//

import UIKit

class RequestsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgUserPhoto: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserRole: UILabel!
    @IBOutlet weak var btnViewRequest: UIButton!
    var onViewTapped: (() -> Void)?
      
      override func awakeFromNib() {
          super.awakeFromNib()
          
          // ✅ ADD THIS: Connect button action
          btnViewRequest.addTarget(self, action: #selector(viewButtonTapped), for: .touchUpInside)
      }
      
      // ✅ ADD THIS: Button action
      @objc private func viewButtonTapped() {
          onViewTapped?()
      }
      
      func setupCell(photoUrl: String?, name: String, role: String) {
          lblUsername.text = name
          lblUserRole.text = role

          guard let photoUrl else {
              imgUserPhoto.image = UIImage(named: "Log-Profile")
              return
          }

          Task {
              let image = await ImageDownloader.fetchImage(from: photoUrl)
              await MainActor.run {
                  self.imgUserPhoto.image = image ?? UIImage(named: "Log-Profile")
              }
          }
      }

      override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)
      }
  }
