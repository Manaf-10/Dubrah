//
//  ProviderViewController.swift
//  Dubrah
//
//  Created by mohammed ali on 23/12/2025.
//

import UIKit

class ProviderViewController: UIViewController {
    // Mark: - Outlets
    @IBOutlet weak var myBookingCollectionView: UICollectionView!
    @IBOutlet weak var IncomingRequestCollectionView: UICollectionView!
    @IBOutlet weak var CompletedRequestsCollectionView: UICollectionView!
    @IBOutlet weak var addNewPostBTN: UIButton!
    
    var data = DummyDataManager.shared.getMyBookings()
    // MARK: - Data
    var myBookings = DummyDataManager.shared.getMyBookings()
    var completedBookings = DummyDataManager.shared.getCompletedBookings()
    var incomingRequests = DummyDataManager.shared.getIncomingRequests()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(myBookings.count)
        print(completedBookings.count)
        print(incomingRequests.count)
        setupUI()
        setupCollectionViews()
        updateAllEmptyStates()
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
    
    // MARK: - Empty State
    private func updateAllEmptyStates() {
        updateEmptyState(for: myBookingCollectionView, message: "No bookings yet")
        updateEmptyState(for: CompletedRequestsCollectionView, message: "No completed bookings")
        updateEmptyState(for: IncomingRequestCollectionView, message: "No incoming requests")
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
           case 0: return myBookings.count
           case 1: return incomingRequests.count
           case 2: return completedBookings.count
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
           let booking = myBookings[indexPath.row]
           
           // Styling
           cell.contentView.backgroundColor = UIColor(named: "CardBackground")
           cell.contentView.layer.cornerRadius = 12
           cell.contentView.layer.masksToBounds = true
           
           // Profile Image
           cell.layoutIfNeeded()
           cell.profilePic.image = UIImage(systemName: booking.profileImage)
           cell.profilePic.contentMode = .scaleAspectFill
           cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
           cell.profilePic.clipsToBounds = true
           cell.profilePic.tintColor = .systemBlue
           
           // Data
           cell.username.text = booking.userName
           cell.dateInput.text = booking.date
           cell.timeInput.text = booking.time
           cell.serviceInput.text = booking.service
           cell.paidInput.text = booking.paid
           cell.statusInput.text = booking.status.rawValue.capitalized
           
           // Status Color
           switch booking.status {
           case .accepted:
               cell.statusInput.textColor = .systemGreen
           case .pending:
               cell.statusInput.textColor = .systemOrange
           case .rejected:
               cell.statusInput.textColor = .systemRed
           default:
               cell.statusInput.textColor = .darkGray
           }
           
           return cell
       }
       
       private func configureCompletedCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CompletedRequestsCell", for: indexPath) as! CompletedRequestCollectionViewCell
           let booking = completedBookings[indexPath.row]
           
           // Styling
           cell.contentView.backgroundColor = UIColor(named: "CardBackground")
           cell.contentView.layer.cornerRadius = 12
           cell.contentView.layer.masksToBounds = true
           
           // Profile Image
           cell.layoutIfNeeded()
           cell.profilePic.image = UIImage(systemName: booking.profileImage)
           cell.profilePic.contentMode = .scaleAspectFill
           cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
           cell.profilePic.clipsToBounds = true
           cell.profilePic.tintColor = .systemGreen
           
           // Data
           cell.username.text = booking.userName
           cell.dateInput.text = booking.date
           cell.timeInput.text = booking.time
           cell.serviceInput.text = booking.service
           cell.paidInput.text = booking.paid
           
           return cell
       }
       
       private func configureIncomingCell(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncomingRequestsCell", for: indexPath) as! IncomingRequestCollectionViewCell
           let booking = incomingRequests[indexPath.row]
           
           // Styling
           cell.contentView.backgroundColor = UIColor(named: "CardBackground")
           cell.contentView.layer.cornerRadius = 12
           cell.contentView.layer.masksToBounds = true
           
           // Profile Image
           cell.layoutIfNeeded()
           cell.profilePic.image = UIImage(systemName: booking.profileImage)
           cell.profilePic.contentMode = .scaleAspectFill
           cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
           cell.profilePic.clipsToBounds = true
           cell.profilePic.tintColor = .systemOrange
           
           // Data
           cell.username.text = booking.userName
           cell.dateInput.text = booking.date
           cell.timeInput.text = booking.time
           cell.serviceInput.text = booking.service
           
           // Style Buttons
           styleButton(cell.acceptBTN, color: .primaryBtn)
           styleButton(cell.rejectBTN, color: .white)
           
           // Set button actions
           cell.acceptBTN.tag = indexPath.row
           cell.rejectBTN.tag = indexPath.row
           cell.acceptBTN.addTarget(self, action: #selector(acceptTapped(_:)), for: .touchUpInside)
           cell.rejectBTN.addTarget(self, action: #selector(rejectTapped(_:)), for: .touchUpInside)
           
           return cell
       }
       
       // MARK: - Button Styling
       private func styleButton(_ button: UIButton, color: UIColor) {
           button.backgroundColor = color
           button.setTitleColor(.white, for: .normal)
           button.layer.cornerRadius = 8
           button.layer.borderWidth = 1
           button.layer.borderColor = color.cgColor
           button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
       }
       
       // MARK: - Button Actions
       @objc private func acceptTapped(_ sender: UIButton) {
           let index = sender.tag
           let booking = incomingRequests[index]
           print("Accepted: \(booking.userName)")
           
           // TODO: Update Firebase status to .accepted
           // For now, remove from incoming and reload
           incomingRequests.remove(at: index)
           IncomingRequestCollectionView.reloadData()
       }
       
       @objc private func rejectTapped(_ sender: UIButton) {
           let index = sender.tag
           let booking = incomingRequests[index]
           print("Rejected: \(booking.userName)")
           
           // TODO: Update Firebase status to .rejected
           // For now, remove from incoming and reload
           incomingRequests.remove(at: index)
           IncomingRequestCollectionView.reloadData()
       }
    
}
