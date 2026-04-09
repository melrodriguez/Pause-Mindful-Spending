import SwiftUI
import FirebaseFirestore

// Handles logic for adding, editing, and deleting categories

class CategoriesViewModel: ObservableObject {
    private let firestoreService = FireStoreService()
    
    // Use this list for the cells
    @Published var categories: [String] = []
    @Published var errorMessage: String? = nil
    
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
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        
        let alreadyExists = categories.contains {
            $0.lowercased() == trimmed.lowercased()
        }
 
        if alreadyExists {
            errorMessage = "A category with that name already exists."
            return
        }
        
        errorMessage = nil
 
        firestoreService.addCategory(uid: uid, name: trimmed, enableStreak: enableStreak) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.errorMessage = nil
                self.categories.append(trimmed)
            } else {
                self.errorMessage = "A category with that name already exists."
            }
        }
    }

    func pressedEditButton(uid: String, oldName: String, newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
 
        if trimmed.lowercased() == oldName.lowercased() {
            return
        }
 
        let alreadyExists = categories.contains {
            $0.lowercased() == trimmed.lowercased()
        }
 
        if alreadyExists {
            errorMessage = "A category with that name already exists."
            return
        }
        
        errorMessage = nil
 
        firestoreService.fetchCategoryIdUsingName(uid: uid, name: oldName) { [weak self] categoryId in
            guard let self = self, let categoryId = categoryId else { return }
 
            self.firestoreService.changeCategoryName(
                uid: uid,
                categoryId: categoryId,
                newName: trimmed
            )
 
            DispatchQueue.main.async {
                if let idx = self.categories.firstIndex(of: oldName) {
                    self.categories[idx] = trimmed
                }
                self.errorMessage = nil
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

