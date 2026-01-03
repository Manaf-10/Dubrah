//
//  ServicesViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

class AdminServicesViewController: AdminBaseViewController, UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
        private var services: [Service] = Service.mock

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationTitle("Services")
        setupNavigationAppearance()
        collectionView.delegate = self
                collectionView.dataSource = self


    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
//           setTabBarHidden(false)
        showTabBar()

       }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            // Ensure tab bar is visible
            showTabBar()
        }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            services.count
        }

        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ServiceCell",
                for: indexPath
            ) as! ServiceCollectionViewCell

            cell.setupCell(with: services[indexPath.item])
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {

            let padding: CGFloat = 16
            let spacing: CGFloat = 12
            let totalSpacing = padding * 2 + spacing

            let width = (collectionView.bounds.width - totalSpacing) / 2
            return CGSize(width: width, height: 230)
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            12
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            12
        }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let service = services[indexPath.item]

        let vc = UIStoryboard(name: "Services", bundle: nil)
            .instantiateViewController(withIdentifier: "ServiceDetailsViewController")
            as! AdminServiceDetailsViewController

        vc.service = service   // 👈 pass data

        navigationController?.pushViewController(vc, animated: true)
    }
    }
