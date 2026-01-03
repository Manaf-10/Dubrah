//
//  NewPostsViewController.swift
//  Dubrah
//
//  Created by mohammed ali on 01/01/2026.
//

import UIKit

class MyPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var services = [Service]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        Task {
            do {
                services = try await ServiceController.shared.getAllServices()
                
                await MainActor.run {
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    let errorAlert = UIAlertController(
                        title: "Fetch Error",
                        message: "We couldn't load the services: \(error.localizedDescription)",
                        preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MyPostsTableViewCell
        
        let data = services[indexPath.row]
        var averageRating:Double? = nil
        let reviews = data.reviews
        
        if !reviews.isEmpty {
            let totalSum = reviews.reduce(0) {$0 + $1.rate}
             averageRating = Double(totalSum) / Double(reviews.count)
        }

        cell.setupCell(photoURL: data.image, title: data.title, desc: data.description, price: data.price, rating: averageRating)
        
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(editBtnTapped(sender:)), for: .touchUpInside)
        return cell
    }
    
    
    @objc func editBtnTapped(sender: UIButton) {
        let index = sender.tag
        let selectedService = services[index]
        
        performSegue(withIdentifier: "goToNewPost", sender: selectedService)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToNewPost" {
            if let destinationVC = segue.destination as? NewPostViewController {
                if let serviceToEdit = sender as? Service {
                    destinationVC.selectedService = serviceToEdit
                    destinationVC.isEditMode = true
                } else {
                    destinationVC.isEditMode = false
                }
            }
        }
    }
    
    
    @IBAction func addPostBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToNewPost", sender: nil)
    }
    

}
