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

        Service(
            id: "S001",
            category: "Beauty",
            description: "Professional men's haircut including wash and styling.",
            duration: 30,
            image: "haircut",
            providerID: "P100",
            title: "Men's Haircut",
            price: 15.0,
            rating: 4.5
        ),

        Service(
            id: "S002",
            category: "Beauty",
            description: "Relaxing full body massage by certified therapists.",
            duration: 60,
            image: "massage",
            providerID: "P101",
            title: "Full Body Massage",
            price: 50.0,
            rating: 4.9
        ),

        Service(
            id: "S003",
            category: "Beauty",
            description: "Facial treatment to cleanse and rejuvenate skin.",
            duration: 45,
            image: "facial",
            providerID: "P102",
            title: "Facial Treatment",
            price: 40.0,
            rating: 4.7
        ),

        Service(
            id: "S004",
            category: "Home",
            description: "Deep home cleaning service for apartments and villas.",
            duration: 120,
            image: "cleaning",
            providerID: "P200",
            title: "Home Cleaning",
            price: 80.0,
            rating: 4.6
        ),

        Service(
            id: "S005",
            category: "Auto",
            description: "Complete car wash including interior and exterior.",
            duration: 45,
            image: "carwash",
            providerID: "P300",
            title: "Car Wash",
            price: 10.0,
            rating: 4.3
        ),

        Service(
            id: "S006",
            category: "Education",
            description: "One-on-one math tutoring for high school students.",
            duration: 60,
            image: "tutoring",
            providerID: "P400",
            title: "Math Tutoring",
            price: 25.0,
            rating: 4.8
        )
    ]

    var categories: [Category] = []
    var filteredServices: [Service] = []
    
    var isPriceAscending = true
    var isRatingAscending = false
    var isTitleAscending = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag
        
        // Horizontal scrolling layout for categories
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Load categories from Firebase
        Task {
            do {
                categories = try await CategoriesController().getAllCategories()
                print("Fetched categories:", categories.map { $0.title })
                categoryCollectionView.reloadData()
            } catch {
                print("Failed to fetch categories:", error.localizedDescription)
            }
        }
        
        // Load your services here (replace with your actual data)
        filteredServices = allServices
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - TableView Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let service = filteredServices[indexPath.row]
        cell.textLabel?.text = service.title
        cell.detailTextLabel?.text = "Price: $\(service.price) | Rating: \(service.rating)"
        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredServices = allServices
            noResultsLabel.isHidden = true
        } else {
            filteredServices = allServices.filter {
                $0.title.lowercased().contains(searchText.lowercased())
            }
            noResultsLabel.isHidden = !filteredServices.isEmpty
        }
        tableView.reloadData()
        updateFilterButtonVisibility()
    }

    func updateFilterButtonVisibility() {
        filterButton.isEnabled = !filteredServices.isEmpty
        filterButton.tintColor = filteredServices.isEmpty ? .clear : nil
    }

    @IBAction func filterTapped(_ sender: UIButton) {
        showFilterOptions()
    }

    func showFilterOptions() {
        let priceTitle = isPriceAscending ? "Price (Low → High)" : "Price (High → Low)"
        let ratingTitle = isRatingAscending ? "Rating (Low → High)" : "Rating (High → Low)"
        let titleTitle = isTitleAscending ? "Title (A-Z)" : "Title (Z-A)"
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: priceTitle, style: .default) { _ in self.sortByPrice() })
        alert.addAction(UIAlertAction(title: ratingTitle, style: .default) { _ in self.sortByRating() })
        alert.addAction(UIAlertAction(title: titleTitle, style: .default) { _ in self.sortByTitle() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func sortByPrice() {
        filteredServices.sort { isPriceAscending ? $0.price < $1.price : $0.price > $1.price }
        isPriceAscending.toggle()
        tableView.reloadData()
    }

    func sortByRating() {
        filteredServices.sort { isRatingAscending ? $0.rating < $1.rating : $0.rating > $1.rating }
        isRatingAscending.toggle()
        tableView.reloadData()
    }

    func sortByTitle() {
        filteredServices.sort {
            isTitleAscending ? $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                             : $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending
        }
        isTitleAscending.toggle()
        tableView.reloadData()
    }

    // MARK: - CollectionView Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryCell",
            for: indexPath
        ) as! CategoryCell
        
        let category = categories[indexPath.item]
        cell.categoryTitleLabel.text = category.title
        cell.categoryID = category.id

        // ===== Direct styling =====
        cell.contentView.backgroundColor = UIColor.systemGray6
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.systemGray3.cgColor

        cell.categoryTitleLabel.textAlignment = .center
        cell.categoryTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.categoryTitleLabel.textColor = UIColor.label
        cell.categoryTitleLabel.numberOfLines = 1
        cell.categoryTitleLabel.adjustsFontSizeToFitWidth = true  // shrink text if too long
        cell.categoryTitleLabel.minimumScaleFactor = 0.5         // minimum shrink

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        print("Tapped category:", category.title) 
        filterServices(by: category)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let title = categories[indexPath.item].title
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let titleWidth = title.size(withAttributes: [.font: font]).width

        let cellWidth = titleWidth + 24  // 12 pts padding on each side
        return CGSize(width: cellWidth, height: 32)
    }

    // MARK: - Filter services by category
    func filterServices(by category: Category) {
        filteredServices = allServices.filter { $0.category == category.title }
        tableView.reloadData()
        noResultsLabel.isHidden = !filteredServices.isEmpty
        updateFilterButtonVisibility()
    }
}
