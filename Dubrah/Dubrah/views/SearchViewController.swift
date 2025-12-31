//
//  SearchViewController.swift
//  Dubrah
//

import UIKit

class SearchViewController: UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UISearchBarDelegate,
                            UICollectionViewDelegate,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let allServices: [Service] = [
        Service(id: "S001", category: "Beauty", description: "Professional men's haircut including wash and styling.", duration: 30, image: "haircut", providerID: "P100", title: "Men's Haircut", price: 15.0, rating: 4.5),
        Service(id: "S002", category: "Beauty", description: "Relaxing full body massage by certified therapists.", duration: 60, image: "massage", providerID: "P101", title: "Full Body Massage", price: 50.0, rating: 4.9),
        Service(id: "S003", category: "Beauty", description: "Facial treatment to cleanse and rejuvenate skin.", duration: 45, image: "facial", providerID: "P102", title: "Facial Treatment", price: 40.0, rating: 4.7),
        Service(id: "S004", category: "Home", description: "Deep home cleaning service for apartments and villas.", duration: 120, image: "cleaning", providerID: "P200", title: "Home Cleaning", price: 80.0, rating: 4.6),
        Service(id: "S005", category: "Auto", description: "Complete car wash including interior and exterior.", duration: 45, image: "carwash", providerID: "P300", title: "Car Wash", price: 10.0, rating: 4.3),
        Service(id: "S006", category: "Education", description: "One-on-one math tutoring for high school students.", duration: 60, image: "tutoring", providerID: "P400", title: "Math Tutoring", price: 25.0, rating: 4.8)
    ]

    var categories: [Category] = []
    var filteredServices: [Service] = []
    
    var isPriceAscending = true
    var isRatingAscending = false
    var isTitleAscending = true
    var selectedCategoryIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        // Horizontal scrolling layout for categories
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Load categories
        Task {
            do {
                categories = try await CategoriesController().getAllCategories()
                categoryCollectionView.reloadData()
            } catch {
                print("Failed to fetch categories:", error.localizedDescription)
            }
        }
        
        filteredServices = allServices
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as? ServiceTableViewCell else {
            return UITableViewCell()
        }

        let service = filteredServices[indexPath.row]
        cell.configure(with: service)
        return cell
    }

    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredServices = allServices
            noResultsLabel.isHidden = true
        } else {
            filteredServices = allServices.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            noResultsLabel.isHidden = !filteredServices.isEmpty
        }
        tableView.reloadData()
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.item]
        cell.categoryTitleLabel.text = category.title

        // Highlight selected
        if indexPath == selectedCategoryIndex {
            cell.contentView.backgroundColor = .systemBlue
            cell.categoryTitleLabel.textColor = .white
        } else {
            cell.contentView.backgroundColor = .systemGray6
            cell.categoryTitleLabel.textColor = .label
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath
        let category = categories[indexPath.item]
        filterServices(by: category)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = categories[indexPath.item].title
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let width = title.size(withAttributes: [.font: font]).width + 24
        return CGSize(width: width, height: 32)
    }

    // MARK: - Filter
    func filterServices(by category: Category) {
        filteredServices = allServices.filter { $0.category == category.title }
        tableView.reloadData()
        noResultsLabel.isHidden = !filteredServices.isEmpty
    }
}
