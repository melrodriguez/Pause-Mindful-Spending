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
    @Published var timerUpdated: Bool = false

    @Published var timerId: String?
    @Published var timerEndDate: Date?
    @Published var timerSeconds: Int = 0
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
        let totalSeconds = timerSeconds
        let days = totalSeconds / secondsInDay
        let hours = (totalSeconds % secondsInDay) / secondsInHour
        let minutes = (totalSeconds % secondsInHour) / secondsInMinute
        
        return String(format: "%02dd %02dh %02dm", days, hours, minutes)
    }
    
    func loadCategories(uid: String) {
        repo.fetchCategoryNames(uid: uid) { [weak self] categories in
            self?.categories = categories
        }
    }
    
    func getRemainingSeconds(endDate: Date?) -> Int {
        guard let endDate = timerEndDate else { return 0 }
        
        let remaining = max(0, endDate.timeIntervalSince(Date()))
        let totalSeconds = Int(remaining)
        return totalSeconds
    }
    
    func loadItem(uid: String) {
        guard let itemId = item.id  else { return }
        
        firestoreService.fetchItem(uid: uid, itemId: itemId) { data in
            
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
                        self.timerSeconds = self.getRemainingSeconds(endDate: timestamp.dateValue())
                    }
                }
            }
        }
    }
    
    func deleteItem(uid: String) {
        guard let itemId = item.id else { return }
        
        firestoreService.deleteItem(uid: uid, itemId: itemId)
    }
    
    func setItemAsBought(uid: String) {
        guard let itemId = item.id else { return }
        
        firestoreService.setItemAsBought(uid: uid, itemId: itemId)
    }
    
    func setItemAsCompleted(uid: String) {
        // Temporary function
        guard let itemId = item.id else { return }
        
        firestoreService.setItemAsCompleted(uid: uid, itemId: itemId)
    }

    // Mood and category never gets deselected
    // -> Only required fields are name and cost
    func updateIsValid(name: String, cost: Double, timer: Int) -> Bool {
        return (name.isEmpty || cost == 0 || timer == 0) ? false : true
    }
    
    // TODO: needs imageUrl logic
    func updateItem(uid: String) {
        guard let itemId = item.id  else { return }
        
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
                itemId: itemId,
                fieldsToUpdate: fieldsToUpdate
            )
            
            self.firestoreService.updateTimerItemName(uid: uid, timerId: self.timerId!, itemName: self.name)
            
            if self.timerUpdated {
                self.firestoreService.updateTimer(uid: uid, timerId: self.timerId!, newDurationSeconds: self.timerSeconds)
            }
        }
    }
    
}
