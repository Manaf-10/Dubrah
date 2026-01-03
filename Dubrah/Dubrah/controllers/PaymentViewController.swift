//
//  PaymentViewController.swift
//  Dubrah
//
//  Created by Ali on 20/12/2025.
//

import UIKit

class PaymentViewController: UIViewController {
    var serviceImageUrl: String?
    var serviceTitleText: String!
    var providerNameAttributed: NSAttributedString!
    var priceText: String?
    var durationText: String?              // passed through only
    var serviceImage: UIImage?
    var providerImage: UIImage?
    var serviceId: String?
    var availablePaymentMethods: [String] = []
    var providerId: String?
    private var selectedPayment: RadiobuttonView?

       @IBOutlet weak var paymentImageView: UIImageView!
       @IBOutlet weak var paymentTitleLabel: UILabel!
       @IBOutlet weak var paymentProviderLabel: UILabel!
       @IBOutlet weak var creditOption: RadiobuttonView!
       @IBOutlet weak var applePayOption: RadiobuttonView!
       @IBOutlet weak var cashOption: RadiobuttonView!

    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var subtotalLabel: UILabel!
       @IBOutlet weak var proceedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
        setupUI()
        configureAvailablePaymentMethods()
    }

    // MARK: - Bind Passed Data
    private func bindData() {
        paymentTitleLabel.text = serviceTitleText
        paymentProviderLabel.attributedText = providerNameAttributed
        paymentImageView.image = serviceImage
        providerImageView.image = providerImage
        subtotalLabel.text = priceText
    }

    // MARK: - UI Setup
    private func setupUI() {

        // Proceed button
        proceedButton.isEnabled = false
        proceedButton.backgroundColor = .systemGray4
        proceedButton.setTitleColor(.black, for: .disabled)
        proceedButton.layer.cornerRadius = 12

        // Images
        paymentImageView.layer.cornerRadius = 12
        paymentImageView.clipsToBounds = true
        makeCircular(providerImageView)

        // Titles
        creditOption.titleLabel.text = "Credit/Debit Card"
        applePayOption.titleLabel.text = "Apple Pay"
        cashOption.titleLabel.text = "Cash"

        // Gestures
        creditOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMethod)))
        applePayOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMethod)))
        cashOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMethod)))
    }

    // MARK: - Payment Methods (from DB)
    private func configureAvailablePaymentMethods() {

        // Hide all first
        creditOption.isHidden = true
        applePayOption.isHidden = true
        cashOption.isHidden = true

        for method in availablePaymentMethods {
            switch method {
            case "Cash":
                cashOption.isHidden = false
            case "Credit/Debit Card":
                creditOption.isHidden = false
            case "Apple Pay":
                applePayOption.isHidden = false
            default:
                break
            }
        }
    }

    // MARK: - Selection
    @objc private func selectMethod(_ sender: UITapGestureRecognizer) {
        guard let option = sender.view as? RadiobuttonView else { return }

        selectedPayment?.isSelectedOption = false
        option.isSelectedOption = true
        selectedPayment = option

        UIView.animate(withDuration: 0.25) {
            self.proceedButton.isEnabled = true
            self.proceedButton.backgroundColor = .black
            self.proceedButton.setTitleColor(.white, for: .normal)
        }
    }

    // MARK: - Helpers
    private func selectedPaymentMethod() -> String? {
        if selectedPayment === cashOption { return "Cash" }
        if selectedPayment === applePayOption { return "Apple Pay" }
        if selectedPayment === creditOption { return "Credit/Debit Card" }
        return nil
    }

    private func generateOrderDate() -> Date {
        return Date()
    }

    @IBAction func payNowTapped(_ sender: Any) {
        guard let method = selectedPaymentMethod() else { return }
              let orderDate = generateOrderDate()

              if method == "Credit/Debit Card" {
                  performSegue(withIdentifier: "toPaymentGateway", sender: orderDate)
              } else {
                  performSegue(withIdentifier: "toReceiptPage", sender: orderDate)
              }
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

           guard let orderDate = sender as? Date else { return }
           let paymentMethod = selectedPaymentMethod() ?? ""

           if segue.identifier == "toReceiptPage",
              let destination = segue.destination as? ReceiptPageViewController {

               destination.serviceTitle = serviceTitleText
               destination.providerNameAttributed = providerNameAttributed
               destination.serviceImage = serviceImage
               destination.subtotalText = priceText
               destination.serviceId = serviceId
               destination.paymentMethod = paymentMethod
               destination.orderDate = orderDate
               destination.providerId = providerId
               destination.serviceImageUrl = serviceImageUrl

           }

           if segue.identifier == "toPaymentGateway",
              let destination = segue.destination as? CreditCardPaymentViewController {

               destination.serviceTitle = serviceTitleText
               destination.providerNameAttributed = providerNameAttributed
               destination.serviceImage = serviceImage
               destination.subtotalText = priceText
               destination.serviceId = serviceId
               destination.paymentMethod = paymentMethod
               destination.orderDate = orderDate
               destination.providerId = providerId
               destination.serviceImageUrl = serviceImageUrl

           }
       }
}
