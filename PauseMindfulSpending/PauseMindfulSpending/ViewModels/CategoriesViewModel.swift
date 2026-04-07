import SwiftUI
import FirebaseFirestore

// Handles logic for adding, editing, and deleting categories

class CategoriesViewModel: ObservableObject {
    private let firestoreService = FireStoreService()
    
    // Use this list for the cells
    @Published var categories: [String] = []
    
    // Get category names list for display
    func getCategoryNames(uid: String) {
        firestoreService.fetchCategoryList(uid: uid) { [weak self] categoryIds in
            guard let self = self else { return }
           
            var fetchedCategories: [String] = []
            
            // Run a group of threads instead of just one
            let group = DispatchGroup()
        
            for categoryId in categoryIds {
                group.enter()
                
                firestoreService.fetchCategoryStringUsingId(uid: uid, categoryId: categoryId) { categoryName in
                    // Add category name to master list
                    if let categoryName = categoryName {
                        fetchedCategories.append(categoryName)
                    }
                    group.leave()
                }
            }
           
            // Update categories once we get all of the names
            group.notify(queue: .main) {
                self.categories = fetchedCategories
            }
        }
    }
    
    func pressedAddButton(uid: String, name: String, enableStreak: Bool) {
        firestoreService.addCategory(uid: uid, name: name, enableStreak: enableStreak, categories: categories)
    }
    
    //TODO: Make a listener in Dashboard repo, so we don't have to duplicate this function
    func generateUniqueCatgoryName(base: String) -> String {
        let trimmed = base.trimmingCharacters(in: .whitespaces)
        let lowercased = trimmed.lowercased()
        
        var usedNumbers = Set<Int>()
        
        for name in categories {
            let lower = name.lowercased()
            guard lower.hasPrefix(lowercased) else { continue }
            
            let suffix = lower.dropFirst(lowercased.count)
            
            if suffix.isEmpty {
                usedNumbers.insert(0)
            } else if let num = Int(suffix) {
                usedNumbers.insert(num)
            }
        }
        
        if !usedNumbers.contains(0) {
            return trimmed
        }
        
        var i = 1
        
        while true {
            if !usedNumbers.contains(i) {
                return "\(trimmed)\(i)"
            }
            
            i += 1
        }
    }

    func pressedEditButton(uid: String, oldName: String, newName: String) {
        firestoreService.fetchCategoryIdUsingName(uid: uid, name: oldName) { [weak self] categoryId in
            guard let self = self else { return }
            guard let categoryId = categoryId else { return }

            // Actually change the category name
            firestoreService.changeCategoryName(uid: uid, categoryId: categoryId, name: newName, categories: categories)

            // Update the UI
            DispatchQueue.main.async {
                if let idx = self.categories.firstIndex(of: oldName) {
                    self.categories[idx] = self.generateUniqueCatgoryName(base: newName)
                }
            }
            
        }
    }
    
    func pressedDeleteButton(uid: String, name: String) {
        firestoreService.fetchCategoryIdUsingName(uid: uid, name: name) { [weak self] categoryId in
            guard let self = self else { return }
            guard let categoryId = categoryId else { return }

            // Actually change the category name
            firestoreService.deleteCategory(uid: uid, categoryId: categoryId)

            // Update the categories available
            DispatchQueue.main.async {
                if let index = self.categories.firstIndex(of: name) {
                    self.categories.remove(at: index)
                }
            }
            
            // Set item's current category to a blank category
            firestoreService.fetchItemsInCategory(uid: uid, categoryId: categoryId) { itemIds in
               for itemId in itemIds {
                self.firestoreService.updateItem(uid: uid, itemId: itemId, fieldsToUpdate: [
                    "categoryId": FieldValue.delete() // Remove the category
                ])
               }
           }
        }
        
    }
    
}

