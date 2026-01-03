//
//  UIImageView+Load.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

extension UIImageView {
    
    func loadFromUrl(_ urlString: String, placeholder: UIImage? = UIImage(named: "Log-Profile")) {
        // Set placeholder immediately
        self.image = placeholder
        
        // Load image asynchronously
        Task {
            guard let url = URL(string: urlString) else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.image = image
                    }
                }
            } catch {
                print("❌ Error loading image: \(error)")
            }
        }
    }
}
