import SwiftUI
import FirebaseFirestore

// Handles navigation and logic for ItemLogView and EditItemLogView

class ItemLogViewModel: ObservableObject {
    // Reusing components
    private let repo = DashboardRepository()
    
    let item: Item
    
    @Published var name: String = "My Item"
    @Published var cost: Double?
    @Published var currencyCode: String = "USD"
    @Published var createdAt: Date?
    @Published var notes: String = ""
    @Published var mood: String = ""
    @Published var imageUrl: String? // does nothing for now
    @Published var categoryName: String?
    @Published var categoryId: String?
    @Published var categories: [String] = []
    
    @Published var timerId: String?
    @Published var timerEndDate: Date?
    private var secondsInDay = 86400
    private var secondsInHour = 3600
    private var secondsInMinute = 60
    
    private let firestoreService = FireStoreService()
    
    init(item: Item) {
        self.item = item
    }

    var formattedDate: String {
        createdAt?.formatted(date: .long, time: .omitted) ?? ""
    }
    
    var formattedPrice: String {
        cost?.formatted(.currency(code: currencyCode)) ?? ""
    }
    
    var formattedTimer: String {
        guard let endDate = timerEndDate else { return "" }
        
        let remaining = max(0, endDate.timeIntervalSince(Date()))
        let totalSeconds = Int(remaining)
        let days = totalSeconds / secondsInDay
        let hours = (totalSeconds % secondsInDay) / secondsInHour
        let minutes = (totalSeconds % secondsInHour) / secondsInMinute
        
        return "\(days)d \(hours)hr \(minutes)min"
    }
    
    func loadCategories(uid: String) {
        repo.fetchCategoryNames(uid: uid) { [weak self] categories in
            self?.categories = categories
        }
    }
    
    func loadItem(uid: String) {
        firestoreService.fetchItem(uid: uid, itemId: item.id) { data in
            
            guard let data = data else { return }
            
            let name = data["name"] as? String ?? "My Item"
            let cost = data["cost"] as? Double ?? 0
            let currencyCode = data["currencyCode"] as? String ?? "USD"
            let notes = data["note"] as? String ?? ""
            let mood = data["mood"] as? String ?? ""
            let imageUrl = data["imageUrl"] as? String
            let categoryId = data["categoryId"] as? String
            let timerId = data["timerId"] as? String
            
            var createdAt: Date?
            if let timestamp = data["createdAt"] as? Timestamp {
                createdAt = timestamp.dateValue()
            }
            
            DispatchQueue.main.async {
                self.name = name
                self.cost = cost
                self.currencyCode = currencyCode
                self.notes = notes
                self.mood = mood
                self.imageUrl = imageUrl
                self.categoryId = categoryId
                self.createdAt = createdAt
                self.timerId = timerId
            }
                    
            // Get the category from the collection
            if let categoryId = categoryId {
                self.firestoreService.fetchCategory(uid: uid, categoryId: categoryId) { categoryData in
                    
                    guard let categoryData = categoryData else { return }
                    
                    DispatchQueue.main.async {
                        self.categoryName = categoryData["name"] as? String
                    }
                }
            }
            
            // Get the timer from the collection
            if let timerId = timerId {
                self.firestoreService.fetchTimer(uid: uid, timerId: timerId) { timerData in
                    
                    guard
                        let timerData = timerData,
                        let timestamp = timerData["endDate"] as? Timestamp
                    else { return }
                    
                    DispatchQueue.main.async {
                        self.timerEndDate = timestamp.dateValue()
                    }
                }
            }
        }
    }
    
    func deleteItem(uid: String) {
        firestoreService.deleteItem(uid: uid, itemId: item.id)
    }
    
    // Mood and category never gets deselected
    // -> Only required fields are name and cost
    func updateIsValid(name: String, cost: Double) -> Bool {
        return (name.isEmpty || cost == 0) ? false : true
    }
    
    // TODO: needs imageUrl logic
    func updateItem(uid: String) {
        firestoreService.fetchCategoryIdUsingName(uid: uid, name: categoryName ?? "") { categoryId in
            
            var fieldsToUpdate: [String: Any] = [
                "name": self.name,
                "cost": self.cost!,
                "currencyCode": self.currencyCode,
                "note": self.notes,
                "mood": self.mood
            ]
            
            if let categoryId = categoryId {
                fieldsToUpdate["categoryId"] = categoryId
            }

            self.firestoreService.updateItem(
                uid: uid,
                itemId: self.item.id,
                fieldsToUpdate: fieldsToUpdate
            )
        }
    }
    
}
