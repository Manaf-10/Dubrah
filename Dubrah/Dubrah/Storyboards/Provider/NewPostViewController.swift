//
//  NewPostViewController.swift
//  Dubrah
//
//  Created by mohammed ali on 01/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var categoryButton: UIButton!
    
    @IBOutlet weak var creditCardButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var cashButton: UIButton!
    private var selectedPaymentMethods: Set<String> = []
    
    @IBOutlet weak var imgPhoto: UIImageView!
    
    @IBOutlet weak var titleTxtBox: UITextField!
    @IBOutlet weak var descTxtBox: UITextField!
    @IBOutlet weak var PriceTxtBox: UITextField!
    
    private var categories: [Category] = []
    private var selectedCategory: Category?
    private let db = Firestore.firestore()
    
    var selectedService: Service?
    var isEditMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupPaymentButtons()
        
        if isEditMode {
            setupEditMode()
        }
        
        fetchCategories()
    }
    
    private func setupEditMode() {
            self.title = "Edit Post"
           
           let deleteButton = UIBarButtonItem(
               image: UIImage(systemName: "trash"),
               style: .plain,
               target: self,
               action: #selector(deleteButtonTapped)
           )
           deleteButton.tintColor = UIColor.systemRed
           navigationItem.rightBarButtonItem = deleteButton
           
           saveButton.setTitle("Update", for: .normal)
       }
    
    @objc private func deleteButtonTapped() {
           let alert = UIAlertController(
               title: "Delete Post",
               message: "Are you sure you want to delete this Post? This action cannot be undone.",
               preferredStyle: .alert
           )
           
           let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
               self.deleteService()
           }
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
           
           alert.addAction(deleteAction)
           alert.addAction(cancelAction)
           
           present(alert, animated: true)
       }
       
       // MARK: - Delete Service ⭐
       private func deleteService() {
           guard let service = selectedService else { return }
           
           // Show loading
           let loadingAlert = UIAlertController(title: "Deleting...", message: nil, preferredStyle: .alert)
           present(loadingAlert, animated: true)
           
           Task {
               do {
                   try await ServiceController.shared.deleteService(id: service.id)
                   
                   await MainActor.run {
                       loadingAlert.dismiss(animated: true) {
                           let successAlert = UIAlertController(
                               title: "Success",
                               message: "Post deleted successfully",
                               preferredStyle: .alert
                           )
                           successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                               self.navigationController?.popViewController(animated: true)
                           })
                           self.present(successAlert, animated: true)
                       }
                   }
               } catch {
                   await MainActor.run {
                       loadingAlert.dismiss(animated: true) {
                           let errorAlert = UIAlertController(
                               title: "Error",
                               message: "Failed to delete Post: \(error.localizedDescription)",
                               preferredStyle: .alert
                           )
                           errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                           self.present(errorAlert, animated: true)
                       }
                   }
               }
           }
       }
    
    private func setupUI() {
        saveButton.layer.cornerRadius = 18
        saveButton.layer.masksToBounds = true
                
        imgPhoto.layer.cornerRadius = 18
        imgPhoto.clipsToBounds = true
        
        categoryButton.contentHorizontalAlignment = .left
    }
    
       
       // MARK: - Fetch Categories
    private func fetchCategories() {
        // Disable button and show loading state
        categoryButton.setTitle("Loading...", for: .normal)
        categoryButton.isEnabled = false
        Task {
            do {
                let fetchedCategories = try await CategoriesController.shared.getAllCategories()
                await MainActor.run {
                    self.categories = fetchedCategories.sorted { $0.title < $1.title }
                    
                    // Check if we got categories
                    if self.categories.isEmpty {
                        self.categoryButton.setTitle("No categories available", for: .normal)
                        self.categoryButton.isEnabled = false
                    } else {
                        self.categoryButton.setTitle("Select Category", for: .normal)
                        self.createCategoryMenu()
                        self.categoryButton.isEnabled = true
                        
                        if self.isEditMode {
                           self.populateFieldsForEditing()
                       }
                    }
                }
            } catch {
                print("Error fetching categories: \(error.localizedDescription)")
                await MainActor.run {
                    self.categoryButton.setTitle("Failed to load categories", for: .normal)
                    self.categoryButton.isEnabled = false
                }
            }
        }
    }
    
       private func populateFieldsForEditing() {
           guard let service = selectedService else { return }
           
           titleTxtBox.text = service.title
           descTxtBox.text = service.description
           PriceTxtBox.text = "\(service.price)"
           
           if let category = categories.first(where: { $0.title == service.category }) {
               selectCategory(category)
           }
           
           selectedPaymentMethods = Set(service.paymentMethods)
           updatePaymentButtonsUI()
           
           if !service.image.isEmpty {
               loadImage(from: service.image)
           }
       }
       
       private func updatePaymentButtonsUI() {
           updatePaymentButton(creditCardButton, title: "Credit/Debit Card")
           updatePaymentButton(applePayButton, title: "Apple Pay")
           updatePaymentButton(cashButton, title: "Cash")
       }
       
       private func updatePaymentButton(_ button: UIButton, title: String) {
           guard var config = button.configuration else { return }
           
           if selectedPaymentMethods.contains(title) {
               config.image = UIImage(named: "checkbox_selected")
           } else {
               config.image = UIImage(named: "checkbox")
           }
           
           button.configuration = config
       }
       
       private func loadImage(from urlString: String) {
           guard let url = URL(string: urlString) else { return }
           
           URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               guard let data = data, let image = UIImage(data: data) else { return }
               
               DispatchQueue.main.async {
                   self?.imgPhoto.image = image
                   self?.imgPhoto.contentMode = .scaleAspectFill
                   self?.imgPhoto.backgroundColor = .white
               }
           }.resume()
       }
    
       private func createCategoryMenu() {
           let menuItems = categories.map { category in
               UIAction(title: category.title) { [weak self] _ in
                   self?.selectCategory(category)
               }
           }
           categoryButton.menu = UIMenu(children: menuItems)
           categoryButton.showsMenuAsPrimaryAction = true
           categoryButton.isEnabled = true
       }
       
       // MARK: - Select Category
       private func selectCategory(_ category: Category) {
           selectedCategory = category
           categoryButton.setTitle(category.title, for: .normal)
           categoryButton.setTitleColor(.label, for: .normal)
       }
       
    
    
    private func configurePaymentButton(_ button: UIButton, title: String) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(named: "checkbox")
        config.imagePadding = 10
        config.imagePlacement = .leading
        config.baseForegroundColor = .label

        button.configuration = config
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(paymentMethodTapped), for: .touchUpInside)
    }
    
    
    private func setupPaymentButtons() {
        configurePaymentButton(creditCardButton, title: "Credit/Debit Card")
        configurePaymentButton(applePayButton, title: "Apple Pay")
        configurePaymentButton(cashButton, title: "Cash")
        }
    
    
    
    @objc func paymentMethodTapped(_ sender: UIButton) {
        guard var config = sender.configuration,
                  let title = config.title, !title.isEmpty else {  return }
            
            
            if selectedPaymentMethods.contains(title) {
                // Deselect
                selectedPaymentMethods.remove(title)
                config.image = UIImage(named: "checkbox")
            } else {
                // Select
                selectedPaymentMethods.insert(title)
                config.image = UIImage(named: "checkbox_selected")
            }
            
            sender.configuration = config
    }
    
    func getSelectedPaymentMethods() -> [String] {
            return Array(selectedPaymentMethods)
        }
    
    @IBAction func addImageBtnClick(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: {actiopn in
            self.getPhoto(type: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Choose From Gallary", style: .default, handler: {actiopn in
            self.getPhoto(type: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func getPhoto(type: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            print("Image not found")
            return
        }
        imgPhoto.image = image
        imgPhoto.contentMode = .scaleAspectFill
        imgPhoto.layer.cornerRadius = 18
        imgPhoto.clipsToBounds = true
        imgPhoto.backgroundColor = .white
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func SaveBtn(_ sender: Any) {
        
            guard validateForm() else { return }
        
            let confirmMessage = isEditMode ? "Are you sure you want to update this service?" : "Are you sure you want to save this service?"
            let confirmTitle = isEditMode ? "Confirm Update" : "Confirm Save"
         
        
        let confirmAlert = UIAlertController(
                  title: confirmTitle,
                  message: confirmMessage,
                  preferredStyle: .alert
              )
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                    if self.isEditMode {
                        self.startUpdatingProcess()
                    } else {
                        self.startSavingProcess()
                    }
                }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
               
               confirmAlert.addAction(confirmAction)
               confirmAlert.addAction(cancelAction)
               
               present(confirmAlert, animated: true)
        }

    private func startUpdatingProcess() {
           guard let service = selectedService else { return }
           
           saveButton.isEnabled = false
           saveButton.setTitle("Updating...", for: .normal)
           
           Task {
               do {
                   let title = titleTxtBox.text!.trimmingCharacters(in: .whitespaces)
                   let description = descTxtBox.text!.trimmingCharacters(in: .whitespaces)
                   let price = Double(PriceTxtBox.text!.trimmingCharacters(in: .whitespaces))!
                   let category = selectedCategory!
                   let paymentMethods = Array(selectedPaymentMethods)
                   
                   let updatedData: [String: Any] = [
                       "title": title,
                       "description": description,
                       "price": price,
                       "category": category.title,
                       "paymentMethod": paymentMethods
                   ]
                   
                   try await ServiceController.shared.editService(id: service.id, updatedData: updatedData)
                   
                   // Upload new image if changed
                   if let newImage = imgPhoto.image {
                       MediaManager.shared.uploadProfilePicture(image: newImage, documentID: service.id)
                   }
                   
                   await MainActor.run {
                       self.saveButton.isEnabled = true
                       self.saveButton.setTitle("Update", for: .normal)
                       
                       let successAlert = UIAlertController(
                           title: "Success",
                           message: "Your service has been updated!",
                           preferredStyle: .alert
                       )
                       successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                           self.navigationController?.popViewController(animated: true)
                       })
                       self.present(successAlert, animated: true)
                   }
                   
               } catch {
                   await MainActor.run {
                       self.saveButton.isEnabled = true
                       self.saveButton.setTitle("Update", for: .normal)
                       
                       let errorAlert = UIAlertController(
                           title: "Error",
                           message: "Failed to update service: \(error.localizedDescription)",
                           preferredStyle: .alert
                       )
                       errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                       self.present(errorAlert, animated: true)
                   }
               }
           }
       }
        private func startSavingProcess() {
            saveButton.isEnabled = false
            saveButton.setTitle("Saving...", for: .normal)
            
            Task {
                do {
                    let title = titleTxtBox.text!.trimmingCharacters(in: .whitespaces)
                    let description = descTxtBox.text!.trimmingCharacters(in: .whitespaces)
                    let price = Double(PriceTxtBox.text!.trimmingCharacters(in: .whitespaces))!
                    let category = selectedCategory!
                    let paymentMethods = Array(selectedPaymentMethods)
                    let image = imgPhoto.image!
                    
                    let postData: [String: Any] = [
                        "title": title,
                        "description": description,
                        "price": price,
                        "category": category.title,
                        "paymentMethod": paymentMethods, // Using singular "paymentMethod"
                        "createdAt": FieldValue.serverTimestamp(),
                        "providerID": Auth.auth().currentUser?.uid ?? "",
                        "duration": 0,
                        "reviews": [], // Initialized as empty array
                        "image": ""
                    ]
                    
                    let serviceID = try await ServiceController.shared.addService(data: postData)
                    
                    MediaManager.shared.uploadProfilePicture(image: image, documentID: serviceID)
                    
                    await MainActor.run {
                        self.saveButton.isEnabled = true
                        self.saveButton.setTitle("Save", for: .normal)
                        
                        let successAlert = UIAlertController(
                            title: "Success",
                            message: "Your service has been created!",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self.navigationController?.popViewController(animated: true)
                        })
                        self.present(successAlert, animated: true)
                    }
                    
                } catch {
                    await MainActor.run {
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitle("Save", for: .normal)
                   
                    let errorAlert = UIAlertController(
                        title: "Error",
                        message: "Failed to save service: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    
    private func validateForm() -> Bool {
        var errorMessage = ""
        
        let title = titleTxtBox.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if title.isEmpty {
            errorMessage += "• Please enter a title\n"
        } else if title.count < 3 {
            errorMessage += "• Title must be at least 3 characters\n"
        }
        
        let description = descTxtBox.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if description.isEmpty {
            errorMessage += "• Please enter a description\n"
        } else if description.count < 3 {
            errorMessage += "• Description must be at least 3 characters\n"
        }
        
        if let priceText = PriceTxtBox.text?.trimmingCharacters(in: .whitespaces),
           !priceText.isEmpty {
            if Double(priceText) == nil {
                errorMessage += "• Please enter a valid price\n"
            }
        } else {
            errorMessage += "• Please enter a price\n"
        }
        
        if selectedCategory == nil {
            errorMessage += "• Please select a category\n"
        }
        
        if selectedPaymentMethods.isEmpty {
            errorMessage += "• Please select at least one payment method\n"
        }
        
        if imgPhoto.image == nil {
            errorMessage += "• Please add a photo\n"
        }
        
        if !errorMessage.isEmpty {
            showErrorAlert(message: errorMessage)
            return false
        }
        
        return true
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
