//
//  OrderHistoryViewController.swift
//  Dubrah
//
//  Created by Ali on 29/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class OrderHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var tableView: UITableView!
    

    private var orders: [Order] = []

    override func viewDidLoad() {
        tableView.allowsSelection = false
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchOrders()
    }
    
    private func fetchOrders() {
           guard let userId = Auth.auth().currentUser?.uid else {
               print("❌ No logged-in user")
               return
           }
        
           Task {
               do {
                   let fetchedOrders = try await OrderController.shared.getOrdersByUser(userID: userId)

                   await MainActor.run {
                       self.orders = fetchedOrders
                       self.tableView.reloadData()
                   }

                   print("Orders loaded:", fetchedOrders.count)

               } catch {
                   print("Failed to fetch orders:", error.localizedDescription)
               }
           }
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "OrderHisCell",
            for: indexPath
        ) as! OrderHistoryCell

        let order = orders[indexPath.row]
        cell.configure(order)

        cell.rateButton.tag = indexPath.row
        cell.rateButton.addTarget(self, action: #selector(rateTapped(_:)), for: .touchUpInside)

        cell.viewDetailsButton.tag = indexPath.row
        cell.viewDetailsButton.addTarget(self, action: #selector(viewDetailsTapped(_:)), for: .touchUpInside)

        return cell
    }
    
    

    @objc private func rateTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toServiceReview", sender: orders[sender.tag])
    }

    @objc private func viewDetailsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toOrderDetails", sender: orders[sender.tag])
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toOrderDetails",
           let order = sender as? Order,
           let vc = segue.destination as? OrderDetailsViewController {

            vc.order = order
            return
        }

        if segue.identifier == "toServiceReview",
           let order = sender as? Order,
           let vc = segue.destination as? ServiceRatingViewController {

            vc.order = order
            return
        }
    }

}
