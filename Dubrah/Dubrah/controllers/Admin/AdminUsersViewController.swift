import UIKit

class AdminUsersViewController: AdminBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let usersService = AdminUsersService()
     private let servicesService = AdminServicesService()
     
     private var users: [AppUser] = []
     private var services: [Service] = []
     
     private var currentSegment: Int = 0

     override func viewDidLoad() {
         super.viewDidLoad()

         setupNavigationTitle("Browse")
         setupNavigationAppearance()
         
         setupSegmentedControl()
         
         collectionView.delegate = self
         collectionView.dataSource = self

         loadData()
     }
     
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         showTabBar()
         loadData() // Reload when coming back
     }
     
     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         collectionView.collectionViewLayout.invalidateLayout()
     }
     
     private func setupSegmentedControl() {
         segmentedControl.removeAllSegments()
         segmentedControl.insertSegment(withTitle: "Users", at: 0, animated: false)
         segmentedControl.insertSegment(withTitle: "Services", at: 1, animated: false)
         segmentedControl.selectedSegmentIndex = 0
         
         if #available(iOS 13.0, *) {
             segmentedControl.selectedSegmentTintColor = UIColor(named: "PrimaryBlue")
         }
         segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
         segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
         
         segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
     }
     
     @objc func segmentChanged() {
         currentSegment = segmentedControl.selectedSegmentIndex
         collectionView.reloadData()
         
         if collectionView.numberOfItems(inSection: 0) > 0 {
             collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
         }
     }

     private func loadData() {
         loadUsers()
         loadServices()
     }
     
     private func loadUsers() {
         usersService.fetchUsers { [weak self] users in
             self?.users = users
             if self?.currentSegment == 0 {
                 self?.collectionView.reloadData()
             }
         }
     }
     
     private func loadServices() {
         servicesService.fetchServices { [weak self] services in
             self?.services = services
             if self?.currentSegment == 1 {
                 self?.collectionView.reloadData()
             }
         }
     }

     // MARK: - CollectionView DataSource

     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return currentSegment == 0 ? users.count : services.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         
         if currentSegment == 0 {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! UsersCollectionViewCell
             cell.setupCell(with: users[indexPath.item])
             return cell
             
         } else {
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCollectionViewCell
             cell.setupCell(with: services[indexPath.item])
             return cell
         }
     }
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

         if currentSegment == 0 {
             let user = users[indexPath.item]
             let vc = UIStoryboard(name: "Users", bundle: nil)
                 .instantiateViewController(withIdentifier: "AdminUserProfileViewController") as! AdminUserProfileViewController
             vc.userId = user.id
             navigationController?.pushViewController(vc, animated: true)
             
         } else {
             let service = services[indexPath.item]
             let vc = UIStoryboard(name: "Services", bundle: nil)
                 .instantiateViewController(withIdentifier: "ServiceDetailsViewController") as! AdminServiceDetailsViewController
             vc.service = service
             navigationController?.pushViewController(vc, animated: true)
         }
     }
     
     // MARK: - Layout
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

         let padding: CGFloat = 16
         let spacing: CGFloat = 12
         let totalHorizontal = padding + spacing

         let availableWidth = collectionView.bounds.width - totalHorizontal
         let cellWidth = availableWidth / 2

         return currentSegment == 0
             ? CGSize(width: cellWidth, height: 200)
             : CGSize(width: cellWidth, height: 250)
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return 12
     }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 12
     }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
     }
 }
