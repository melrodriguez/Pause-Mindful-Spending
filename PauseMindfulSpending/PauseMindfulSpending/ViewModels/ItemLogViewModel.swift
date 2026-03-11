import SwiftUI
import FirebaseFirestore

class ItemLogViewModel: ObservableObject {
    
    let item: Item
    
    @Published var name: String = "My Item"
    @Published var cost: Double?
    @Published var currencyCode: String = "USD"
    @Published var createdAt: Date?
    @Published var notes: String = ""
    @Published var mood: String = ""
    @Published var imageUrl: String? // does nothing for now
    @Published var categoryName: String = "No category"
    
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
    
    func loadItem(uid: String) {
        firestoreService.fetchItem(uid: uid, itemId: item.id) { data in
            
            guard let data = data else { return }
            
            let name = data["name"] as? String ?? "My Item"
            let cost = data["cost"] as? Double
            let currencyCode = data["currencyCode"] as? String ?? "USD"
            let notes = data["notes"] as? String ?? ""
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
                self.createdAt = createdAt
                self.timerId = timerId
            }
                    
            if let categoryId = categoryId {
                self.firestoreService.fetchCategory(uid: uid, categoryId: categoryId) { categoryData in
                    
                    guard let categoryData = categoryData else { return }
                    
                    DispatchQueue.main.async {
                        self.categoryName = categoryData["name"] as? String ?? ""
                    }
                }
            }
                        
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
    
    func pressedEditTimerButton() {
        print("pressed edit timer")
    }
    
    func pressedEditItemButton() {
        print("pressed edit item")
    }
    
    func pressedDeleteItemButton() {
        print("pressed delete item")
    }
}
