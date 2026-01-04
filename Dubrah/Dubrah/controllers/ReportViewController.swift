//
//  ReportViewController.swift
//  Dubrah
//
//  Created by mohammed ali on 03/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ReportViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate{
    
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var reportTypeSegment: UISegmentedControl!
    @IBOutlet weak var submitButton: UIButton!
    
    var userOrders: [(id: String, title: String, imageUrl: String?, date: Date?)] = []
    var selectedOrderId: String?
    var selectedOrderImageUrl: String?
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 8
        
        descriptionView.layer.borderWidth = 1.0
        descriptionView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionView.layer.cornerRadius = 8
        descriptionView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        
        setupPicker()
        fetchUserOrders()
        
        titleField.placeholder = "Enter report title"
        descriptionView.delegate = self
        
        orderButton.setTitle("Select Order", for: .normal)
        reportTypeSegment.selectedSegmentIndex = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearForm()
    }
    func clearForm() {
        // Clear text fields
        titleField.text = ""
        descriptionView.text = ""
        descriptionView.textColor = .black
        
        // Reset order selection
        selectedOrderId = nil
        selectedOrderImageUrl = nil
        orderButton.setTitle("Select Order", for: .normal)
        
        // Reset segment control
        reportTypeSegment.selectedSegmentIndex = 0
        
        // Reset submit button
        submitButton.isEnabled = true
        submitButton.setTitle("Submit Report", for: .normal)
    }
    
    func setupPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: false)
        
        orderButton.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
    }
    
    @objc func showPicker() {
        let alert = UIAlertController(title: "Select Order", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        pickerView.frame = CGRect(x: 0, y: 50, width: 270, height: 100)
        alert.view.addSubview(pickerView)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            self.donePicker()
        }))
        present(alert, animated: true)
    }
    
    @objc func donePicker() {
        let selected = pickerView.selectedRow(inComponent: 0)
            if selected < userOrders.count {
                let order = userOrders[selected]
                selectedOrderId = order.id
                selectedOrderImageUrl = order.imageUrl
                orderButton.setTitle(order.title, for: .normal)
            }
    }
    
    func fetchUserOrders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
         
         Firestore.firestore().collection("orders")
             .whereField("userID", isEqualTo: userId)
             .getDocuments { snapshot, error in
                 guard let documents = snapshot?.documents else { return }
                 
                 self.userOrders = documents.compactMap { doc in
                     let data = doc.data()
                     let serviceName = data["serviceName"] as? String ?? "Service"
                     let imageUrl = data["serviceImageUrl"] as? String
                     
                     // Get order date
                     var orderDate: Date?
                     if let timestamp = data["orderDate"] as? Timestamp {
                         orderDate = timestamp.dateValue()
                     }
                     
                     // Format the title with date
                     var displayTitle = serviceName
                     if let date = orderDate {
                         let formatter = DateFormatter()
                         formatter.dateFormat = "MMM d, yyyy" // e.g., "Jan 3, 2026"
                         displayTitle = "\(serviceName) - \(formatter.string(from: date))"
                     }
                     
                     return (id: doc.documentID, title: displayTitle, imageUrl: imageUrl, date: orderDate)
                 }
                 
                 // Sort by date (most recent first)
                 self.userOrders.sort { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
                 
                 self.pickerView.reloadAllComponents()
             }
    }
    
    @IBAction func submitReport(_ sender: Any) {
        // Validate title
        guard let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            showAlert(message: "Please enter a report title")
            return
        }
        
        // Validate title length (minimum 5 characters)
        guard title.count >= 5 else {
            showAlert(message: "Title must be at least 5 characters")
            return
        }
        
        // Validate description
        guard let description = descriptionView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !description.isEmpty else {
            showAlert(message: "Please enter a description")
            return
        }
        
        // Validate description length (minimum 10 characters)
        guard description.count >= 10 else {
            showAlert(message: "Description must be at least 10 characters")
            return
        }
        
        // Validate order selection
        guard let orderId = selectedOrderId else {
            showAlert(message: "Please select an order to report")
            return
        }
        
        // Validate user authentication
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not authenticated")
            return
        }
        
        // All validations passed - proceed with submission
        let reportType = reportTypeSegment.selectedSegmentIndex == 0 ? "service" : "provider"
        let reportId = UUID().uuidString
        
        let report = Report(
            reportId: reportId,
            userId: userId,
            orderId: orderId,
            reportType: reportType,
            title: title,
            description: description,
            status: "pending",
            createdAt: Date()
        )
        
        // Disable button to prevent double submission
        submitButton.isEnabled = false
        submitButton.setTitle("Submitting...", for: .normal)
        
        Firestore.firestore().collection("Report").document(reportId).setData(report.dictionary) { error in
            // Re-enable button
            self.submitButton.isEnabled = true
            self.submitButton.setTitle("Submit Report", for: .normal)
            
            if let error = error {
                self.showAlert(message: "Error submitting report: \(error.localizedDescription)")
            } else {
                print("TESTING ")
                Task {
                    do {
                        // Fetch the order document to get the provider ID
                        let orderDoc = try await Firestore.firestore().collection("orders").document(orderId).getDocument()
                        
                        if let providerId = orderDoc.data()?["providerID"] as? String {
                            // Send notification to the provider
                            print("TESTING 1 \(providerId) ")
                            await NotificationController.shared.newNotification(
                                receiverId: providerId,
                                senderId: reportSystemID,
                                type: .report
                            )
                            print("TESTING  2")
                        }
                        
                        await MainActor.run {
                            self.showSuccessAlert()
                        }
                    } catch {
                        await MainActor.run {
                            // Still show success for report, but log notification error
                            print("Report saved but notification failed: \(error.localizedDescription)")
                            self.showSuccessAlert()
                        }
                    }
                }
            }
        }
    }
    
    func showSuccessAlert() {
        let alert = UIAlertController(
            title: "Report Submitted",
            message: "Your report will be reviewed and you will be contacted shortly.",
            preferredStyle: .alert
        )
        present(alert, animated: true)
        
        // Auto-dismiss after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true) {
                self.clearForm()
                // Go back after alert is dismissed
                if let navController = self.navigationController {
                    navController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - PickerView
    // MARK: - PickerView DataSource & Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return userOrders.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let order = userOrders[row]
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        
        // Image view
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.backgroundColor = .lightGray
        
        if let urlString = order.imageUrl, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }.resume()
        }
        
        // Label
        let label = UILabel(frame: CGRect(x: 45, y: 0, width: 200, height: 40))
        label.text = order.title
        label.font = UIFont.systemFont(ofSize: 14)
        
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        return containerView
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    
}
