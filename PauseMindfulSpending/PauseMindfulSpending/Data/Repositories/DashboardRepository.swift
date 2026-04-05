import Foundation
import FirebaseFirestore

class DashboardRepository {

    private let firestoreService = FireStoreService()
    private let db = Firestore.firestore()

    // Fetch the users categories
    func fetchCategoryNames(uid: String, completion: @escaping ([String]) -> Void) {
        firestoreService.fetchCategoryList(uid: uid) { categoryIds in
            guard !categoryIds.isEmpty else {
                completion([])
                return
            }

            let group = DispatchGroup()
            var namesByIndex = Array<String?>(repeating: nil, count: categoryIds.count)

            for (index, categoryId) in categoryIds.enumerated() {
                group.enter()

                self.firestoreService.fetchCategoryStringUsingId(uid: uid, categoryId: categoryId) { categoryName in
                    namesByIndex[index] = categoryName
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(namesByIndex.compactMap { $0 })
            }
        }
    }

    // Saves dashboard configuration locally
    func saveLocalDashboardConfig(_ config: DashboardConfig, uid: String) {
        guard let encoded = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(encoded, forKey: "dashboard_config_\(uid)")
    }
     
    func loadLocalDashboardConfig(uid: String) -> DashboardConfig {
        guard
            let data = UserDefaults.standard.data(forKey: "dashboard_config_\(uid)"),
            let decoded = try? JSONDecoder().decode(DashboardConfig.self, from: data)
        else {
            return .empty
        }
        return decoded
    }

    // Fetch the impulses resisted state to be displayed
    func fetchImpulsesState(
        uid: String,
        completion: @escaping (ImpulsesState) -> Void
    ) {
        let service = FireStoreService()

        service.fetchUserDocumentField(uid: uid, fieldName: "impulseResisted") { (resistedCount: Int?) in
            
            let resisted = resistedCount ?? 0
            
            service.db.collection("users")
                .document(uid)
                .collection("items")
                .getDocuments { snapshot, error in

                    if let error = error {
                        print("Failed to fetch items for impulses state:", error.localizedDescription)
                        completion(
                            ImpulsesState(
                                resistedCount: resisted,
                                boughtCount: 0
                            )
                        )
                        return
                    }

                    let documents = snapshot?.documents ?? []
                    var boughtCount = 0

                    for document in documents {
                        let data = document.data()
                        let status = (data["status"] as? String ?? "").lowercased()

                        if status == "bought" {
                            boughtCount += 1
                        }
                    }

                    completion(
                        ImpulsesState(
                            resistedCount: resisted,
                            boughtCount: boughtCount
                        )
                    )
                }
        }
    }

    // Fetch the money saved data for data points to be displayed
    func fetchMoneySavedState(
        uid: String,
        completion: @escaping (MoneySavedState) -> Void
    ) {
        let service = FireStoreService()

        service.fetchEventList(uid: uid) { eventIds in
            guard !eventIds.isEmpty else {
                completion(
                    MoneySavedState(
                        currencySymbol: "$",
                        weeklyData: [],
                        monthlyData: [],
                        allTimeData: []
                    )
                )
                return
            }

            let group = DispatchGroup()
            var events: [DashboardEvent] = []

            for eventId in eventIds {
                group.enter()

                service.fetchDetailsFromEvent(uid: uid, eventId: eventId) { details in
                    guard
                        let details = details,
                        let type = details["type"] as? String,
                        let timestamp = details["createdAt"] as? Timestamp
                    else {
                        group.leave()
                        return
                    }

                    let event = DashboardEvent(
                        id: eventId,
                        type: type,
                        createdAt: timestamp.dateValue(),
                        itemId: details["itemId"] as? String,
                        timerId: details["timerId"] as? String,
                        category: details["categoryId"] as? String,
                        amount: details["amount"] as? Double,
                        currencyCode: nil
                    )

                    events.append(event)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                let state = MoneySavedCalculator.makeMoneySavedState(
                    from: events.sorted { $0.createdAt < $1.createdAt },
                    currencySymbol: "$"
                )

                completion(state)
            }
        }
    }

    // Fetch streak state for pause streak display
    func fetchStreakState(
        uid: String,
        completion: @escaping (DashboardStreakState) -> Void
    ) {
        let categoriesRef = db.collection("users").document(uid).collection("categories")
        let itemsRef = db.collection("users").document(uid).collection("items")
        let eventsRef = db.collection("users").document(uid).collection("events")

        let group = DispatchGroup()

        var categoryDocs: [QueryDocumentSnapshot] = []
        var itemDocs: [QueryDocumentSnapshot] = []
        var eventDocs: [QueryDocumentSnapshot] = []

        var categoriesError: Error?
        var itemsError: Error?
        var eventsError: Error?

        group.enter()
        categoriesRef.getDocuments { snapshot, error in
            categoriesError = error
            categoryDocs = snapshot?.documents ?? []
            group.leave()
        }

        group.enter()
        itemsRef.getDocuments { snapshot, error in
            itemsError = error
            itemDocs = snapshot?.documents ?? []
            group.leave()
        }

        group.enter()
        eventsRef.order(by: "createdAt", descending: false).getDocuments { snapshot, error in
            eventsError = error
            eventDocs = snapshot?.documents ?? []
            group.leave()
        }

        group.notify(queue: .main) {
            if let categoriesError = categoriesError {
                print("Failed to fetch categories for streak state:", categoriesError.localizedDescription)
            }
            if let itemsError = itemsError {
                print("Failed to fetch items for streak state:", itemsError.localizedDescription)
            }
            if let eventsError = eventsError {
                print("Failed to fetch events for streak state:", eventsError.localizedDescription)
            }

            guard categoriesError == nil, itemsError == nil, eventsError == nil else {
                completion(.empty)
                return
            }

            let categories = categoryDocs.compactMap { PauseStreaksCalculator.makeCategoryRecord(from: $0) }
            let items = itemDocs.map { PauseStreaksCalculator.makeItemRecord(from: $0) }
            let boughtEvents = eventDocs.compactMap { PauseStreaksCalculator.makeBoughtEventRecord(from: $0) }

            let state = PauseStreaksCalculator.makeStreakState(
                categories: categories,
                items: items,
                boughtEvents: boughtEvents
            )

            completion(state)
        }
    }
    
    func fetchActivityCalendarState(
        uid: String,
        completion: @escaping ([String: Int]) -> Void
    ) {
        let service = FireStoreService()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Reuses the existing fetchEventList already in FireStoreService+Events.swift
        service.fetchEventList(uid: uid) { eventIds in
            guard !eventIds.isEmpty else {
                completion([:])
                return
            }

            let group = DispatchGroup()
            var activityByDay: [String: Int] = [:]
            let lock = NSLock()

            for eventId in eventIds {
                group.enter()

                service.fetchDetailsFromEvent(uid: uid, eventId: eventId) { details in
                    defer { group.leave() }

                    guard
                        let details = details,
                        let type = details["type"] as? String,
                        let timestamp = details["createdAt"] as? Timestamp
                    else { return }

                    let countedTypes: Set<String> = [
                        "item_created",
                        "item_bought",
                        "item_completed",
                        "item_deleted"
                    ]

                    guard countedTypes.contains(type) else { return }

                    let dateKey = formatter.string(from: timestamp.dateValue())

                    lock.lock()
                    activityByDay[dateKey, default: 0] += 1
                    lock.unlock()
                }
            }

            group.notify(queue: .main) {
                completion(activityByDay)
            }
        }
    }
    
    // Saves budget limits to Firestore, then caches locally as a fallback.
    // Also deletes any categories the user removed from their budget.
    func saveBudgetConfig(
        uid: String,
        budgets: [BudgetCategory],
        previousBudgets: [BudgetCategory],
        completion: @escaping (Bool) -> Void
    ) {
        // Delete categories that were removed
        let removedIds = Set(previousBudgets.map(\.id)).subtracting(Set(budgets.map(\.id)))
        for id in removedIds {
            firestoreService.deleteBudget(uid: uid, categoryId: id)
        }

        // Save to Firestore
        firestoreService.saveBudgets(uid: uid, budgets: budgets) { success in
            if success {
                // Also cache locally so the widget loads instantly on next open
                if let encoded = try? JSONEncoder().encode(budgets) {
                    UserDefaults.standard.set(encoded, forKey: "budget_config_\(uid)")
                }
            }
            completion(success)
        }
    }

    func loadCachedBudgetConfig(uid: String) -> [BudgetCategory] {
        guard
            let data = UserDefaults.standard.data(forKey: "budget_config_\(uid)"),
            let decoded = try? JSONDecoder().decode([BudgetCategory].self, from: data)
        else { return [] }
        return decoded
    }

    func fetchBudgetState(
        uid: String,
        completion: @escaping (BudgetState) -> Void
    ) {
        let service = FireStoreService()

        service.fetchBudgets(uid: uid) { savedBudgets in
            guard !savedBudgets.isEmpty else {
                completion(BudgetState(categories: [], currencySymbol: "$"))
                return
            }

            if let encoded = try? JSONEncoder().encode(savedBudgets) {
                UserDefaults.standard.set(encoded, forKey: "budget_config_\(uid)")
            }

            service.fetchEventList(uid: uid) { eventIds in
                guard !eventIds.isEmpty else {
                    completion(BudgetState(categories: savedBudgets, currencySymbol: "$"))
                    return
                }

                let group = DispatchGroup()

                struct RawPurchase {
                    let eventId: String
                    let itemId: String?
                    let categoryId: String?
                    let amount: Double
                    let date: Date
                }

                var rawPurchases: [RawPurchase] = []

                for eventId in eventIds {
                    group.enter()
                    service.fetchDetailsFromEvent(uid: uid, eventId: eventId) { details in
                        defer { group.leave() }
                        guard
                            let details = details,
                            let type = details["type"] as? String,
                            type == "item_bought",
                            let amount = details["amount"] as? Double,
                            let timestamp = details["createdAt"] as? Timestamp
                        else { return }

                        rawPurchases.append(RawPurchase(
                            eventId: eventId,
                            itemId: details["itemId"] as? String,
                            categoryId: details["categoryId"] as? String,
                            amount: amount,
                            date: timestamp.dateValue()
                        ))
                    }
                }

                group.notify(queue: .main) {
                    let resolveGroup = DispatchGroup()

                    var idToName: [String: String] = [:]
                    for categoryId in Set(rawPurchases.compactMap(\.categoryId)) {
                        resolveGroup.enter()
                        service.fetchCategoryStringUsingId(uid: uid, categoryId: categoryId) { name in
                            if let name = name { idToName[categoryId] = name }
                            resolveGroup.leave()
                        }
                    }

                    var itemIdToName: [String: String] = [:]
                    for itemId in Set(rawPurchases.compactMap(\.itemId)) {
                        resolveGroup.enter()
                        service.fetchItem(uid: uid, itemId: itemId) { data in
                            if let name = data?["name"] as? String {
                                itemIdToName[itemId] = name
                            }
                            resolveGroup.leave()
                        }
                    }

                    resolveGroup.notify(queue: .main) {
                        var overallPurchases: [BudgetPurchase] = []
                        var purchasesByName: [String: [BudgetPurchase]] = [:]

                        for raw in rawPurchases.sorted(by: { $0.date > $1.date }) {
                            let itemName = raw.itemId.flatMap { itemIdToName[$0] } ?? "Unknown item"

                            let purchase = BudgetPurchase(
                                id: raw.eventId,
                                itemName: itemName,
                                amount: raw.amount,
                                date: raw.date
                            )

                            overallPurchases.append(purchase)

                            if let categoryId = raw.categoryId,
                               let name = idToName[categoryId] {
                                purchasesByName[name, default: []].append(purchase)
                            }
                        }

                        let withSpending: [BudgetCategory] = savedBudgets.map { budget in
                            var updated = budget
                            if budget.id == "Overall" {
                                updated.spent = overallPurchases.reduce(0) { $0 + $1.amount }
                                updated.purchases = overallPurchases
                            } else {
                                let categoryPurchases = purchasesByName[budget.id] ?? []
                                updated.spent = categoryPurchases.reduce(0) { $0 + $1.amount }
                                updated.purchases = categoryPurchases
                            }
                            return updated
                        }

                        completion(BudgetState(categories: withSpending, currencySymbol: "$"))
                    }
                }
            }
        }
    }
}
