//
//  SearchViewController.swift
//  Dubrah
//
//  Created by BP-36-212-16N on 28/12/2025.
//

import UIKit

class SearchViewController: UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UISearchBarDelegate {

    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let allItems = [
        "Apple",
        "Banana",
        "Orange",
        "Mango",
        "Pineapple",
        "Grapes",
        "Strawberry"
    ]

    var filteredItems: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredItems = allItems
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = filteredItems[indexPath.row]
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredItems = allItems
            noResultsLabel.isHidden = true
        } else {
            filteredItems = allItems.filter {
                $0.lowercased().contains(searchText.lowercased())
            }
            noResultsLabel.isHidden = !filteredItems.isEmpty
        }

        tableView.reloadData()
    }

}
