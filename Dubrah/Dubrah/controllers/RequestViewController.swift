//
//  RequestViewController.swift
//  Dubrah
//
//  Created by mohammed ali on 02/01/2026.
//

import UIKit
import FirebaseAuth


class RequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    var type: String?
    var orders: [Order] = []
    private var userDataCache: [String: UserData] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        table.delegate = self
        table.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            // Fetch user data for all orders
            fetchAllUserData()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateEmptyState()
    }

    private func updateEmptyState() {
        if orders.isEmpty {
            let emptyLabel = UILabel(frame: table.bounds)
            emptyLabel.text = type == "Incoming" ? "No requests yet" :
                              type == "Completed" ? "No completed bookings" :
                              "No bookings yet"
            emptyLabel.textColor = .gray
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            table.backgroundView = emptyLabel
        } else {
            table.backgroundView = nil
        }
    }
        private func setupUI() {
            // Set title based on type
            if type == "Incoming" {
                self.title = "Incoming Requests"
            } else if type == "Completed" {
                self.title = "Completed Bookings"
            } else if type == "MyBooking" {
                self.title = "My Bookings"
            }
            
            table.rowHeight = 190
        }
        
        private func fetchAllUserData() {
            Task {
                do {
                    // Get all unique user IDs from orders
                    let userIDs = orders.map { $0.userID }
                    let userData = try await fetchUserData(userIDs: userIDs)
                    
                    await MainActor.run {
                        self.userDataCache = userData
                        self.table.reloadData()
                    }
                } catch {
                    print("Error fetching user data: \(error)")
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
                    usersData[userID] = UserData(fullName: "Unknown User", profilePicture: "")
                }
            }
            
            return usersData
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! RequestTableViewCell
                
                let order = orders[indexPath.row]
                let userData = userDataCache[order.userID]
                
                // Configure cell
                cell.configure(with: order, userData: userData, viewMode: type ?? "")
                
                // Set button callbacks
        if type == "Incoming" {
            switch order.status.lowercased() {
            case "pending":
                cell.onLeftButtonTapped = { [weak self] in
                    self?.acceptRequest(at: indexPath.row)
                }
                cell.onRightButtonTapped = { [weak self] in
                    self?.rejectRequest(at: indexPath.row)
                }
                
            case "accepted":
                cell.onLeftButtonTapped = { [weak self] in
                    self?.openChat(at: indexPath.row)
                }
                cell.onRightButtonTapped = { [weak self] in
                    self?.completeRequest(at: indexPath.row)
                }
                
            default:
                break
            }
        }
                
                return cell
    }

    private func acceptRequest(at index: Int) {
        let order = orders[index]
            
            let confirmAlert = UIAlertController(
                title: "Accept Request",
                message: "Are you sure you want to accept this request?",
                preferredStyle: .alert
            )
            
            confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            confirmAlert.addAction(UIAlertAction(title: "Accept", style: .default) { _ in
                Task {
                    do {
                        try await OrderController.shared.updateOrderStatus(id: order.id, status: "accepted")
                        
                        await MainActor.run {
                            // Update order in array
                            self.orders[index].status = "accepted"
                            
                            // Reload cell
                            self.table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            
                            // Show success
                            let alert = UIAlertController(title: "Success", message: "Request accepted", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    } catch {
                        print("Error accepting request: \(error)")
                    }
                }
            })
            
            present(confirmAlert, animated: true)
        }
        
        private func rejectRequest(at index: Int) {
            let order = orders[index]
            
            let alert = UIAlertController(title: "Reject Request", message: "Are you sure you want to reject this request?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Reject", style: .destructive) { _ in
                Task {
                    do {
                        try await OrderController.shared.updateOrderStatus(id: order.id, status: "rejected")
                        
                        await MainActor.run {
                            // Remove from array
                            self.orders.remove(at: index)
                            self.table.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                        }
                    } catch {
                        print("Error rejecting request: \(error)")
                    }
                }
            })
            
            present(alert, animated: true)
        }
        
        private func openChat(at index: Int) {
            let order = orders[index]
            
            Task {
                do {
                    let chatID = try await ChatController.shared.getOrCreateChat(
                        user1ID: order.providerID,
                        user2ID: order.userID
                    )

                    await MainActor.run {
                        // Make sure storyboard ID is correct (you said it's "ChatVC")
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
                        vc.chatID = chatID
                        vc.receiverID = order.userID

                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } catch {
                    print("❌ open chat failed:", error)
                }
            }
        }
        
        private func completeRequest(at index: Int) {
            let order = orders[index]
            
            let alert = UIAlertController(
                title: "Complete Order",
                message: "Mark this order as completed?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Complete", style: .default) { _ in
                Task {
                    do {
                        try await OrderController.shared.updateOrderStatus(id: order.id, status: "completed")
                        
                        await MainActor.run {
                            // Remove from array
                            self.orders.remove(at: index)
                            self.table.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            
                            // Show success
                            let successAlert = UIAlertController(
                                title: "Success",
                                message: "Order marked as completed",
                                preferredStyle: .alert
                            )
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(successAlert, animated: true)
                        }
                    } catch {
                        print("Error completing order: \(error)")
                    }
                }
            })
            
            present(alert, animated: true)
        }
    }
