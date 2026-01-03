//
//  CreditCardPaymentViewController.swift
//  Dubrah
//
//  Created by Ali on 22/12/2025.
//

import UIKit

class CreditCardPaymentViewController: UIViewController, UITextFieldDelegate {
    // Passed from PaymentViewController
    var serviceTitle: String!
    var providerNameAttributed: NSAttributedString!
    var serviceImage: UIImage?
    var subtotalText: String!
    var serviceId: String!
    var paymentMethod: String!          // "Credit/Debit Card"
    var orderDate: Date!
    var providerId: String?
    var serviceImageUrl: String?
    
    //MARK: - IBOutlets
    // Textfield Containers
    @IBOutlet weak var cardNameContainer: UIView!
    @IBOutlet weak var cardNumberContainer: UIView!
    @IBOutlet weak var expiryContainer: UIView!
    @IBOutlet weak var cvvContainer: UIView!
    // Textfield
    @IBOutlet weak var cardNameField: UITextField!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    // UI
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTargets()
            validateForm()
        }
    // MARK: - UI Setup
       private func setupUI() {
           
           payButton.isEnabled = false
           payButton.alpha = 0.5
           payButton.layer.cornerRadius = 14
           payButton.backgroundColor = .black

           subtotalLabel.text = "Subtotal: \(subtotalText ?? "")"


           let containers = [
               cardNameContainer,
               cardNumberContainer,
               expiryContainer,
               cvvContainer
           ]

           for container in containers {
               container?.layer.cornerRadius = 12
               container?.layer.borderWidth = 1
               container?.layer.borderColor = UIColor.systemGray4.cgColor
           }

           let fields = [
               cardNameField,
               cardNumberField,
               expiryField,
               cvvField
           ]

           for field in fields {
               field?.borderStyle = .none
               field?.backgroundColor = .clear
               field?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
               field?.delegate = self
           }

           cardNumberField.keyboardType = .numberPad
           expiryField.keyboardType = .numberPad
           cvvField.keyboardType = .numberPad
       }
    
    // MARK: - Targets
       private func setupTargets() {

           cardNumberField.addTarget(self, action: #selector(cardNumberChanged), for: .editingChanged)


           let fields = [cardNameField, cardNumberField, expiryField, cvvField]

           for field in fields {
               field?.addTarget(self, action: #selector(editingBegan(_:)), for: .editingDidBegin)
               field?.addTarget(self, action: #selector(editingEnded(_:)), for: .editingDidEnd)
               field?.addTarget(self, action: #selector(validateForm), for: .editingChanged)
           }
       }
    // MARK: - Validation
        @objc private func validateForm() {

            let nameText = cardNameField.text?.trimmingCharacters(in: .whitespaces) ?? ""
            let nameValid = nameText.count >= 3

            let cardDigits = cardNumberField.text?
                .replacingOccurrences(of: " ", with: "") ?? ""
            let cardValid = cardDigits.count == 16

            let expiryValid = isValidExpiry(expiryField.text ?? "")
            let cvvValid = cvvField.text?.count == 3

            updateBorder(cardNameContainer, cardNameField.text, nameValid)
            updateBorder(cardNumberContainer, cardNumberField.text, cardValid)
            updateBorder(expiryContainer, expiryField.text, expiryValid)
            updateBorder(cvvContainer, cvvField.text, cvvValid)

            let isValid = nameValid && cardValid && expiryValid && cvvValid
            payButton.isEnabled = isValid
            payButton.alpha = isValid ? 1.0 : 0.5
        }

        private func isValidExpiry(_ text: String) -> Bool {
            let parts = text.split(separator: "/")
            if parts.count != 2 { return false }

            let month = Int(parts[0]) ?? 0
            return (1...12).contains(month) && parts[1].count == 2
        }

        // MARK: - Formatting
        @objc private func cardNumberChanged() {
            let raw = cardNumberField.text ?? ""
            let digits = raw.filter { $0.isNumber }.prefix(16)

            var formatted = ""
            for (index, char) in digits.enumerated() {
                if index > 0 && index % 4 == 0 {
                    formatted.append(" ")
                }
                formatted.append(char)
            }

            cardNumberField.text = formatted
        }


        // MARK: - Border Handling
        private func updateBorder(_ container: UIView, _ text: String?, _ valid: Bool) {
            if text?.isEmpty ?? true {
                container.layer.borderColor = UIColor.systemGray4.cgColor
            } else if valid {
                container.layer.borderColor = UIColor.systemGreen.cgColor
            } else {
                container.layer.borderColor = UIColor.systemRed.cgColor
            }
        }

        @objc private func editingBegan(_ textField: UITextField) {
            getContainer(for: textField)?.layer.borderColor = UIColor.systemBlue.cgColor
        }

        @objc private func editingEnded(_ textField: UITextField) {
            validateForm()
        }

        private func getContainer(for textField: UITextField) -> UIView? {
            if textField == cardNameField { return cardNameContainer }
            if textField == cardNumberField { return cardNumberContainer }
            if textField == expiryField { return expiryContainer }
            if textField == cvvField { return cvvContainer }
            return nil
        }

        // MARK: - UITextField Delegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // CVV
        if textField == cvvField {
            if string.isEmpty { return true }
            return string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
                && (textField.text?.count ?? 0) < 3
        }

        // Cardholder name
        if textField == cardNameField {
            if string.isEmpty { return true }
            let allowed = CharacterSet.letters.union(.whitespaces)
            return string.rangeOfCharacter(from: allowed.inverted) == nil
        }

        // 🔥 EXPIRY FIELD (MM/YY)
        if textField == expiryField {

            // Allow delete
            if string.isEmpty { return true }

            // Only digits
            if string.rangeOfCharacter(from: .decimalDigits.inverted) != nil {
                return false
            }

            let currentText = textField.text ?? ""
            let newText = (currentText as NSString)
                .replacingCharacters(in: range, with: string)

            // Max length MM/YY
            if newText.count > 5 { return false }

            // Auto-insert slash
            if newText.count == 2 {
                if let m = Int(newText), (1...12).contains(m) {
                    textField.text = newText + "/"
                }
                return false
            }

            // Prevent invalid month first digit
            if newText.count == 1, let digit = Int(newText), digit > 1 {
                return false
            }

            return true
        }

        return true
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let orderDate = sender as? Date else { return }

        if segue.identifier == "toReceiptPage",
           let destination = segue.destination as? ReceiptPageViewController {

            destination.serviceTitle = serviceTitle
            destination.providerNameAttributed = providerNameAttributed
            destination.serviceImage = serviceImage
            destination.subtotalText = subtotalText
            destination.serviceId = serviceId
            destination.paymentMethod = paymentMethod
            destination.orderDate = orderDate
            destination.providerId = providerId
            destination.serviceImageUrl = serviceImageUrl
        }
    }

    @IBAction func payButtonTapped(_ sender: UIButton) {
        // 🔥 Ensure payment method is set
        paymentMethod = "Credit/Debit Card"

        let date = orderDate ?? Date()
        performSegue(withIdentifier: "toReceiptPage", sender: date)
    }

}




