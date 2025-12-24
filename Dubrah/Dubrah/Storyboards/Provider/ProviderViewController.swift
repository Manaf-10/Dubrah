//
//  ProviderViewController.swift
//  Dubrah
//
//  Created by mohammed ali on 23/12/2025.
//

import UIKit

class ProviderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addNewPostBTN: UIButton!
    var data = DummyDataManager.shared.getMyBookings()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewPostBTN.layer.cornerRadius = 18
        
        collectionView.delegate = self
        collectionView.dataSource = self
        updateEmptyState()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myBookingCell", for: indexPath) as! ProviderCollectionViewCell
        
        
        
        cell.contentView.backgroundColor = UIColor(named: "CardBackground")
        cell.contentView.layer.cornerRadius = 12
        cell.contentView.layer.masksToBounds = true
        
        cell.layoutIfNeeded()
        cell.profilePic.image = UIImage(systemName: data[indexPath.row].profileImage)
        cell.profilePic.contentMode = .scaleAspectFill
        cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2
        cell.profilePic.clipsToBounds = true
        cell.profilePic.tintColor = .systemBlue
        
        
        cell.username.text = data[indexPath.row].userName
        cell.dateInput.text = data[indexPath.row].date
        cell.timeInput.text = data[indexPath.row].time
        cell.serviceInput.text = data[indexPath.row].service
        cell.paidInput.text = data[indexPath.row].paid
        cell.statusInput.text = data[indexPath.row].status.rawValue
        
        switch data[indexPath.row].status {
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 222, height: collectionView.frame.height)
    }
    func updateEmptyState() {
        if data.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            noDataLabel.text = "No Bookings Available"
            noDataLabel.textColor = .gray
            noDataLabel.textAlignment = .center
            noDataLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            collectionView.backgroundView = noDataLabel
        } else {
            collectionView.backgroundView = nil
        }
    }
}
