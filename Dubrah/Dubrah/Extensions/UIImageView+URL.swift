//
//  UIImageView+URL.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

import UIKit

extension UIImageView {

    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        image = placeholder

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard
                let self = self,
                let data = data,
                let image = UIImage(data: data)
            else {
                return
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
