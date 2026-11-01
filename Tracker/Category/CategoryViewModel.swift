import UIKit

// MARK: - CategoryViewModel

final class CategoryViewModel {
    
    // MARK: - Properties
    
    var onCategoriesUpdated: (() -> Void)?
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?()
        }
    }
    
    // MARK: - Initializers
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        fetchCategories()
    }
    
    // MARK: - Public Methods
    
    func fetchCategories() {
        self.categories = categoryStore.categories
    }
    
    func addCategory(title: String) {
        try? categoryStore.addCategory(title: title)
        fetchCategories()
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String {
        return categories[indexPath.row].title
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidChangeCategories() {
        fetchCategories()
    }
}

