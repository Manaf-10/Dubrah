//
//  CategoriesViewController.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 18/12/2025.
//

import UIKit
class CategoriesViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,CategoryCellDelegate{

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIButton!

    // MARK: - Data
    

    var filteredCategories: [Category] = []
    var isSearching = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // CollectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = UIColor(hex: "#F6F8F9")

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }

        // SearchBar styling (borderless)
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.borderStyle = .none
        searchBar.backgroundColor = .white

        // Button styling
        addButton.backgroundColor = .white
    }
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredCategories.count : categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryCell",
            for: indexPath
        ) as! CategoryCell

        let item = isSearching
            ? filteredCategories[indexPath.item]
            : categories[indexPath.item]

        cell.iconLabel.text = item.title
        cell.delegate = self
        
        return cell
    }

    // MARK: - CollectionView Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 2
        let spacing: CGFloat = 12
        let inset: CGFloat = 16

        let totalSpacing = (columns - 1) * spacing + inset * 2
        let width = (collectionView.bounds.width - totalSpacing) / columns

        return CGSize(width: width, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    

    // MARK: - SearchBar Logic (MATCHES MessagesViewController)
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            isSearching = false
            filteredCategories.removeAll()
        } else {
            isSearching = true
            filteredCategories = categories.filter {
                $0.title.lowercased().contains(text.lowercased())
            }
        }

        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func didTapDelete(on cell: CategoryCell) {

        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let alert = UIAlertController(
            title: "Delete Category",
            message: "Are you sure you want to delete this category?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in

            if self.isSearching {
                let item = self.filteredCategories.remove(at: indexPath.item)
                categories.removeAll { $0.title == item.title }
            } else {
                categories.remove(at: indexPath.item)
            }

            self.collectionView.reloadData()
        })

        present(alert, animated: true)
    }
    
    func didTapEdit(on cell: CategoryCell) {

        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let item = isSearching
            ? filteredCategories[indexPath.item]
            : categories[indexPath.item]

        let alert = UIAlertController(
            title: "Edit Category",
            message: "Enter a new name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = item.title
            textField.placeholder = "Category name"
            textField.autocapitalizationType = .words
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let newName = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !newName.isEmpty else { return }

            // Duplicate name check (case-insensitive, excluding current item)
            let nameExists = categories.contains {
                $0.title.lowercased() == newName.lowercased() &&
                $0.title.lowercased() != item.title.lowercased()
            }

            if nameExists {
                let errorAlert = UIAlertController(
                    title: "Name Already Exists",
                    message: "Please choose a different category name.",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }

            // Update data
            if self.isSearching {
                self.filteredCategories[indexPath.item] =
                    Category(title: newName)

                if let originalIndex = categories.firstIndex(where: {
                    $0.title == item.title
                }) {
                    categories[originalIndex] =
                        Category(title: newName)
                }
            } else {
                categories[indexPath.item] =
                    Category(title: newName)
            }

            self.collectionView.reloadData()
        })

        present(alert, animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {

        let alert = UIAlertController(
            title: "Add Category",
            message: "Enter a name and choose an image",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Category name"
            textField.autocapitalizationType = .words
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !name.isEmpty else { return }

            // 🔍 Duplicate check
            let nameExists = categories.contains {
                $0.title.lowercased() == name.lowercased()
            }

            if nameExists {
                let error = UIAlertController(
                    title: "Name Already Exists",
                    message: "Choose a different category name.",
                    preferredStyle: .alert
                )
                error.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(error, animated: true)
                return
            }

            let newCategory = Category(title: name)
            categories.append(newCategory)

            self.isSearching = false
            self.filteredCategories.removeAll()
            self.searchBar.text = nil

            self.collectionView.reloadData()
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(addAction)

        present(alert, animated: true)
    }

}
