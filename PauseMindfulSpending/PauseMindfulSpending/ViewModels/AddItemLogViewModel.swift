import SwiftUI
import PhotosUI
import FirebaseAuth

@MainActor
class AddItemLogViewModel: ObservableObject {
    
    private let repo = DashboardRepository()
    
    @Published var itemName: String = ""
    @Published var selectedCategory: String? = nil
    @Published var imageCaptured: UIImage? = nil
    @Published var selectedMood: String? = nil
    @Published var showTimerSheet: Bool = false
    @Published var showCamera: Bool = false
    @Published var permissionDenied: Bool = false
    @Published var note: String = ""
    @Published var price: String = ""
    @Published var showValidationAlert: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var categories: [String] = []
    
    @Published var createdItemId: String? = nil
    @Published var createdTimerId: String? = nil
    
    private let firestoreService = FireStoreService()
    
    var isValid: Bool {
        !itemName.isEmpty && selectedMood != nil && !price.isEmpty && selectedCategory != nil
    }
    
    func loadCategories(uid: String) {
        repo.fetchCategoryNames(uid: uid) { [weak self] categories in
            self?.categories = categories
        }
    }
    
    func pressedAddItemButton() {
        if isValid {
            showTimerSheet = true
        } else {
            showValidationAlert = true
        }
    }
    
    func removeImage() {
        imageCaptured = nil
    }
    
    func selectMood(_ mood: String) {
        selectedMood = selectedMood == mood ? nil : mood
    }
    
    func createItem(durationSeconds: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let priceDouble = Double(price) else { return }
        
        isLoading = true
        
        let newItem: [String: Any] = [
            "name" : itemName,
            "cost" : priceDouble,
            "mood" : selectedMood ?? "",
            "note" : note,
            "imageURL" : ""
        ]
        
        firestoreService.createItem(uid: uid, data: newItem, durationSeconds: durationSeconds, category: selectedCategory) { result in
                self.isLoading = false
                guard let result = result else {
                    self.errorMessage = "Failed to create item, please try again."
                    return
                }
                self.createdItemId = result["itemId"] as? String
                self.createdTimerId = result["timerId"] as? String
                print("Setting up log success to true")
        }
    }
}
