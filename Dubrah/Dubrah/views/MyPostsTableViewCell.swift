//
//  NewPostsTableViewCell.swift
//  Dubrah
//
//  Created by mohammed ali on 01/01/2026.
//

import UIKit

class MyPostsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var serviceImg: UIImageView!
    @IBOutlet weak var serviceTitle: UILabel!
    @IBOutlet weak var ratingImg: UIImageView!
    @IBOutlet weak var ratingNum: UILabel!
    @IBOutlet weak var serviceDesc: UILabel!
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(photoURL: String, title: String, desc: String, price: Double, rating: Double? = nil) {
        serviceTitle.text = title
        serviceDesc.text = desc
        servicePrice.text = "\(price) BD"
        
        if !photoURL.isEmpty {
            Task {
                if let downloadedImage = await ImageDownloader.fetchImage(from: photoURL){
                    await MainActor.run {
                        self.serviceImg?.image = downloadedImage
                    }
                } else {
                    await MainActor.run {
                        self.serviceImg?.image = UIImage(named: "fallback_servicePic_table")
                    }
                }
            }
        } else {
            self.serviceImg?.image = UIImage(named: "fallback_servicePic_table")
            print("Could not download image for \(title) service")
        }
        
        if let ratingnumber = rating {
            ratingNum.isHidden = false
            ratingImg.isHidden = false
            
            ratingNum.text = String(format: "%.1f", ratingnumber)
            ratingImg.image = UIImage(named: "Star")
        } else {
            ratingNum.isHidden = true
            ratingImg.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
