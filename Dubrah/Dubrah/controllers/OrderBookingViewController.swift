//
//  OrderBookingViewController.swift
//  Dubrah
//
//  Created by Ali on 18/12/2025.
//

import UIKit

class OrderBookingViewController: UIViewController,
                                  UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    let maxCharacters = 300
    struct BookingDate {
        let day: String
        let date: String
        let isAvailable: Bool
    }

    var dates: [BookingDate] = [
        BookingDate(day: "Sun", date: "13/1", isAvailable: false),
        BookingDate(day: "Mon", date: "14/1", isAvailable: false),
        BookingDate(day: "Tue", date: "15/1", isAvailable: true),
        BookingDate(day: "Wed", date: "16/1", isAvailable: true),
        BookingDate(day: "Thu", date: "17/1", isAvailable: true)
    ]
    
    struct BookingTime {
        let time: String
        let isAvailable: Bool
    }
    var times: [BookingTime] = [
        BookingTime(time: "4:00 – 5:00 PM", isAvailable: false),
        BookingTime(time: "6:00 – 7:00 PM", isAvailable: true),
        BookingTime(time: "7:00 – 8:00 PM", isAvailable: true)
    ]

    
    var selectedDateIndex: IndexPath?
    var selectedTimeIndex: IndexPath?
    

    @IBOutlet weak var notesCounterLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    @IBOutlet weak var orderPreviewCardView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var dateCollectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeCollectionView.dataSource = self
        timeCollectionView.delegate = self
        dateCollectionView.dataSource = self
        dateCollectionView.delegate = self
        notesTextView.delegate = self
        notesTextView.text = "Add additional notes (optional)..."
        notesTextView.textColor = UIColor.systemGray3
        orderPreviewView(orderPreviewCardView)
        previewImageView.layer.cornerRadius = 12
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.borderWidth = 1
        previewImageView.layer.borderColor = UIColor.systemGray4.cgColor
        makeCircular(providerImageView)
        styleNotesTextView()

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if collectionView == dateCollectionView {
            return dates.count
        } else {
            return times.count
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == dateCollectionView {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DateCell",
                for: indexPath
            ) as! DateCollectionViewCell
            
            let item = dates[indexPath.item]
            let isSelected = (selectedDateIndex == indexPath)
            
            cell.configure(
                day: item.day,
                date: item.date,
                isSelected: isSelected,
                isAvailable: item.isAvailable
            )
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TimeCell",
                for: indexPath
            ) as! TimeCollectionViewCell
            
            let item = times[indexPath.item]
            let isSelected = (selectedTimeIndex == indexPath)
            
            cell.configure(
                time: item.time,
                isAvailable: item.isAvailable,
                isSelected: isSelected
            )
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {
            
            
            if collectionView == dateCollectionView {
                
                if dates[indexPath.row].isAvailable == false { return }

                selectedDateIndex = indexPath
                collectionView.reloadData()
                
            } else {
                
                if times[indexPath.row].isAvailable == false { return }

                selectedTimeIndex = indexPath
                collectionView.reloadData()
            }
        }
        
    
    func orderPreviewView(_ view: UIView) {
        
        view.layer.cornerRadius = 12
        view.clipsToBounds = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowRadius = 6
        
    }
    func roundImage(_ imageView: UIImageView, radius: CGFloat) {
        imageView.layer.cornerRadius = radius
        imageView.clipsToBounds = true
    }
    func makeCircular(_ imageView: UIImageView) {
        imageView.layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    func styleNotesTextView() {
        notesTextView.layer.cornerRadius = 12
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.systemGray4.cgColor
        notesTextView.clipsToBounds = true
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OrderBookingViewController {

    func textViewDidBeginEditing(_ textView: UITextView) {

        notesTextView.layer.borderColor = UIColor.systemBlue.cgColor
        notesTextView.layer.borderWidth = 1.2

        if textView.textColor == UIColor.systemGray3 {
            textView.text = ""
            textView.textColor = .label
            textView.tintColor = .systemBlue
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        notesTextView.layer.borderColor = UIColor.systemGray4.cgColor
        notesTextView.layer.borderWidth = 1

        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Add additional notes (optional)..."
            textView.textColor = UIColor.systemGray3
            textView.tintColor = .clear
            notesCounterLabel.text = "0/\(maxCharacters)"
        }
    }

    func textViewDidChange(_ textView: UITextView) {

        if textView.textColor == UIColor.systemGray3 { return }

        let count = textView.text.count
        notesCounterLabel.text = "\(count)/\(maxCharacters)"

        if count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
            notesCounterLabel.text = "\(maxCharacters)/\(maxCharacters)"
        }
    }
}
