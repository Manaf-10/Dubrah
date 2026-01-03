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
    private let service = AdminServicesService()
       private var services: [Service] = []

       override func viewDidLoad() {
           super.viewDidLoad()
           
           setupNavigationTitle("Services")
           setupNavigationAppearance()
           
           collectionView.delegate = self
           collectionView.dataSource = self
           
           loadServices()
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           showTabBar()
           
           // Reload in case service was deleted
           loadServices()
       }
       
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           showTabBar()
       }
       
       private func loadServices() {
           print("📥 Fetching services...")
           
           service.fetchServices { [weak self] services in
               print("✅ Loaded \(services.count) services")
               self?.services = services
               self?.collectionView.reloadData()
           }
       }
       
       // MARK: - CollectionView DataSource
       
       func collectionView(_ collectionView: UICollectionView,
                           numberOfItemsInSection section: Int) -> Int {
           return services.count
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
                           didSelectItemAt indexPath: IndexPath) {

           let service = services[indexPath.item]
           openServiceDetails(service)
       }
       
       private func openServiceDetails(_ service: Service) {
           let vc = UIStoryboard(name: "Services", bundle: nil)
               .instantiateViewController(withIdentifier: "ServiceDetailsViewController")
               as! AdminServiceDetailsViewController

           vc.service = service
           navigationController?.pushViewController(vc, animated: true)
       }
       
       // MARK: - Layout
       
       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {

           let padding: CGFloat = 16
           let spacing: CGFloat = 12
           let totalSpacing = padding * 2 + spacing

           let width = (collectionView.bounds.width - totalSpacing) / 2
           return CGSize(width: width, height: 250)
       }

       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumLineSpacingForSectionAt section: Int) -> CGFloat {
           return 12
       }

       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
           return 12
       }

       func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
       }
   }
