//
//  ImageDownloader.swift
//  Dubrah
//
//  Created by Sayed on 22/12/2025.
//

import UIKit

class ImageDownloader {
    
    static func fetchImage(from urlString: String) async -> UIImage? {
            guard let url = URL(string: urlString) else { return nil }
            
            do {
                // 1. Download data from the URL
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // 2. Convert to UIImage and return it
                return UIImage(data: data)
            } catch {
                print("❌ Error downloading image: \(error.localizedDescription)")
                return nil
            }
        }
}
