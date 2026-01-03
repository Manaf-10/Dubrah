//
//  OrderDetailsViewController.swift
//  Dubrah
//
//  Created by Ali on 31/12/2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class OrderDetailsViewController: UIViewController {
    var order: Order?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bindData()
    }
    
    // MARK: - UI
    private func configureUI() {
        roundImage(serviceImageView, radius: 12)
    }
    
    // MARK: - Bind Data
    private func bindData() {
        guard let order = order else {
            print("❌ OrderDetailsViewController: order is nil")
            return
        }

        serviceNameLabel.text = order.serviceName
        priceLabel.text = order.subtotal
        dateLabel.text = formattedDate(order.orderDate)
        paymentMethodLabel.text = order.paymentMethod
        providerNameLabel.text = "Loading..."
        loadImage(from: order.serviceImageUrl)

        fetchProviderName()
    }

    private func fetchProviderName() {
        guard let order = order else { return }

        Firestore.firestore()
            .collection("user")
            .document(order.providerID)
            .getDocument { snapshot, error in

                if let error = error {
                    print("❌ Failed to fetch provider:", error.localizedDescription)
                    self.providerNameLabel.text = "—"
                    return
                }

                let name = snapshot?.data()?["fullName"] as? String
                self.providerNameLabel.text = name ?? "Provider"
            }
    }

    
    // MARK: - Helpers
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            serviceImageView.image = UIImage(systemName: "photo")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.serviceImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

