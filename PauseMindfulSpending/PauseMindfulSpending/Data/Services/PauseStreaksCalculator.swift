import Foundation
import FirebaseFirestore

// Helper records and functions needed to calculate streak state
struct CategoryRecord {
    let id: String
    let name: String
}

struct ItemRecord {
    let id: String
    let categoryId: String?
    let status: String
    let createdAt: Date?
}

struct BoughtEventRecord {
    let itemId: String
    let createdAt: Date
}

enum PauseStreaksCalculator {
    
    static func makeCategoryRecord(from doc: QueryDocumentSnapshot) -> CategoryRecord? {
        let data = doc.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        
        return CategoryRecord(
            id: doc.documentID,
            name: name
        )
    }
    
    static func makeItemRecord(from doc: QueryDocumentSnapshot) -> ItemRecord {
        let data = doc.data()
        
        let createdAt: Date?
        if let ts = data["createdAt"] as? Timestamp {
            createdAt = ts.dateValue()
        } else if let date = data["createdAt"] as? Date {
            createdAt = date
        } else {
            createdAt = nil
        }
        
        return ItemRecord(
            id: doc.documentID,
            categoryId: data["categoryId"] as? String,
            status: (data["status"] as? String ?? "").lowercased(),
            createdAt: createdAt
        )
    }
    
    static func makeBoughtEventRecord(from doc: QueryDocumentSnapshot) -> BoughtEventRecord? {
        let data = doc.data()
        
        guard
            let type = data["type"] as? String,
            type == "item_bought",
            let itemId = data["itemId"] as? String
        else {
            return nil
        }
        
        let createdAt: Date
        if let ts = data["createdAt"] as? Timestamp {
            createdAt = ts.dateValue()
        } else if let date = data["createdAt"] as? Date {
            createdAt = date
        } else {
            return nil
        }
        
        return BoughtEventRecord(
            itemId: itemId,
            createdAt: createdAt
        )
    }
    
    static func makeStreakState(
        categories: [CategoryRecord],
        items: [ItemRecord],
        boughtEvents: [BoughtEventRecord]
    ) -> DashboardStreakState {
        let itemById = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        
        let allBoughtDates = boughtEvents.map(\.createdAt)
        let activeItems = items.filter { isActiveForCurrentStreak(status: $0.status) }
        let allActiveItemCreatedDates = activeItems.compactMap(\.createdAt)
        
        let overallCurrentStreak = currentStreak(
            boughtDates: allBoughtDates,
            fallbackCreatedDates: allActiveItemCreatedDates
        )
        
        let overallHighestStreak = highestStreak(
            boughtDates: allBoughtDates,
            currentStreak: overallCurrentStreak
        )
        
        var summaries: [CategoryStreakSummary] = []
        
        for category in categories {
            let itemsInCategory = items.filter { $0.categoryId == category.id }
            let activeItemsInCategory = itemsInCategory.filter {
                isActiveForCurrentStreak(status: $0.status)
            }
            let fallbackCreatedDates = activeItemsInCategory.compactMap(\.createdAt)
            
            let boughtDatesInCategory: [Date] = boughtEvents.compactMap { event in
                guard let item = itemById[event.itemId] else { return nil }
                guard item.categoryId == category.id else { return nil }
                return event.createdAt
            }
            
            let current = currentStreak(
                boughtDates: boughtDatesInCategory,
                fallbackCreatedDates: fallbackCreatedDates
            )
            
            let highest = highestStreak(
                boughtDates: boughtDatesInCategory,
                currentStreak: current
            )
            
            if !itemsInCategory.isEmpty || !boughtDatesInCategory.isEmpty {
                summaries.append(
                    CategoryStreakSummary(
                        id: category.id,
                        name: category.name,
                        currentStreak: current,
                        highestStreak: highest
                    )
                )
            }
        }
        
        summaries.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        
        return DashboardStreakState(
            overallCurrentStreak: overallCurrentStreak,
            overallHighestStreak: overallHighestStreak,
            categorySummaries: summaries
        )
    }
    
    static func isActiveForCurrentStreak(status: String) -> Bool {
        switch status.lowercased() {
        case "wishlist", "completed":
            return true
        case "bought", "deleted":
            return false
        default:
            return true
        }
    }
    
    static func currentStreak(
        boughtDates: [Date],
        fallbackCreatedDates: [Date]
    ) -> Int {
        let calendar = Calendar.current
        
        if let mostRecentPurchase = boughtDates.sorted().last {
            return daysBetween(
                calendar.startOfDay(for: mostRecentPurchase),
                and: calendar.startOfDay(for: Date())
            )
        }
        
        if let earliestCreated = fallbackCreatedDates.sorted().first {
            return daysBetween(
                calendar.startOfDay(for: earliestCreated),
                and: calendar.startOfDay(for: Date())
            )
        }
        
        return 0
    }
    
    static func highestStreak(
        boughtDates: [Date],
        currentStreak: Int
    ) -> Int {
        let sortedDates = boughtDates
            .map { Calendar.current.startOfDay(for: $0) }
            .sorted()
        
        var highest = 0
        
        if sortedDates.count >= 2 {
            for index in 1..<sortedDates.count {
                let gap = daysBetween(sortedDates[index - 1], and: sortedDates[index])
                highest = max(highest, gap)
            }
        }
        
        return max(highest, currentStreak)
    }
    
    static func daysBetween(_ start: Date, and end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
