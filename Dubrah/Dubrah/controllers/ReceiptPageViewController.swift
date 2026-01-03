//
//  ReceiptPageViewController.swift
//  Dubrah
//
//  Created by Ali on 24/12/2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ReceiptPageViewController: UIViewController {
    var serviceTitle: String!
    var providerNameAttributed: NSAttributedString!
    var serviceImage: UIImage?
    var subtotalText: String!
    var paymentMethod: String!
    var orderDate: Date!
    var serviceId: String?
    var serviceImageUrl: String?

    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var serviceTitleLabel: UILabel!
    @IBOutlet weak var providerNameLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    private var orderCreated = false
    var providerId: String!   // 🔥 MUST be passed from previous screen

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        configureUI()
        bindData()
        print("didload")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard !orderCreated else { return }
        orderCreated = true

        print("🟢 Receipt appeared, creating order...")

        Task {
            await createOrderIfNeeded()
        }
    }

    private func createOrderIfNeeded() async {
        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("❌ No logged-in user")
                return
            }
            
            guard let providerId = providerId else {
                print("❌ providerId is nil")
                return
            }
            
            let orderData: [String: Any] = [
                "orderDate": FieldValue.serverTimestamp(),

                "providerID": providerId,
                "providerRating": 0,

                "serviceId": serviceId ?? "",
                "serviceName": serviceTitle ?? "",
                "serviceImageUrl": serviceImageUrl ?? "",   
                "serviceRating": 0,

                "subtotal": subtotalText ?? "",
                "paymentMethod": paymentMethod ?? "",

                "status": "pending",
                "userID": userId
            ]


            let orderId = try await OrderController.shared.addOrder(data: orderData)
            print("✅ Order CREATED:", orderId)

        } catch {
            print("❌ Firestore write failed:", error.localizedDescription)
        }
    }


    
    
    
    // MARK: - UI Setup
    private func configureUI() {
        roundImage(serviceImageView, radius:12)
    }


    // MARK: - Bind Data
    private func bindData() {

        serviceTitleLabel.text = serviceTitle ?? "—"
        providerNameLabel.attributedText = providerNameAttributed
        subtotalLabel.text = subtotalText ?? "—"
        paymentMethodLabel.text = paymentMethod ?? "—"

        if let image = serviceImage {
            serviceImageView.image = image
        }

        if let date = orderDate {
            orderDateLabel.text = formattedDate(from: date)
        } else {
            orderDateLabel.text = "—"
        }

        orderIdLabel.text = generateOrderId()
    }

    // MARK: - Helpers
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func generateOrderId() -> String {
        return "ORD-" + UUID().uuidString.prefix(8).uppercased()
    }

   @IBAction func doneTapped(_ sender: UIButton) {
    navigationController?.popToRootViewController(animated: true)
}
}
