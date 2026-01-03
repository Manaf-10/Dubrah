//
//  RequestsViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 23/12/2025.
//

import UIKit

class AdminRequestsViewController: AdminBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var arrRequests: [Request] = Request.allRequests

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitle("Requests")
        setupNavigationAppearance()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
//           setTabBarHidden(false)
        showTabBar()

       }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            // Ensure tab bar is visible
            showTabBar()
        }
    
    

    // MARK: - TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrRequests.count
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestsTableViewCell
        let request = arrRequests[indexPath.section]
        cell.setupCell(photo: request.photo, name: request.username, role: request.role)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8 // spacing below each cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let detailVC = UIStoryboard(name: "Requests", bundle: nil)
//            .instantiateViewController(withIdentifier: "UserRequestViewController")
//        
//        // 🔑 THIS is the important line
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
    
    
    
}
