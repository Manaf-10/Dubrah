//
//  CreditCardPaymentViewController.swift
//  Dubrah
//
//  Created by Ali on 22/12/2025.
//

import UIKit

class CreditCardPaymentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var cardNameField: UITextField!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expiryField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            setupFields()
            setupButton()
            setDelegates()
        
            cardNumberField.addTarget(self, action: #selector(cardNumberChanged(_:)), for: .editingChanged)
            expiryField.addTarget(self, action: #selector(expiryChanged(_:)), for: .editingChanged)
        }
        
        func setupFields() {
            let fields = [cardNameField, cardNumberField, expiryField, cvvField]
            
            fields.forEach { field in
                field?.layer.cornerRadius = 12
                field?.layer.borderWidth = 1
                field?.layer.borderColor = UIColor.systemGray4.cgColor
                field?.backgroundColor = UIColor.systemGray6
                
            }
            
            cardNumberField.keyboardType = .numberPad
            expiryField.keyboardType = .numberPad
            cvvField.keyboardType = .numberPad
            
            subtotalLabel.text = "Subtotal: 35 BD"
        }
        
        func setupButton() {
            payButton.layer.cornerRadius = 12
            payButton.backgroundColor = .black
            payButton.setTitleColor(.white, for: .normal)
        }
        
        func setDelegates() {
            cardNameField.delegate = self
            cvvField.delegate = self
        }
        
        @objc func cardNumberChanged(_ textField: UITextField) {
            let raw = textField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            let digits = raw.filter { $0.isNumber }
            let limited = String(digits.prefix(16))
            
            var formatted = ""
            for (i, char) in limited.enumerated() {
                if i > 0 && i % 4 == 0 {
                    formatted.append(" ")
                }
                formatted.append(char)
            }
            
            textField.text = formatted
        }

        @objc func expiryChanged(_ textField: UITextField) {
            let raw = textField.text?.replacingOccurrences(of: "/", with: "") ?? ""
            let digits = raw.filter { $0.isNumber }
            let limited = String(digits.prefix(4))
            
            if limited.count <= 2 {
                textField.text = limited
            } else {
                let mm = String(limited.prefix(2))
                let yy = String(limited.suffix(limited.count - 2))
                textField.text = "\(mm)/\(yy)"
            }
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
            if textField == cvvField {
                let current = (textField.text ?? "") as NSString
                let newString = current.replacingCharacters(in: range, with: str)
                return newString.count <= 3
            }
            return true
        }

        @IBAction func payButtonTapped(_ sender: UIButton) {
            performSegue(withIdentifier: "toReceiptPage", sender: self)
        }
    }



