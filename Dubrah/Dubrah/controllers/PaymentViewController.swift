//
//  PaymentViewController.swift
//  Dubrah
//
//  Created by Ali on 20/12/2025.
//

import UIKit




class PaymentViewController: UIViewController {

    
       @IBOutlet weak var paymentCardView: UIView!
       @IBOutlet weak var paymentImageView: UIImageView!
       @IBOutlet weak var paymentTitleLabel: UILabel!
       @IBOutlet weak var paymentProviderLabel: UILabel!
       @IBOutlet weak var paymentDateLabel: UILabel!
       @IBOutlet weak var paymentTimeLabel: UILabel!
       @IBOutlet weak var creditOption: RadiobuttonView!
       @IBOutlet weak var applePayOption: RadiobuttonView!
       @IBOutlet weak var cashOption: RadiobuttonView!

    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var subtotalLabel: UILabel!
       @IBOutlet weak var proceedButton: UIButton!
       var selectedPayment: RadiobuttonView?

    override func viewDidLoad() {
           super.viewDidLoad()
        setupProceedButton()
           paymentImageView.layer.cornerRadius = 12
           paymentImageView.layer.masksToBounds = true
           paymentImageView.layer.borderWidth = 1
           paymentImageView.layer.borderColor = UIColor.systemGray4.cgColor

           makeCircular(providerImageView)

           creditOption.titleLabel.text = "Credit / Debit Card"
           applePayOption.titleLabel.text = "Apple Pay"
           cashOption.titleLabel.text = "Cash"

       
           creditOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMethod)))
           applePayOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMethod)))
           cashOption.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectMethod)))

           
           paymentCardView.layer.cornerRadius = 12
           paymentCardView.layer.borderWidth = 1
           paymentCardView.layer.borderColor = UIColor.systemGray4.cgColor
           paymentCardView.layer.shadowOpacity = 0.08
           paymentCardView.layer.shadowOffset = CGSize(width: 0, height: 3)
           paymentCardView.layer.shadowRadius = 6
       }
    func setupProceedButton() {
        proceedButton.layer.cornerRadius = 12
           proceedButton.clipsToBounds = true
           proceedButton.isEnabled = false
           proceedButton.backgroundColor = .systemGray4
           proceedButton.setTitleColor(.black, for: .disabled)
    }

    @objc func selectMethod(_ sender: UITapGestureRecognizer) {
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



    @IBAction func payNowTapped(_ sender: Any) {
           performSegue(withIdentifier: "toReceiptPage", sender: self)
       }
    
    func makeCircular(_ imageView: UIImageView) {
        imageView.layoutIfNeeded()
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
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
