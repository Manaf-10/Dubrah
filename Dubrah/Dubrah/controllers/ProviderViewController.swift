//
//  ProviderViewController.swift
//  Dubrah
//
//  Created by mohammed ali on 23/12/2025.
//

import UIKit
import FirebaseAuth

struct UserData {
    let fullName: String
    let profilePicture: String
}
class ProviderViewController: UIViewController {
    // Mark: - Outlets
    @IBOutlet weak var myBookingCollectionView: UICollectionView!
    @IBOutlet weak var IncomingRequestCollectionView: UICollectionView!
    @IBOutlet weak var CompletedRequestsCollectionView: UICollectionView!
    @IBOutlet weak var addNewPostBTN: UIButton!
        
    
    @IBOutlet weak var myPosts: UIStackView!
    @IBOutlet weak var incoming: UIStackView!
    @IBOutlet weak var completed: UIStackView!
    
    var myBookings: [Order] = []
    var completedBookings: [Order] = []
    var incomingRequests: [Order] = []
    var allIncomingRequests: [Order] = []
    
    private var userDataCache: [String: UserData] = [:]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadAllData()
        checkProviderStatusAndSetupUI()
    }
    
    private func checkProviderStatusAndSetupUI() {
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                print("No user logged in")
                hideProviderElements()
                return
            }
            
            Task {
                do {
                    let isProvider = try await isUserProvider(userID: currentUserID)
                    print("is prvider: \(isProvider)")
                    await MainActor.run {
                        if isProvider {
                            // User is a provider - show all elements
                            showProviderElements()
                            loadAllData()
                        } else {
                            // User is NOT a provider - hide provider-specific elements
                            hideProviderElements()
                        }
                    }
                } catch {
                    print("Error checking provider status: \(error)")
                    await MainActor.run {
                        hideProviderElements()
                    }
                }
            }
        }
    
    private func showProviderElements() {
         myPosts.isHidden = false
         incoming.isHidden = false
         completed.isHidden = false
         addNewPostBTN.isHidden = false
         
         myBookingCollectionView.isHidden = false
         IncomingRequestCollectionView.isHidden = false
         CompletedRequestsCollectionView.isHidden = false
         
         print("✅ Provider dashboard visible")
     }
     
     private func hideProviderElements() {
         myPosts.isHidden = true
         incoming.isHidden = true
         completed.isHidden = true
         addNewPostBTN.isHidden = true
         
         myBookingCollectionView.isHidden = false
         IncomingRequestCollectionView.isHidden = true
         CompletedRequestsCollectionView.isHidden = true
         
         print("❌ Provider dashboard hidden")
     }
    
    func isUserProvider(userID: String) async throws -> Bool {
        let document = try await db.collection("user").document(userID).getDocument()
        
        guard let data = document.data(),
              let role = data["role"] as? String else {
            return false
        }
        // Note: Use .trimmingCharacters because your screenshot shows "provider " with a space
        return role.trimmingCharacters(in: .whitespaces) == "provider"
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        addNewPostBTN.layer.cornerRadius = 18
    }
    
    private func setupCollectionViews() {
        // My Bookings Collection View
        myBookingCollectionView.delegate = self
        myBookingCollectionView.dataSource = self
        myBookingCollectionView.tag = 0
        
        // Incoming Requests Collection View
        IncomingRequestCollectionView.delegate = self
        IncomingRequestCollectionView.dataSource = self
        IncomingRequestCollectionView.tag = 1
        
        // Completed Collection View
        CompletedRequestsCollectionView.delegate = self
        CompletedRequestsCollectionView.dataSource = self
        CompletedRequestsCollectionView.tag = 2
    }
    
   
    // MARK: - Load Data from Firebase
        private func loadAllData() {
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                print("No user logged in")
                return
            }
            
            // Load all three collections
            loadMyBookings(userID: currentUserID)
            loadIncomingRequests(providerID: currentUserID)
            loadCompletedBookings(providerID: currentUserID)
        }
        
        private func loadMyBookings(userID: String) {
            Task {
                do {
                       let orders = try await OrderController.shared.getOrdersByUser(userID: userID)
                       
                       // ⭐ Fetch all provider data at once
                       let providerIDs = orders.map { $0.providerID }
                       let providerData = try await fetchUserData(userIDs: providerIDs)
                       
                       await MainActor.run {
                           self.myBookings = orders
                           self.userDataCache.merge(providerData) { _, new in new }
                           self.myBookingCollectionView.reloadData()
                           self.updateEmptyState(for: self.myBookingCollectionView, message: "No bookings yet")
                       }
                   } catch {
                       print("Error loading my bookings: \(error.localizedDescription)")
                   }
            }
        }
        
    private func loadIncomingRequests(providerID: String) {
        Task {
              do {
                  // Get Pending orders
                  let pendingOrders = try await OrderController.shared.getOrdersByStatus(
                      providerID: providerID,
                      status: "pending"
                  )
                  
                  let acceptedOrders = try await OrderController.shared.getOrdersByStatus(
                      providerID: providerID,
                      status: "accepted"
                  )
                  
                  let allOrders = pendingOrders + acceptedOrders
                  
                  let sortedAllOrders = allOrders.sorted {
                      if $0.status == $1.status {
                          return $0.orderDate < $1.orderDate  // Then oldest first within same status
                      }
                      return $0.status.lowercased() == "pending"  // Pending before Accepted
                  }
                  
                  // Fetch all user data
                  let userIDs = sortedAllOrders.map { $0.userID }
                  let userData = try await fetchUserData(userIDs: userIDs)
                  
                  await MainActor.run {
                      self.incomingRequests = pendingOrders
                      self.allIncomingRequests = sortedAllOrders
                      self.userDataCache.merge(userData) { _, new in new }
                      self.IncomingRequestCollectionView.reloadData()
                      self.updateEmptyState(for: self.IncomingRequestCollectionView, message: "No incoming requests")
                  }
              } catch {
                  print("Error loading incoming requests: \(error.localizedDescription)")
              }
          }
    }
        private func loadCompletedBookings(providerID: String) {
            Task {
                do {
                      let orders = try await OrderController.shared.getOrdersByStatus(
                          providerID: providerID,
                          status: "completed"
                      )
                      
                      // ⭐ Fetch all user data at once
                      let userIDs = orders.map { $0.userID }
                      let userData = try await fetchUserData(userIDs: userIDs)
                      
                      await MainActor.run {
                          self.completedBookings = orders
                          self.userDataCache.merge(userData) { _, new in new }
                          self.CompletedRequestsCollectionView.reloadData()
                          self.updateEmptyState(for: self.CompletedRequestsCollectionView, message: "No completed bookings")
                      }
                  } catch {
                      print("Error loading completed bookings: \(error.localizedDescription)")
                  }
            }
        }
     private func fetchUserData(userIDs: [String]) async throws -> [String: UserData] {
        var usersData: [String: UserData] = [:]
        
        for userID in userIDs {
            if userID.isEmpty { continue }
            
            if let userData = try? await OrderController.shared.getUserData(userID: userID) {
                usersData[userID] = userData
            } else {
                print("Failed to fetch user data, using default")
                usersData[userID] = UserData(fullName: "Unknown User", profilePicture: "")
            }
        }
        
        return usersData
    }
    private func updateEmptyState(for collectionView: UICollectionView, message: String) {
        let isEmpty: Bool
            
            switch collectionView.tag {
            case 0: isEmpty = myBookings.isEmpty
            case 1: isEmpty = incomingRequests.isEmpty
            case 2: isEmpty = completedBookings.isEmpty
            default: isEmpty = true
            }
            
            if isEmpty {
                let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height))
                noDataLabel.text = message
                noDataLabel.textColor = .gray
                noDataLabel.textAlignment = .center
                noDataLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                collectionView.backgroundView = noDataLabel
            } else {
                collectionView.backgroundView = nil
            }
        }
}

// MARK: - UICollectionView DataSource & Delegate
extension ProviderViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           switch collectionView.tag {
           case 0: return min(myBookings.count, 5)
           case 1: return min(incomingRequests.count, 5)
           case 2: return min(completedBookings.count, 5)
           default: return 0
           }
       }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
          switch collectionView.tag {
          case 0:
              // My Bookings Cell
              return configureMyBookingCell(collectionView, indexPath: indexPath)
          case 1:
              // Incoming Bookings Cell
              return configureIncomingCell(collectionView, indexPath: indexPath)
          case 2:
              // Completed Requests Cell
              return configureCompletedCell(collectionView, indexPath: indexPath)
          default:
              return UICollectionViewCell()
          }
      }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           switch collectionView.tag {
           case 0: return CGSize(width: 222, height: collectionView.frame.height)
           case 1: return CGSize(width: 222, height: collectionView.frame.height)
           case 2: return CGSize(width: 222, height: collectionView.frame.height)
           default: return CGSize(width: 222, height: collectionView.frame.height)
           }
       }
    
    // MARK: - Configure Cells
    
    private func configureMyBookingCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myBookingCell", for: indexPath) as! MyBookingCollectionViewCell
               let order = myBookings[indexPath.row]
               
               // Styling
               cell.contentView.backgroundColor = UIColor(named: "CardBackground")
               cell.contentView.layer.cornerRadius = 12
               cell.contentView.layer.masksToBounds = true
               
               // Profile Image - Load from URL or use placeholder
        cell.layoutIfNeeded()
               
               if let userData = userDataCache[order.providerID],
                  !userData.profilePicture.isEmpty,
                  let imageUrl = URL(string: userData.profilePicture) {
                   loadImage(from: imageUrl, into: cell.profilePic)
               } else {
                   cell.profilePic.image = UIImage(systemName: "person.circle.fill")
                   cell.profilePic.tintColor = .systemBlue
               }
               
               cell.profilePic.contentMode = .scaleAspectFill
               cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
               cell.profilePic.clipsToBounds = true
               
               // ⭐ Data - Use cached user data
               cell.username.text = userDataCache[order.providerID]?.fullName ?? "Unknown User"
               cell.dateInput.text = formatDate(order.orderDate)
               cell.timeInput.text = formatTime(order.orderDate)
               cell.serviceInput.text = order.serviceName
               cell.paidInput.text = order.subtotal
               cell.statusInput.text = order.status.capitalized
               
               // Status Color
               switch order.status.lowercased() {
               case "accepted":
                   cell.statusInput.textColor = .systemGreen
               case "pending":
                   cell.statusInput.textColor = .systemOrange
               case "rejected":
                   cell.statusInput.textColor = .systemRed
               case "completed":
                   cell.statusInput.textColor = .systemBlue
               default:
                   cell.statusInput.textColor = .darkGray
               }
        return cell
       }
       
       private func configureCompletedCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompletedRequestsCell", for: indexPath) as! CompletedRequestCollectionViewCell
               let order = completedBookings[indexPath.row]  // ⭐ Use completedBookings array
               
               // Styling
               cell.contentView.backgroundColor = UIColor(named: "CardBackground")
               cell.contentView.layer.cornerRadius = 12
               cell.contentView.layer.masksToBounds = true
               
               // Profile Image
               cell.layoutIfNeeded()
               
               if let userData = userDataCache[order.userID],
                  !userData.profilePicture.isEmpty,
                  let imageUrl = URL(string: userData.profilePicture) {
                   loadImage(from: imageUrl, into: cell.profilePic)
               } else {
                   cell.profilePic.image = UIImage(systemName: "person.circle.fill")
                   cell.profilePic.tintColor = .systemGreen  // Green for completed
               }
               
               cell.profilePic.contentMode = .scaleAspectFill
               cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
               cell.profilePic.clipsToBounds = true
               
               // Data
               cell.username.text = userDataCache[order.userID]?.fullName ?? "Unknown User"
               cell.dateInput.text = formatDate(order.orderDate)
               cell.timeInput.text = formatTime(order.orderDate)
               cell.serviceInput.text = order.serviceName
               cell.paidInput.text = order.subtotal
               
               return cell
       }
       
       private func configureIncomingCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncomingRequestsCell", for: indexPath) as! IncomingRequestCollectionViewCell
              let order = incomingRequests[indexPath.row]
              
              // Styling
              cell.contentView.backgroundColor = UIColor(named: "CardBackground")
              cell.contentView.layer.cornerRadius = 12
              cell.contentView.layer.masksToBounds = true
              
              // Profile Image
              cell.layoutIfNeeded()
              
              if let userData = userDataCache[order.userID],
                 !userData.profilePicture.isEmpty,
                 let imageUrl = URL(string: userData.profilePicture) {
                  loadImage(from: imageUrl, into: cell.profilePic)
              } else {
                  cell.profilePic.image = UIImage(systemName: "person.circle.fill")
                  cell.profilePic.tintColor = .systemOrange
              }
              
              cell.profilePic.contentMode = .scaleAspectFill
              cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
              cell.profilePic.clipsToBounds = true
              
              // Data
              cell.username.text = userDataCache[order.userID]?.fullName ?? "Unknown User"
              cell.dateInput.text = formatDate(order.orderDate)
              cell.timeInput.text = formatTime(order.orderDate)
              cell.serviceInput.text = order.serviceName
              
              // ⭐ Configure buttons based on status
              cell.acceptBTN.tag = indexPath.row
              cell.rejectBTN.tag = indexPath.row
              cell.acceptBTN.removeTarget(nil, action: nil, for: .allEvents)
              cell.rejectBTN.removeTarget(nil, action: nil, for: .allEvents)
              
              if order.status.lowercased() == "pending" {
                  cell.acceptBTN.layer.cornerRadius = 8
                  cell.rejectBTN.layer.cornerRadius = 8
                  
                  cell.acceptBTN.clipsToBounds = true
                  cell.rejectBTN.clipsToBounds = true
                  
                  cell.rejectBTN.layer.borderWidth = 2.0
                  cell.rejectBTN.layer.borderColor = UIColor(named: "Primary_btn_color")?.cgColor
                  
                  cell.acceptBTN.addTarget(self, action: #selector(acceptTapped(_:)), for: .touchUpInside)
                  cell.rejectBTN.addTarget(self, action: #selector(rejectTapped(_:)), for: .touchUpInside)
                  
              }
              return cell
       }
    
    private func styleBackground(cell: UITableViewCell, color: UIColor) {
        
    }
    
    private func loadImage(from url: URL, into imageView: UIImageView) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, let image = UIImage(data: data) else { return }
                
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }.resume()
        }
       // MARK: - Button Styling
    private func formatDate(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "MMM dd, yyyy"
           return formatter.string(from: date)
       }
       
       private func formatTime(_ date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "hh:mm a"
           return formatter.string(from: date)
       }
       
       // MARK: - Button Styling
       private func styleButton(_ button: UIButton, color: UIColor) {
           button.backgroundColor = color
           button.setTitleColor(.white, for: .normal)
           button.layer.cornerRadius = 8
           button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
       }
       
       // MARK: - Button Actions
       @objc private func acceptTapped(_ sender: UIButton) {
           let index = sender.tag
               let order = incomingRequests[index]
               
               let confirmAlert = UIAlertController(
                   title: "Accept Request",
                   message: "Are you sure you want to accept this request?",
                   preferredStyle: .alert
               )
               
               confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
               confirmAlert.addAction(UIAlertAction(title: "Accept", style: .default) { _ in
                   Task {
                               do {
                                   // Update status to "accepted"
                                   try await OrderController.shared.updateOrderStatus(id: order.id, status: "accepted")
                                   
                                   // ⭐ Wait for data to reload BEFORE navigating
                                   guard let currentUserID = Auth.auth().currentUser?.uid else { return }
                                   
                                   // Reload and AWAIT completion
                                   await self.reloadIncomingRequestsAndNavigate(providerID: currentUserID)
                                   
                               } catch {
                                   print("Error accepting request: \(error.localizedDescription)")
                               }
                           }
                       })
               
               present(confirmAlert, animated: true)
       }
    
    // ⭐ ADD THIS METHOD
    private func reloadIncomingRequestsAndNavigate(providerID: String) async {
        do {
            // Get Pending orders
            let pendingOrders = try await OrderController.shared.getOrdersByStatus(
                providerID: providerID,
                status: "pending"
            )
            
            // Get Accepted orders
            let acceptedOrders = try await OrderController.shared.getOrdersByStatus(
                providerID: providerID,
                status: "accepted"
            )
            
            // Combine both
            let allOrders = pendingOrders + acceptedOrders
            
            // Sort by status (Pending first, then Accepted)
            let sortedAllOrders = allOrders.sorted {
                if $0.status == $1.status {
                    return $0.orderDate < $1.orderDate
                }
                return $0.status.lowercased() == "pending"
            }
            
            // Fetch user data
            let userIDs = sortedAllOrders.map { $0.userID }
            let userData = try await fetchUserData(userIDs: userIDs)
            
            // ⭐ Update data on main thread
            await MainActor.run {
                self.incomingRequests = pendingOrders
                self.allIncomingRequests = sortedAllOrders
                self.userDataCache.merge(userData) { _, new in new }
                
                // ⭐ NOW perform segue with fresh data
                self.performSegue(withIdentifier: "viewRequests", sender: "Incoming")
                
                // Show success message
                let alert = UIAlertController(
                    title: "Success",
                    message: "Request accepted",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        } catch {
            print("Error reloading incoming requests: \(error)")
        }
    }
       @objc private func rejectTapped(_ sender: UIButton) {
           let index = sender.tag
              let order = incomingRequests[index]
              
              // Show confirmation
              let alert = UIAlertController(title: "Reject Request", message: "Are you sure you want to reject this request?", preferredStyle: .alert)
              
              alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
              alert.addAction(UIAlertAction(title: "Reject", style: .destructive) { _ in
                  Task {
                      do {
                          // Update status to "rejected"
                          try await OrderController.shared.updateOrderStatus(id: order.id, status: "rejected")
                          
                          await MainActor.run {
                              // Remove from incoming
                              self.incomingRequests.remove(at: index)
                              self.IncomingRequestCollectionView.reloadData()
                              self.updateEmptyState(for: self.IncomingRequestCollectionView, message: "No incoming requests")
                          }
                      } catch {
                          print("Error rejecting request: \(error.localizedDescription)")
                      }
                  }
              })
              
              present(alert, animated: true)
       }
    
    @IBAction func viewAllIncomingTapped(sender: UIButton) {
    performSegue(withIdentifier: "viewRequests", sender: "Incoming")
    }
    @IBAction func viewAllCompletedTapped(sender: UIButton) {
    performSegue(withIdentifier: "viewRequests", sender: "Completed")
    }
    @IBAction func viewAllMyBookingTapped(sender: UIButton) {
    performSegue(withIdentifier: "viewRequests", sender: "MyBooking")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewRequests" {
                   if let destinationVC = segue.destination as? RequestViewController,
                      let type = sender as? String {
                       
                       destinationVC.type = type
                       
                       // Pass the appropriate data
                       if type == "Incoming" {
                           destinationVC.orders = allIncomingRequests
                       } else if type == "Completed" {
                           destinationVC.orders = completedBookings
                       } else if type == "MyBooking" {
                           destinationVC.orders = myBookings
                       }
                   }
               }
           }
    
    
}
