//
//  Untitled.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 18/12/2025.
//

import UIKit

class CategoriesViewController: BaseViewController,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }
    }


    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryCell",
            for: indexPath
        ) as! CategoryCell
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 2
        let spacing: CGFloat = 12
        let inset: CGFloat = 16

        let totalSpacing = (columns - 1) * spacing + inset * 2
        let width = (collectionView.bounds.width - totalSpacing) / columns
        collectionView.backgroundColor = UIColor(hex: "#F6F8F9")
        return CGSize(width: width, height: 140) 
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }


}

